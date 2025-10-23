#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""


# https://www.usenix.org/system/files/usenixsecurity23-appendix-abdelaziz.pdf to install DLVA

"""

import pandas as pd
import os

os.system("mkdir ~/dlva")

import re
from pathlib import Path
import pandas as pd

# Configuration
BYTECODE_DIR = Path("Bytecode")            # folder containing .rt.hex files
DLVA_DIR = Path.home() / "dlva"           # ~/dlva
TOOLS_LABELS_DIR = Path("Tools_Labels")   # local Tools_Labels folder

attack_types = ["Reentrancy", "Suicide", "IntergerOU"]

# Regex patterns
ADDRESS_RE = re.compile(r"0x[a-fA-F0-9]{40}")
LABEL_RE = re.compile(r"\*(0|1)\*")  # finds *0* or *1*

def normalize_for_match(s: str) -> str:
    """Lowercase and remove non-alphanumeric characters for robust matching."""
    return re.sub(r"[^0-9a-z]", "", s.lower())

def collect_all_evm_files(bytecode_dir: Path):
    """Return list of Path objects for .rt.hex files in bytecode_dir (non-recursive)."""
    if not bytecode_dir.exists() or not bytecode_dir.is_dir():
        raise FileNotFoundError(f"Bytecode directory not found: {bytecode_dir.resolve()}")
    return sorted(p for p in bytecode_dir.iterdir() if p.is_file() and p.suffix.lower() == ".hex")

def extract_label_from_filename(fn: str):
    """Return '0' or '1' if found as *0* or *1* in filename; otherwise None."""
    m = LABEL_RE.search(fn)
    return m.group(1) if m else None

def extract_address_from_filename(fn: str):
    """Return first 0x...40hex address found in filename, or None."""
    m = ADDRESS_RE.search(fn)
    return m.group(0) if m else None

def read_bytecode(path: Path):
    """Read and return file contents (strip trailing whitespace)."""
    try:
        with path.open("r", encoding="utf-8") as f:
            return f.read().strip()
    except Exception as e:
        print(f"[ERROR] Failed to read {path}: {e}")
        return None

def ensure_dirs():
    DLVA_DIR.mkdir(parents=True, exist_ok=True)
    TOOLS_LABELS_DIR.mkdir(parents=True, exist_ok=True)

def main():
    ensure_dirs()
    evm_files = collect_all_evm_files(BYTECODE_DIR)
    if not evm_files:
        print(f"[WARN] No .rt.hex files found in {BYTECODE_DIR.resolve()}. Exiting.")
        return

    # Pre-collect metadata for all files to avoid repeated I/O
    records = []
    for p in evm_files:
        fname = p.name
        label = extract_label_from_filename(fname)
        address = extract_address_from_filename(fname)
        bytecode = read_bytecode(p)

        if bytecode is None:
            # skip files that couldn't be read
            print(f"[WARN] Skipping unreadable file {p}")
            continue

        records.append({
            "filename": fname,
            "path": str(p.resolve()),
            "address": address if address else "",
            "label": label if label is not None else "",
            "bytecode": bytecode,
        })

    if not records:
        print("[WARN] No valid records collected. Exiting.")
        return

    # Convert to DataFrame for easy filtering
    df_all = pd.DataFrame.from_records(records, columns=["filename","path","address","label","bytecode"])

    # For each attack, filter rows where normalized attack token is present in normalized filename
    for attack in attack_types:
        norm_attack = normalize_for_match(attack)
        def attack_in_filename(row_fname: str) -> bool:
            return norm_attack in normalize_for_match(row_fname)

        df_attack = df_all[df_all["filename"].apply(attack_in_filename)].copy()

        if df_attack.empty:
            print(f"[INFO] No files found for attack '{attack}'. Creating empty CSVs.")
            df_out = pd.DataFrame(columns=["address","label","bytecode"])
        else:
            # Keep only the requested columns and drop rows missing label or address if you prefer
            df_out = df_attack[["address","label","bytecode"]].copy()

        # Output paths
        out1 = DLVA_DIR / f"{attack}_runtime-bytecode.csv"
        out2 = TOOLS_LABELS_DIR / f"{attack}_runtime-bytecode.csv"

        # Save CSVs (index=False)
        df_out.to_csv(out1, index=False)
        df_out.to_csv(out2, index=False)

        print(f"[OK] Wrote {len(df_out)} rows for attack '{attack}' to:")
        print(f"     {out1}")
        print(f"     {out2}")

    print("Done!")

if __name__ == "__main__":
    main()



# DLVA SMALL

# mkdir Tools_Labels/dlva

# docker pull dlva/dlva:latest
# docker run -i -t -v ~/dlva/:/DLVA_Tool/dlva/ dlva/dlva

# For reentrancy           2 --> 2 --> ../dlva/Reentrancy_runtime-bytecode.csv
# For suicide              2 --> 2 --> ../dlva/Suicide_runtime-bytecode.csv


# cp ~/dlva/DLVA_Predictions_for_Reentrancy_runtime-bytecode.csv Tools_Labels/dlva/DLVA_Predictions_for_Reentrancy_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_Suicide_runtime-bytecode.csv Tools_Labels/dlva/DLVA_Predictions_for_Suicide_runtime-bytecode.csv

"""
dlva_times = {
    "reentrancy": 75.25,
    "suicide": 159.61,
    "unchecked-exceptions": 66.22,
}
"""



#DLVA LARGE

# mkdir Tools_Labels/dlvaL

# docker pull dlva/dlva-large:latest
# docker run -i -t -v ~/dlva/:/DLVA_Tool/dlva/ dlva/dlva-large

# For reentrancy           2 --> ../dlva/Reentrancy_runtime-bytecode.csv
# For suicide              2 --> ../dlva/Suicide_runtime-bytecode.csv


# cp ~/dlva/DLVA_Predictions_for_Reentrancy_runtime-bytecode.csv Tools_Labels/dlvaL/DLVA_Predictions_for_Reentrancy_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_Suicide_runtime-bytecode.csv Tools_Labels/dlvaL/DLVA_Predictions_for_Suicide_runtime-bytecode.csv

"""
dlvaL_times = {
    "reentrancy": 220,
    "suicide": 450,
}
"""