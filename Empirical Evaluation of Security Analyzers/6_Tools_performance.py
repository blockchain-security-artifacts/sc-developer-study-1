#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: ...

"""

import pandas as pd
import numpy as np

import sklearn.metrics


df0 = pd.read_csv("Tools_Labels/results.csv")

attack_types = ["Reentrancy", "Suicide", "IntergerOU"]

for attack in attack_types:

    print(attack)

    df = pd.read_csv("Tools_Labels/" + attack + "_labels.csv")
    print(df)

    tools = df.columns.tolist()[2:]
    print(tools)

    addresses = df["contract_address"].values
    # print(addresses)

    tool_t = list()
    size_t = list()
    tp_t = list()
    fp_t = list()
    tn_t = list()
    fn_t = list()
    accuracy_t = list()
    precision_t = list()
    recall_t = list()
    f1_t = list()
    fnr_t = list()
    fpr_t = list()
    ex_to = list()
    ex = list()
    to = list()
    time_t = list()

    for tool in tools:

        y_pred = df[tool].values
        if np.isnan(y_pred).any():
            continue

        y_true = df["label"].values

        print("=" * 80)
        print(tool)

        print("-" * 80)

        df1 = df0[df0["toolid"] == tool]

        df2 = df1[df1["basename"].isin(addresses)]
        # print(df2)

        ti = np.sum(df2["duration"].values)

        print(f"\nInference is completed in {ti:0.4f} seconds")
        print(f"\nInference for one contract in {(ti)/len(y_true):0.4f} seconds")

        TimeOut = np.count_nonzero(df2["duration"].values > 900)
        print(f"\nTimeOut: {TimeOut}")

        Exceptions = np.sum(df2["fails"] != "{}") - TimeOut
        print(f"\nExceptions: {Exceptions}")

        print("-" * 80)
        accuracy = round(sklearn.metrics.accuracy_score(y_true, y_pred) * 100, 1)
        print("Accuracy score", accuracy)

        # Prediction Result
        print("-" * 80)
        print("confusion_matrix")
        print(pd.DataFrame(sklearn.metrics.confusion_matrix(y_true, y_pred)))

        print("-" * 80)
        print("classification_report (specificity,sensitivity,f1)")
        print(sklearn.metrics.classification_report(y_true, y_pred))

        print("-" * 80)

        # Compute confusion matrix
        tn, fp, fn, tp = sklearn.metrics.confusion_matrix(y_true, y_pred).ravel()

        print("\t tp:", tp)

        print("\t fn:", fn)

        print("\t fp:", fp)

        print("\t tn:", tn)

        print("-" * 80)

        # Calculate False Positive Rate and False Negative Rate
        fpr = round(fp / (fp + tn) * 100, 1)  # False Positive Rate: FP / (FP + TN)
        fnr = round(fn / (fn + tp) * 100, 1)  # False Negative Rate: FN / (FN + TP)

        precision = round(
            sklearn.metrics.precision_score(y_true, y_pred, average="weighted") * 100, 1
        )
        recall = round(
            sklearn.metrics.recall_score(y_true, y_pred, average="weighted") * 100, 1
        )
        f1 = round(
            sklearn.metrics.f1_score(y_true, y_pred, average="weighted") * 100, 1
        )

        print("\t Precision:", precision)
        print("\t Recall   :", recall)
        print("\t F1       :", f1)

        print("=" * 80)

        print("\t FNR (miss rate)  :", fnr)
        print("\t FPR (false alarm):", fpr)

        print("=" * 80)

        tool_t.append(tool)
        size_t.append(len(y_true))
        tp_t.append(tp)
        fp_t.append(fp)
        tn_t.append(tn)
        fn_t.append(fn)

        accuracy_t.append(accuracy)
        precision_t.append(precision)
        recall_t.append(recall)
        f1_t.append(f1)
        fnr_t.append(fnr)
        fpr_t.append(fpr)
        ex_to.append(str(round(Exceptions + TimeOut / len(y_true) * 100, 1)))
        ex.append(str(Exceptions))
        to.append(str(TimeOut))
        time_t.append(ti / len(y_true))

    outdf = pd.DataFrame(
        {
            "Tool": tool_t,
            "size_t": size_t,
            "tp_t": tp_t,
            "fp_t": fp_t,
            "tn_t": tn_t,
            "fn_t": fn_t,
            "accuracy_t": accuracy_t,
            "precision_t": precision_t,
            "recall_t": recall_t,
            "f1_t": f1_t,
            "fnr_t": fnr_t,
            "fpr_t": fpr_t,
            "ex_to": ex_to,
            "ex": ex,
            "to": to,
            "time": time_t,
        }
    )

    outdf = outdf.set_index("Tool")

    outdf.to_csv("Tools_Labels/" + attack + "_summary.csv")

print("=" * 80)
print("Done...!")
