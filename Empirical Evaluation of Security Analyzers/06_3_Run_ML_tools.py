#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: Tamer Abdelaziz


# https://www.usenix.org/system/files/usenixsecurity23-appendix-abdelaziz.pdf to install DLVA

"""

import pandas as pd
import os

os.system("mkdir ~/dlva")

attack_types = ["reentrancy", "suicide", "integer-overflow", "unchecked-exceptions"]

for attack in attack_types:
    df = pd.read_csv('Tools_Labels/'+attack+'_labels.csv')
    print(df)
    cts = [address.split('/')[-1][:-7] for address in df['contract_address'].values]
    #print(cts)
    df['address'] = cts
    bytecodes = []
    
    for address in df['contract_address'].values:
        with open(address, 'r') as file:
            bytecodes.append(file.read())
    
    
    
    df['bytecode'] = bytecodes
    dfout = df[['address','label','bytecode']]
    
    print(dfout)
    dfout.to_csv('~/dlva/'+attack+'_runtime-bytecode.csv', index=False)
    dfout.to_csv('Tools_Labels/'+attack+'_runtime-bytecode.csv', index=False)
    
print("Done!")


# DLVA SMALL

# mkdir Tools_Labels/dlva

# docker pull dlva/dlva:latest
# docker run -i -t -v ~/dlva/:/DLVA_Tool/dlva/ dlva/dlva

# For reentrancy           2 --> 2 --> ../dlva/reentrancy_runtime-bytecode.csv
# For suicide              2 --> 2 --> ../dlva/suicide_runtime-bytecode.csv
# For unchecked-exceptions 2 --> 2 --> ../dlva/unchecked-exceptions_runtime-bytecode.csv


# cp ~/dlva/DLVA_Predictions_for_reentrancy_runtime-bytecode.csv Tools_Labels/dlva/DLVA_Predictions_for_reentrancy_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_suicide_runtime-bytecode.csv Tools_Labels/dlva/DLVA_Predictions_for_suicide_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_unchecked-exceptions_runtime-bytecode.csv Tools_Labels/dlva/DLVA_Predictions_for_unchecked-exceptions_runtime-bytecode.csv

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

# For reentrancy           2 --> ../dlva/reentrancy_runtime-bytecode.csv
# For suicide              2 --> ../dlva/suicide_runtime-bytecode.csv
# For unchecked-exceptions 2 --> ../dlva/unchecked-exceptions_runtime-bytecode.csv


# cp ~/dlva/DLVA_Predictions_for_reentrancy_runtime-bytecode.csv Tools_Labels/dlvaL/DLVA_Predictions_for_reentrancy_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_suicide_runtime-bytecode.csv Tools_Labels/dlvaL/DLVA_Predictions_for_suicide_runtime-bytecode.csv
# cp ~/dlva/DLVA_Predictions_for_unchecked-exceptions_runtime-bytecode.csv Tools_Labels/dlvaL/DLVA_Predictions_for_unchecked-exceptions_runtime-bytecode.csv

"""
dlvaL_times = {
    "reentrancy": 96.81,
    "suicide": 185.06,
    "unchecked-exceptions": 69.89,
}
"""