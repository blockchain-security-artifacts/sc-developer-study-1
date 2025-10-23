#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Tamer Abdelaziz

"""

import pandas as pd


for tool in ["dlva", "dlvaL"]:

    attak_types = ["Reentrancy", "Suicide"]

    attak_types_map = {
        "Reentrancy": ["reentrancy-eth"],
        "Suicide": ["suicidal"],
    }

    for attack_type in attak_types:
        MLtool = pd.read_csv(
            "Tools_Labels/"
            + tool
            + "/DLVA_Predictions_for_"
            + attack_type
            + "_runtime-bytecode.csv"
        )
        print(MLtool)
        print(MLtool.columns.to_list())

        df_results = pd.read_csv("Tools_Labels/" + attack_type + "_labels.csv")
        print(df_results)

        tool_labels = []
        for index, row in df_results.iterrows():
            address = row["contract_address"].split("*")[-1].split(".")[0]
            #print(address)

            label = 0

            ML_1_address = MLtool[MLtool["address"] == address]
            # print(ML_1_address)

            if len(ML_1_address):
                for x in attak_types_map[attack_type]:
                    #print(x)
                    #print(ML_1_address[x].values[0])
                    if ML_1_address[x].values[0] == 1:
                        label = 1
            else:
                label = -1

            #print(label)
            tool_labels.append(label)

        # print(XAD_labels)
        df_results[tool] = tool_labels
        # print(df_results)
        df_results.to_csv("Tools_Labels/" + attack_type + "_labels.csv", index=False)

print("Done!")
