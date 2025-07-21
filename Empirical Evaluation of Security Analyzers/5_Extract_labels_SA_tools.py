#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: ...

"""

import pandas as pd
import numpy as np
import csv

# Load the CSV file
file_path = "Tools_Labels/results.csv"
df = pd.read_csv(file_path)
print(df)

attack_types = ["Reentrancy", "Suicide", "IntergerOU"]

attack_cts = {}

for attack in attack_types:
    print(attack)
    v_cts = (df[df["basename"].str.contains(attack + "*")])["basename"].unique()

    print(len(v_cts))

    attack_cts[attack] = v_cts

# print(attack_cts['Reentrancy'], len(attack_cts['Reentrancy']))


unique_toolids = [
    "confuzzius",
    # "conkas",
    ## "honeybadger",
    # "maian",
    ## "manticore-0.3.7",
    "mythril-0.24.7",
    "osiris",
    "oyente",
    # "securify",
    # "semgrep",
    # "sfuzz",
    "slither-0.10.4",
    # "smartcheck",
    # "solhint-3.3.8",
]

tool_attck_map_All = {
    "confuzzius": set(),
    "conkas": set(),
    "maian": set(),
    "mythril-0.24.7": set(),
    "osiris": set(),
    "oyente": set(),
    "securify": set(),
    "sfuzz": set(),
    "slither-0.10.4": set(),
    "smartcheck": set(),
    "solhint-3.3.8": set(),
}


for attack in attack_types:

    if attack == "Reentrancy":
        tool_attck_map = {
            "confuzzius": ["Reentrancy"],
            "conkas": ["Reentrancy"],
            "maian": [],
            "mythril-0.24.7": [
                "State_access_after_external_call_SWC_107",
                "External_Call_To_User_Supplied_Address_SWC_107",
            ],
            "osiris": ["Reentrancy_bug"],
            "oyente": ["Re_Entrancy_Vulnerability"],
            "securify": ["DAO"],
            "sfuzz": ["Reentrancy"],
            "slither-0.10.4": ["reentrancy_eth"],
            "smartcheck": ["SOLIDITY_CALL_WITHOUT_DATA"],
            "solhint-3.3.8": ["reentrancy"],
        }

    elif attack == "Suicide":
        tool_attck_map = {
            "confuzzius": ["Unprotected_Selfdestruct"],
            "conkas": [],
            "maian": ["Destructible", "Destructible_verified"],
            "mythril-0.24.7": ["Unprotected_Selfdestruct_SWC_106"],
            "osiris": [],
            "oyente": [],
            "securify": [],
            "sfuzz": [],
            "slither-0.10.4": ["suicidal"],
            "smartcheck": [],
            "solhint-3.3.8": [],  # avoid-suicide
        }

    elif attack == "IntergerOU":
        tool_attck_map = {
            "confuzzius": ["Integer_Overflow"],
            "conkas": ["Integer_Underflow", "Integer_Overflow"],
            "maian": [],
            "mythril-0.24.7": ["Integer_Arithmetic_Bugs_SWC_101"],
            "osiris": ["Underflow_bugs", "Overflow_bugs"],
            "oyente": ["Integer_Overflow", "Integer_Underflow"],
            "securify": [],
            "sfuzz": ["Integer_Underflow", "Integer_Overflow"],
            "slither-0.10.4": [],
            "smartcheck": ["SOLIDITY_UINT_CANT_BE_NEGATIVE"],
            "solhint-3.3.8": [],
        }

    # Filter the DataFrame
    filtered_data = df[df["basename"].isin(attack_cts[attack])]

    # print(filtered_data)
    # print(unique_toolids)

    addresses = attack_cts[attack]
    # print(addresses)
    # print(len(addresses))

    with open("Tools_Labels/" + attack + "_labels.csv", mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["contract_address", "label"] + unique_toolids)

        for address in addresses:
            data_for_1_address = filtered_data[filtered_data["basename"] == address]
            print(data_for_1_address)

            contract_tools_labels = [address]

            if "*0*" in address:
                contract_tools_labels.append("0")  # ground truth
            elif "*1*" in address:
                contract_tools_labels.append("1")  # ground truth
            else:
                contract_tools_labels.append("Unknown")  # ground truth

            for toolid in unique_toolids:
                label = "NA"
                data_for_1_address_1_tool = data_for_1_address[
                    data_for_1_address["toolid"] == toolid
                ]
                if len(data_for_1_address_1_tool["findings"].values):
                    findings = (
                        data_for_1_address_1_tool["findings"].values[0][1:-1].split(",")
                    )
                else:
                    findings = [""]
                print(toolid)
                print(tool_attck_map[toolid])
                print(findings)

                if len(tool_attck_map[toolid]):
                    for t_a in tool_attck_map[toolid]:
                        if t_a in findings:
                            label = "1"
                        else:
                            label = "0"
                print(label)
                contract_tools_labels.append(label)

                for fg in findings:
                    tool_attck_map_All[toolid].add(fg)

            print(contract_tools_labels)

            writer.writerow(contract_tools_labels)


print("=" * 80)
for toolid in unique_toolids:
    print()
    print(toolid)
    print()
    print(tool_attck_map_All[toolid])
    print("-" * 80)
