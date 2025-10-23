#!/usr/bin/env python3
"""
fetch_bigquery_bytecode.py

# pip install google-cloud-bigquery
# export GOOGLE_APPLICATION_CREDENTIALS="/media/tam10086/Data/CryptoX/SC Developer Survey/ICSE26/anonymous repo/sc-developer-study-1/Empirical Evaluation of Security Analyzers/scdataset-7d67708771c5.json"


"""


#!/usr/bin/env python3
"""
fetch_bigquery_bytecode_by_filename.py

For each .sol file in the Solidity/ folder extract the contract address from the filename,
fetch the contract's bytecode from BigQuery (bigquery-public-data.crypto_ethereum.contracts),
and save a .rt.hex file in Bytecode/ with the same basename as the .sol file.

Behavior:
 - If multiple .sol files contain the same address, each .sol gets its own .rt.hex file.
 - Bytecode is saved WITHOUT the leading "0x".
 - If bytecode is missing/empty for an address, an empty .rt.hex file is still created and a warning is printed.

Requirements:
  pip install google-cloud-bigquery
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
"""


import os
import re
import csv
import argparse
import sys
from typing import Dict, List, Optional

from google.cloud import bigquery

# ---------- Config ----------
SOLIDITY_DIR = "Solidity"
BYTECODE_DIR = "Bytecode"
BATCH_SIZE = 800  # BigQuery array parameter batch size (tune as needed)
ADDRESS_RE = re.compile(r"0x[a-fA-F0-9]{40}")

# ---------- Helpers ----------
def extract_address_from_filename(fname: str) -> Optional[str]:
    """Return first 0x...40-hex address found in filename, or None."""
    m = ADDRESS_RE.search(fname)
    return m.group(0).lower() if m else None

def collect_files(solidity_dir: str) -> Dict[str, List[str]]:
    """
    Scan solidity_dir for .sol files.
    Return mapping: address (lowercase) -> list of filenames that contain that address.
    """
    if not os.path.isdir(solidity_dir):
        raise FileNotFoundError(f"Solidity directory not found: {solidity_dir}")

    mapping: Dict[str, List[str]] = {}
    total_files = 0
    for fname in os.listdir(solidity_dir):
        path = os.path.join(solidity_dir, fname)
        if not os.path.isfile(path):
            continue
        if not fname.lower().endswith(".sol"):
            continue
        total_files += 1
        addr = extract_address_from_filename(fname)
        if not addr:
            print(f"[WARN] No address found in filename: {fname}")
            continue
        mapping.setdefault(addr, []).append(fname)
    print(f"[INFO] Found {total_files} .sol files, {len(mapping)} unique addresses.")
    return mapping

def ensure_output_dir(d: str):
    os.makedirs(d, exist_ok=True)

def save_bytecode_for_filename(output_dir: str, solidity_filename: str, bytecode: Optional[str]):
    """
    Save the bytecode for this solidity_filename as <basename>.rt.hex inside output_dir.
    If bytecode is None or empty, create an empty file.
    If bytecode starts with '0x', strip it.
    """
    basename = os.path.splitext(solidity_filename)[0]
    outname = basename + ".rt.hex"
    outpath = os.path.join(output_dir, outname)
    try:
        if bytecode and isinstance(bytecode, str) and len(bytecode) > 2:
            data = bytecode[2:] if bytecode.startswith(("0x", "0X")) else bytecode
            with open(outpath, "w", encoding="utf-8") as f:
                f.write(data)
            return True, outpath, len(data)
        else:
            # create empty file (or write empty string)
            with open(outpath, "w", encoding="utf-8") as f:
                f.write("") 
            return False, outpath, 0
    except Exception as e:
        return None, outpath, str(e)

def chunked(iterable: List[str], size: int):
    for i in range(0, len(iterable), size):
        yield iterable[i:i+size]

# ---------- BigQuery query ----------
def query_bytecodes_bigquery(client: bigquery.Client, addresses: List[str]) -> Dict[str, Optional[str]]:
    """
    Query BigQuery for the list of addresses.
    Returns mapping address->bytecode (or None if not found).
    Uses ARRAY parameter (UNNEST(@addrs)) for safety vs long IN lists.
    """
    sql = """
    SELECT LOWER(address) AS address, bytecode
    FROM `bigquery-public-data.crypto_ethereum.contracts`
    WHERE LOWER(address) IN UNNEST(@addrs)
    """
    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ArrayQueryParameter("addrs", "STRING", addresses)
        ]
    )
    query_job = client.query(sql, job_config=job_config)
    results = query_job.result()  # block
    mapping: Dict[str, Optional[str]] = {a.lower(): None for a in addresses}
    for row in results:
        addr = str(row["address"]).lower()
        bytecode = row["bytecode"]
        mapping[addr] = bytecode if bytecode is not None else None
    return mapping

