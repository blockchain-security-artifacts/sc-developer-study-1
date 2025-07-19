#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: CryptoX

"""

import os
import json
import re
import subprocess


def remove_comments(code):
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.DOTALL)
    code = re.sub(r"//.*", "", code)
    return code.strip()


def extract_source_code(source_code_field):
    try:
        parsed = json.loads(source_code_field)
        if isinstance(parsed, dict):
            sources = parsed.get("sources", parsed)
            combined_code = ""
            for key, value in sources.items():
                if isinstance(value, dict) and "content" in value:
                    combined_code += value["content"] + "\n"
                elif isinstance(value, str):
                    combined_code += value + "\n"
            return combined_code
    except Exception:
        return source_code_field
    return ""


def switch_solc_version(version):
    try:
        subprocess.run(
            ["solc-select", "use", version],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except subprocess.CalledProcessError:
        print(
            f"❌ solc version {version} not available. Install it using: solc-select install {version}"
        )
        return False


def is_compilable(solidity_file, log_path=None):
    try:
        result = subprocess.run(
            ["solc", "--ast-compact-json", solidity_file],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=15,
        )
        if result.returncode == 0:
            return True
        else:
            print(f"❌ Compilation error in {solidity_file}")
            if log_path:
                with open(log_path, "a", encoding="utf-8") as log_file:
                    log_file.write(f"=== {solidity_file} ===\n")
                    log_file.write(result.stderr + "\n\n")
            return False
    except Exception as e:
        print(f"❌ Exception during compilation: {solidity_file} -> {e}")
        if log_path:
            with open(log_path, "a", encoding="utf-8") as log_file:
                log_file.write(f"=== {solidity_file} ===\n")
                log_file.write(str(e) + "\n\n")
        return False


def process_json_file(json_path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)
        if "result" not in data or not data["result"]:
            return None, None
        source_code_field = data["result"][0].get("SourceCode", "")
        compiler_field = data["result"][0].get("CompilerVersion", "")

        code = extract_source_code(source_code_field)
        clean_code = remove_comments(code)

        # Extract version from string like "v0.4.21+commit.dfe3193c"
        version_match = re.search(r"(\d+\.\d+\.\d+)", compiler_field)
        version = version_match.group(1) if version_match else None

        # Insert pragma if missing
        if version and not re.search(r"pragma\s+solidity\s+", clean_code):
            pragma_line = f"pragma solidity ^{version};\n\n"
            clean_code = pragma_line + clean_code

        return clean_code, version


def process_all_files(input_folder, output_folder, log_file="compile_errors.txt"):
    os.makedirs(output_folder, exist_ok=True)
    if os.path.exists(log_file):
        os.remove(log_file)

    for filename in os.listdir(input_folder):
        if filename.endswith(".json"):
            input_path = os.path.join(input_folder, filename)
            cleaned_code, version = process_json_file(input_path)

            if cleaned_code:
                output_filename = os.path.splitext(filename)[0] + ".sol"
                output_path = os.path.join(output_folder, output_filename)

                with open(output_path, "w", encoding="utf-8") as out_file:
                    out_file.write(cleaned_code)

                if version:
                    if not switch_solc_version(version):
                        print(
                            f"⚠️ Skipped {filename} due to missing solc version {version}"
                        )
                        os.remove(output_path)
                        continue

                if is_compilable(output_path, log_file):
                    print(f"✅ Compiled: {filename}")
                else:
                    print(f"❌ Failed to compile: {filename} — removing .sol file")
                    os.remove(output_path)
            else:
                print(f"⚠️ Skipped (no SourceCode): {filename}")


# ---------- Run it ---------- #
input_dir = "Etherscan"
output_dir = "Solidity"
process_all_files(input_dir, output_dir)
