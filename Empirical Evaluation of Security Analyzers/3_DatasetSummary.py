#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: ...

"""

import pandas as pd
import os
import matplotlib.pyplot as plt
from collections import defaultdict


def count_csv_rows(file_path):
    """
    Counts the number of rows in a CSV file.
    Returns 0 if the file does not exist or is empty.
    """
    try:
        df = pd.read_csv(file_path)
        return len(df)
    except FileNotFoundError:
        print(f"Warning: File not found at {file_path}")
        return 0
    except pd.errors.EmptyDataError:
        print(f"Warning: File is empty at {file_path}")
        return 0
    except Exception as e:
        print(f"Error reading CSV file {file_path}: {e}")
        return 0


def count_files_in_directory(directory_path):
    """
    Counts the number of files (excluding directories) in a given directory.
    Returns 0 if the directory does not exist.
    """
    if not os.path.isdir(directory_path):
        print(f"Warning: Directory not found at {directory_path}")
        return 0
    return len(
        [
            name
            for name in os.listdir(directory_path)
            if os.path.isfile(os.path.join(directory_path, name))
        ]
    )


def get_addresses_from_csvs(vulnerabilities, data_folder="Data"):
    """
    Reads all deduplicated CSV files for the given vulnerabilities and extracts
    all unique addresses from them. Assumes addresses are in a column named 'Address'.
    """
    all_csv_addresses = set()
    for vul in vulnerabilities:
        file_path_deduplicated = os.path.join(data_folder, f"{vul}.csv")
        try:
            df = pd.read_csv(file_path_deduplicated)
            if "Address" in df.columns:
                all_csv_addresses.update(df["Address"].astype(str).tolist())
            else:
                print(
                    f"Warning: 'Address' column not found in {file_path_deduplicated}. Skipping address extraction for this file."
                )
        except FileNotFoundError:
            print(
                f"Warning: Deduplicated CSV file not found at {file_path_deduplicated}. Skipping."
            )
        except pd.errors.EmptyDataError:
            print(
                f"Warning: Deduplicated CSV file is empty at {file_path_deduplicated}. Skipping."
            )
        except Exception as e:
            print(f"Error reading deduplicated CSV file {file_path_deduplicated}: {e}")
    return all_csv_addresses


def get_addresses_from_etherscan_files(etherscan_folder="Etherscan"):
    """
    Gets all unique filenames (assumed to be addresses) from the Etherscan directory.
    Removes file extensions.
    """
    etherscan_addresses = set()
    if os.path.isdir(etherscan_folder):
        for filename in os.listdir(etherscan_folder):
            if os.path.isfile(os.path.join(etherscan_folder, filename)):
                address, _ = os.path.splitext(filename)
                etherscan_addresses.add(address.split("*")[-1])
    else:
        print(f"Warning: Etherscan directory not found at {etherscan_folder}")
    return etherscan_addresses

def plot():
    # Define folder and attack types
    solidity_folder = "Solidity"
    attack_types = ["Reentrancy", "Suicide", "IntergerOU"]

    # Store LOCs: attack_type -> {0: [], 1: []}
    loc_data = {attack: {0: [], 1: []} for attack in attack_types}

    # Parse files
    for filename in os.listdir(solidity_folder):
        if filename.endswith(".sol"):
            parts = filename.split("*")
            if len(parts) != 3:
                continue  # skip malformed filenames

            attack, label_str, _ = parts
            if attack not in attack_types:
                continue

            try:
                label = int(label_str)
            except ValueError:
                continue

            # Count non-empty lines
            file_path = os.path.join(solidity_folder, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    loc = sum(1 for line in f if line.strip())
                loc_data[attack][label].append(loc)
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

    # Plot and print totals
    for attack in attack_types:
        safe_count = len(loc_data[attack][0])
        vuln_count = len(loc_data[attack][1])
        
        print(f"\n=== {attack} ===")
        print(f"Safe contracts (label=0):      {safe_count}")
        print(f"Vulnerable contracts (label=1): {vuln_count}")

        # Plot histogram
        plt.figure(figsize=(8, 5))
        plt.hist(loc_data[attack][0], bins=20, alpha=0.7, label=f"Safe (0): {safe_count}", color='green')
        plt.hist(loc_data[attack][1], bins=20, alpha=0.7, label=f"Vulnerable (1): {vuln_count}", color='red')
        plt.title(f"LOC Histogram for {attack}")
        plt.xlabel("Lines of Code (non-empty)")
        plt.ylabel("Number of Contracts")
        plt.legend()
        plt.grid(True)
        plt.tight_layout()
        plt.savefig(f"loc_histogram_{attack}.png")
        plt.show()



def main():
    vulnerabilities = ["Reentrancy", "Suicide", "IntergerOU"]

    # Dictionary to store detailed summary for each vulnerability
    summary_details = {}

    # Variables to store overall totals for CSVs
    total_original_csv = 0
    total_deduplicated_csv = 0

    print("--- Detailed Vulnerability Summary (CSV Data) ---")
    print("-" * 50)

    for vul in vulnerabilities:
        print(f"\nVulnerability: {vul}")
        print("-" * (len(vul) + 15))

        # 1. Original vs Removed Duplicates (CSV files)
        file_path_original = f"Data/{vul}_0.csv"
        file_path_deduplicated = f"Data/{vul}.csv"

        original_count = count_csv_rows(file_path_original)
        deduplicated_count = count_csv_rows(file_path_deduplicated)
        removed_duplicates = original_count - deduplicated_count

        print(f"  CSV Data (original vs removed duplicates):")
        print(f"    Original count: {original_count}")
        print(f"    Deduplicated count: {deduplicated_count}")
        print(f"    Duplicates removed: {removed_duplicates}")

        # Store details for overall summary
        summary_details[vul] = {
            "original_csv": original_count,
            "deduplicated_csv": deduplicated_count,
        }

        # Update overall totals for CSVs
        total_original_csv += original_count
        total_deduplicated_csv += deduplicated_count

    # Calculate total file counts for Etherscan and Solidity folders (no subfolders)
    total_etherscan_files = count_files_in_directory("Etherscan")
    total_solidity_files = count_files_in_directory("Solidity")

    print("\n\n--- Overall Dataset Summary ---")
    print("-" * 30)
    print(f"Total Original CSV Rows Across All Vulnerabilities: {total_original_csv}")
    print(
        f"Total Deduplicated CSV Rows Across All Vulnerabilities: {total_deduplicated_csv}"
    )
    print(
        f"Total Duplicates Removed Across All CSVs: {total_original_csv - total_deduplicated_csv}"
    )
    print(f"Total Etherscan Files Collected (Overall): {total_etherscan_files}")
    print(
        f"Total Solidity Files Extracted (Compilable, Overall): {total_solidity_files}"
    )
    print("-" * 30)

    # New section: Find addresses missing in Etherscan
    print("\n\n--- Missing Etherscan Addresses ---")
    print("-" * 30)
    csv_addresses = get_addresses_from_csvs(vulnerabilities)
    etherscan_file_addresses = get_addresses_from_etherscan_files()

    missing_etherscan_addresses = csv_addresses - etherscan_file_addresses

    if missing_etherscan_addresses:
        print(
            f"Found {len(missing_etherscan_addresses)} addresses in CSVs but not in Etherscan files:"
        )
        for address in sorted(list(missing_etherscan_addresses)):
            print(f"  - {address}")
    else:
        print(
            "All addresses in deduplicated CSVs are present as files in the Etherscan folder."
        )
    print("-" * 30)

    plot()


if __name__ == "__main__":
    main()



"""
--- Detailed Vulnerability Summary (CSV Data) ---
--------------------------------------------------

