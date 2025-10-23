#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Tamer Abdelaziz

"""

import json
import os

import requests


def get_contract_runtime_code(api_key, contract_address):
    """
    Fetch the runtime bytecode of a smart contract from Etherscan.

    :param api_key: Your Etherscan API key.
    :param contract_address: The Ethereum address of the smart contract.
    :return: The runtime bytecode as a string, or an error message.
    """
    base_url = "https://api.etherscan.io/api"
    params = {
        "module": "proxy",
        "action": "eth_getCode",
        "address": contract_address,
        "tag": "latest",
        "apikey": api_key,
    }

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        data = response.json()

        # Check for the result key
        if "result" in data:
            return data["result"]
        else:
            return f"Error: Unexpected response format. Response: {data}"
    except requests.exceptions.RequestException as e:
        return f"Request failed: {str(e)}"


def save_to_file(filename, data):
    """
    Save data to a file on disk.

    :param filename: The name of the file to save the data to.
    :param data: The data to write to the file.
    """
    try:
        with open(filename, "w") as file:
            file.write(data)
        # print(f"Runtime code saved to {filename}")
    except Exception as e:
        print(f"Failed to write to file: {e}")


etherscan_api_key = "PTIR3VR214N7JZPM35IYMABH2BBKRSXE8S"

path = "Smartbugs-unchecked-exceptions/"


def load_json(filepath):
    with open(filepath, "r") as f:
        return json.load(f)


def uncheckedExceptions():
    Ex1 = 0
    Ex2 = 0

    Dir = path + "contract_code/unchecked-exceptions/"
    if not os.path.exists(Dir):
        os.makedirs(Dir)

    files_list = [
        file[:-4]
        for _, _, files in os.walk(path + "unchecked_low_level_calls/")
        for file in files
        if file.endswith(".sol")
    ]
    print(files_list)

    for ct in files_list:
        try:
            # print(ct)
            runtime_code = get_contract_runtime_code(etherscan_api_key, ct)
            # print(f"Runtime Code:\n{runtime_code}")
            if runtime_code.startswith("0x") and len(runtime_code) > 2:
                filename = Dir + ct + ".rt.hex"
                save_to_file(filename, runtime_code[2:])
            else:
                print(f"Error: {ct}")
                Ex1 += 1

        except:
            print(f"Error: unable to get runtime code")
            Ex2 += 1

    print(Ex1, Ex2)


if __name__ == "__main__":
    uncheckedExceptions()

    # 47 contracts
    # ./smartbugs/smartbugs -t all -f Smartbugs-unchecked-exceptions/contract_code/unchecked-exceptions/*.rt.hex --runtime --runid Smartbugs_unchecked-exceptions --processes 12 --mem-limit 96g --timeout 600