# ---------- Main ----------
def main(solidity_dir: str = SOLIDITY_DIR, bytecode_dir: str = BYTECODE_DIR, batch_size: int = BATCH_SIZE, project: Optional[str] = None):
    ensure_output_dir(bytecode_dir)

    # collect files and mapping
    addr_to_files = collect_files(solidity_dir)
    if not addr_to_files:
        print("[INFO] No .sol files with addresses found. Exiting.")
        return

    # prepare BigQuery client
    client = bigquery.Client(project=project) if project else bigquery.Client()

    # Flatten unique addresses list
    unique_addresses = list(addr_to_files.keys())

    # Progress counters
    total_addresses = len(unique_addresses)
    saved_count = 0
    empty_count = 0
    error_count = 0
    processed_addresses = 0

    print(f"[INFO] Querying BigQuery in batches of {batch_size} (total addresses: {total_addresses})")

    for batch_idx, batch in enumerate(chunked(unique_addresses, batch_size), start=1):
        print(f"[INFO] Batch {batch_idx}: querying {len(batch)} addresses...")
        try:
            mapping = query_bytecodes_bigquery(client, batch)
        except Exception as e:
            print(f"[ERROR] BigQuery query failed for batch {batch_idx}: {e}")
            # For safety, still create empty files for all solidity files in this batch, and mark as errors.
            for addr in batch:
                for fname in addr_to_files.get(addr, []):
                    res = save_bytecode_for_filename(bytecode_dir, fname, None)
                    error_count += 1
                    print(f"[ERROR_CREATE] Created empty file for {fname} due to query failure.")
            continue

        # For each address in batch, save bytecode for every corresponding solidity filename
        for addr in batch:
            processed_addresses += 1
            bytecode = mapping.get(addr)  # may be None
            filenames = addr_to_files.get(addr, [])
            if not filenames:
                # should not happen
                continue

            if bytecode and isinstance(bytecode, str) and len(bytecode) > 2:
                # Save for all filenames mapped to this address
                for fname in filenames:
                    ok, path_or_err, size_or_zero = save_bytecode_for_filename(bytecode_dir, fname, bytecode)
                    if ok:
                        saved_count += 1
                        print(f"[SAVED] {fname} <- {addr} (bytes hex len: {size_or_zero})")
                    else:
                        # ok==False means empty created, None means error
                        if ok is False:
                            empty_count += 1
                            print(f"[WARN] {fname} <- {addr}: bytecode empty (created empty file).")
                        else:
                            error_count += 1
                            print(f"[ERROR] {fname} <- {addr}: failed to save ({path_or_err})")
            else:
                # bytecode missing or '0x' or None; still create empty file for each solidity filename
                for fname in filenames:
                    ok, path_or_err, size_or_zero = save_bytecode_for_filename(bytecode_dir, fname, None)
                    empty_count += 1
                    print(f"[MISSING] {fname} <- {addr}: no bytecode found; created empty file.")

    print("----- Summary -----")
    print(f"Addresses processed: {processed_addresses}/{total_addresses}")
    print(f"Files with saved bytecode: {saved_count}")
    print(f"Files created empty (no bytecode): {empty_count}")
    print(f"Errors: {error_count}")
    print(f"Bytecode files written to: {os.path.abspath(bytecode_dir)}")
    print("-------------------")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch bytecode from BigQuery and write .rt.hex files per .sol filename.")
    parser.add_argument("--solidity-dir", default=SOLIDITY_DIR, help="Directory containing .sol files (default: Solidity)")
    parser.add_argument("--bytecode-dir", default=BYTECODE_DIR, help="Directory to write .rt.hex files (default: Bytecode)")
    parser.add_argument("--batch-size", type=int, default=BATCH_SIZE, help="Batch size for BigQuery queries (default: 800)")
    parser.add_argument("--project", default=None, help="Optional GCP project for BigQuery client")
    args = parser.parse_args()
    main(solidity_dir=args.solidity_dir, bytecode_dir=args.bytecode_dir, batch_size=args.batch_size, project=args.project)