Vulnerability: Reentrancy
-------------------------
  CSV Data (original vs removed duplicates):
    Original count: 218
    Deduplicated count: 188
    Duplicates removed: 30

Vulnerability: Suicide
----------------------
  CSV Data (original vs removed duplicates):
    Original count: 372
    Deduplicated count: 363
    Duplicates removed: 9

Vulnerability: IntergerOU
-------------------------
  CSV Data (original vs removed duplicates):
    Original count: 168
    Deduplicated count: 166
    Duplicates removed: 2


--- Overall Dataset Summary ---
------------------------------
Total Original CSV Rows Across All Vulnerabilities: 758
Total Deduplicated CSV Rows Across All Vulnerabilities: 717
Total Duplicates Removed Across All CSVs: 41
Total Etherscan Files Collected (Overall): 716
Total Solidity Files Extracted (Compilable, Overall): 653
------------------------------


--- Missing Etherscan Addresses ---
------------------------------
Found 1 addresses in CSVs but not in Etherscan files:
  - 0x59752433dbe28f5aa59b479958689d353b3dee08
------------------------------

=== Reentrancy ===
Safe contracts (label=0):      90
Vulnerable contracts (label=1): 95

=== Suicide ===
Safe contracts (label=0):      89
Vulnerable contracts (label=1): 220

=== IntergerOU ===
Safe contracts (label=0):      96
Vulnerable contracts (label=1): 63

"""
