#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: ...

"""

import json
import time
import requests

import pandas as pd


class etherscan:
    def __init__(self, apikey, network):
        self.network = network
        self.apikey = apikey
        if network == "mainnet":
            self.apipath = "https://api.etherscan.io/api?"
        else:
            self.apipath = "https://api" + "-" + network + ".etherscan.io/api?"

    def getCode(self, address):
        payload = {
            "module": "proxy",
            "action": "eth_getCode",
            "address": address,
            "tag": "latest",
            "apikey": self.apikey,
        }
        return requests.get(self.apipath, params=payload).json()["result"]

    def getSource(self, address):
        payload = {
            "module": "contract",
            "action": "getsourcecode",
            "address": address,
            "apikey": self.apikey,
        }
        return requests.get(self.apipath, params=payload).json()


def save_to_json(data, contract_address):
    with open("Etherscan/" + contract_address + ".json", "w") as f:
        json.dump(data, f, indent=4)
    print(f"Data saved to Etherscan/{contract_address}.json")


def load_from_json(contract_address):
    with open("Etherscan/" + contract_address + ".json", "r") as f:
        data = json.load(f)
    return data


def getSourceCode(address, etherscanapi):
    try:
        source = ""
        source = etherscanapi.getSource(address)

        # print(source)
        if source["status"] == "1" and source["result"][0]["SourceCode"] != "":
            # print("\nContractName:", source['result'][0]['ContractName'])
            # print("\nCompilerVersion:", source['result'][0]['CompilerVersion'])
            # print("\nABI:", source['result'][0]['ABI'])
            # print("\nSourceCode:", source['result'][0]['SourceCode'])

            # fc = open("Solidity/"+address+".sol", "w")
            # fc.write(source['result'][0]['SourceCode'])
            # fc.close()
            return source
        else:
            print("Source code is not available :(")
            return "NoSourceCode"
    except:
        return False


if __name__ == "__main__":

    etherscan_api_key = [
        etherscan("PTIR3VR214N7JZPM35IYMABH2BBKRSXE8S", "mainnet"),  # tamersoc
        etherscan("CGMUD48CAT3GUQVNJBWG1364S3TNMHWN83", "mainnet"),
        etherscan("C2UGGH8W5A3PR1A6JG1ZEAVQPEPK9MFEFN", "mainnet"),
        etherscan("TF3PUSR22C95AAMB6IZRXVISTX47J6XJSI", "mainnet"),  # tamerfcih
        etherscan("JYCHBPPBFTDXJKTZBKH1XUSM41E9TP7AMB", "mainnet"),
        etherscan("2TS4GH8YK78Q4442MG5IH2KEDN9EUK6669", "mainnet"),
        etherscan("YASQWSD87EWR22ACJS58SCVXMNGR99RT9S", "mainnet"),  # tamernus
        etherscan("62CHE31B2NE8ZJJQ1I339U5FWSK93TVKY7", "mainnet"),
        etherscan("9F46HZ4IA7BHWCZGMKJ66DNN8EA5CF53WD", "mainnet"),
    ]
    e_key_index = 0

    vulnerabilities = ["Reentrancy", "Suicide", "IntergerOU"]

    for vul in vulnerabilities:
        file_path_0 = f"Data/{vul}_0.csv"
        file_path = f"Data/{vul}.csv"

        df = pd.read_csv(file_path_0)

        df_cleaned = df.drop_duplicates(subset=["Address"], keep="first")

        df_cleaned = df_cleaned.sort_values(by="Address")

        df_cleaned.to_csv(file_path, index=False)

        print(
            f"{vul}: {len(df) - len(df_cleaned)} duplicates removed, sorted and saved."
        )

    for vul in vulnerabilities:

        file_path = f"Data/{vul}.csv"

        df = pd.read_csv(file_path)

        for index, row in df.iterrows():
            address = row["Address"]
            label = row["Label"]

            print("\n\n")

            print(index, "Vul:", vul, "Address:", address)

            print("keyIndex: ", e_key_index)

            contract_data = getSourceCode(address, etherscan_api_key[e_key_index])

            # print("change_etherscan_api_key")
            while not contract_data and e_key_index < len(etherscan_api_key) - 1:
                e_key_index += 1
                print("e_key_index", e_key_index)
                contract_data = getSourceCode(address, etherscan_api_key[e_key_index])

            # print(tx_features)
            if not contract_data and e_key_index == len(etherscan_api_key) - 1:
                print(
                    "Execution has been suspended Vul: "
                    + vul
                    + "\nAddress: "
                    + address
                    + "\nPlease check the Etherscan API keys as they have exceeded the daily limit."
                )
                print("Current time:", time.ctime(time.time()))
                print("Please wait for 1 minute to use the current Etherscan APIs ...")

                df.loc[len(df)] = row

                time.sleep(60)  # 60 seconds
                e_key_index = 0
                continue

            if contract_data and contract_data != "NoSourceCode":
                filename = vul + "*" + str(label) + "*" + address
                save_to_json(contract_data, filename)
                # loaded_data = load_from_json(filename)
                # print("Loaded Data:", json.dumps(loaded_data, indent=1))

                print()

        print("Done! with ", vul)
