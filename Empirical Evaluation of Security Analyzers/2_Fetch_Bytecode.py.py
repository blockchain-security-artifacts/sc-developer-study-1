#!/usr/bin/env python3
"""
fetch_bytecode_v2.py

Scan a folder named "Solidity" for .sol files whose filenames contain an Ethereum
contract address, fetch each contract's runtime bytecode from Etherscan API V2,
and save it to a "Bytecode" folder with the same base filename and a .evm extension.

Usage examples:
    python fetch_bytecode_v2.py
    python fetch_bytecode_v2.py --solidity-dir ./Solidity --bytecode-dir ./Bytecode --api-key YOUR_KEY
    python fetch_bytecode_v2.py --chainid 137   # For Polygon (example)

Requirements:
  - requests
    pip install requests
"""

from __future__ import annotations
import os
import re
import time
import argparse
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from typing import Optional, Tuple

# Use environment variable if set, otherwise you can pass with --api-key
DEFAULT_API_KEY = os.environ.get("ETHERSCAN_API_KEY", "PTIR3VR214N7JZPM35IYMABH2BBKRSXE8S")

# Address regex
ADDRESS_RE = re.compile(r"0x[a-fA-F0-9]{40}")

def extract_address_from_filename(filename: str) -> Optional[str]:
    """Return the first ethereum address found in the filename, or None."""
    m = ADDRESS_RE.search(filename)
    return m.group(0) if m else None

def make_session(retries: int = 5, backoff_factor: float = 1.0,
                 status_forcelist=(429, 500, 502, 503, 504)) -> requests.Session:
    """Create a requests Session with retry/backoff configured."""
    session = requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
        allowed_methods=frozenset(["GET", "POST"]),
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session

def get_contract_runtime_code(session: requests.Session, api_key: str, contract_address: str,
                              chainid: int = 1, timeout: float = 10.0) -> Tuple[bool, str]:
    """
    Fetch the runtime bytecode of a smart contract from Etherscan API V2.

    Returns (success, result). On success result is the hex bytecode (e.g. "0x..."),
    on failure result is an error message.
    """
    base_url = "https://api.etherscan.io/v2/api"  # Etherscan V2 base path (requires chainid)
    params = {
        "chainid": chainid,
        "module": "proxy",
        "action": "eth_getCode",
        "address": contract_address,
        "tag": "latest",
        "apikey": api_key,
    }

    try:
        resp = session.get(base_url, params=params, timeout=timeout)
        resp.raise_for_status()
    except requests.exceptions.RequestException as e:
        return False, f"HTTP request failed: {e}"

    # attempt to parse json
    try:
        data = resp.json()
    except ValueError:
        return False, f"Invalid JSON response: {resp.text[:200]}"

    # Etherscan sometimes returns an error object like {"status":"0","message":"NOTOK","result":"..."}
    # For proxy methods it frequently returns {"jsonrpc":"2.0","id":1,"result":"0x..."}
    # We'll try to handle both shapes.
    if isinstance(data, dict):
        # Check for deprecation message explicitly (defensive)
        result_field = data.get("result")
        if isinstance(result_field, str) and "deprecated" in result_field.lower():
            return False, f"Etherscan V1 deprecation message: {result_field}"

        # If proxy returns result field with code
        if "result" in data and isinstance(data["result"], str):
            return True, data["result"]

        # Some endpoints include status/message/result pattern
        if data.get("status") in ("1", 1) and "result" in data:
            return True, str(data["result"])

        # If NOTOK, return result/error
        if data.get("status") in ("0", 0):
            return False, f"Etherscan returned error: status=0 message={data.get('message')} result={data.get('result')}"
    # Fallback
    return False, f"Unexpected response shape: {data}"

def save_to_file(path: str, data: str) -> bool:
    """Write data to the path. Returns True on success."""
    try:
        # Write as text (hex string). Use utf-8 just in case.
        with open(path, "w", encoding="utf-8") as f:
            f.write(data)
        return True
    except Exception as e:
        print(f"[ERROR] Failed to write {path}: {e}")
        return False

def process_directory(solidity_dir: str, bytecode_dir: str, api_key: str,
                      chainid: int = 1, sleep_between_requests: float = 0.25,
                      overwrite: bool = False):
    """Main directory processing loop."""
    if not os.path.isdir(solidity_dir):
        raise FileNotFoundError(f"Solidity directory not found: {solidity_dir}")

    os.makedirs(bytecode_dir, exist_ok=True)

    filenames = [f for f in os.listdir(solidity_dir) if os.path.isfile(os.path.join(solidity_dir, f))]
    total_files = len(filenames)
    print(f"[INFO] Found {total_files} files in {solidity_dir}. Processing .sol files...")

    session = make_session()

    processed = 0
    skipped = 0
    errors = 0

    for fname in filenames:
        if not fname.lower().endswith(".sol"):
            skipped += 1
            continue

        address = extract_address_from_filename(fname)
        if address is None:
            print(f"[WARN] No address found in filename '{fname}' - skipping.")
            errors += 1
            continue

        out_basename = os.path.splitext(fname)[0] + ".evm"
        out_path = os.path.join(bytecode_dir, out_basename)

        if os.path.exists(out_path) and not overwrite:
            print(f"[SKIP] Output exists and overwrite=False: {out_basename}")
            skipped += 1
            continue

        success, result = get_contract_runtime_code(session, api_key, address, chainid=chainid)
        if not success:
            print(f"[ERROR] Failed to fetch {address} for '{fname}': {result}")
            errors += 1
            # small extra backoff then continue
            time.sleep(max(0.5, sleep_between_requests))
            continue

        bytecode = result
        # Save the bytecode (even "0x" will be saved unless you'd prefer to skip)
        if save_to_file(out_path, bytecode):
            size = len(bytecode) if bytecode else 0
            print(f"[OK] Saved {out_basename} ({address}) - {size} chars")
            processed += 1
        else:
            errors += 1

        # politeness / rate-limit avoidance
        time.sleep(sleep_between_requests)

    print("----- Summary -----")
    print(f"Processed: {processed}")
    print(f"Skipped:   {skipped}")
    print(f"Errors:    {errors}")
    print("-------------------")

def parse_args():
    p = argparse.ArgumentParser(description="Fetch contract runtime bytecode from Etherscan API V2 for files in a Solidity folder.")
    p.add_argument("--solidity-dir", "-s", default="Solidity", help="Directory that contains .sol files (default: ./Solidity)")
    p.add_argument("--bytecode-dir", "-b", default="Bytecode", help="Directory where .evm files will be written (default: ./Bytecode)")
    p.add_argument("--api-key", "-k", default=DEFAULT_API_KEY, help="Etherscan API key (or set ETHERSCAN_API_KEY env var).")
    p.add_argument("--chainid", type=int, default=1, help="Chain ID for Etherscan V2 (default: 1 for Ethereum mainnet).")
    p.add_argument("--sleep", type=float, default=0.25, help="Seconds to sleep between requests (default 0.25).")
    p.add_argument("--overwrite", action="store_true", help="Overwrite existing .evm files if present.")
    return p.parse_args()

if __name__ == "__main__":
    args = parse_args()
    if not args.api_key or args.api_key.strip() == "":
        print("[ERROR] No Etherscan API key provided. Provide one with --api-key or set ETHERSCAN_API_KEY environment variable.")
        raise SystemExit(1)

    try:
        process_directory(args.solidity_dir, args.bytecode_dir, args.api_key,
                          chainid=args.chainid, sleep_between_requests=args.sleep,
                          overwrite=args.overwrite)
    except Exception as exc:
        print(f"[FATAL] {exc}")
        raise
