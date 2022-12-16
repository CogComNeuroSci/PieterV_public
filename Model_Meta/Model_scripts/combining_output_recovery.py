#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd

files = 36
Models = ["RW", "Error","ALR","ALR_Error","Learning","Full"]
for y in Models:
    result_folder = "/Users/pieter/Desktop/ModelRecoveryExplore/" + y + "_sims/"

    True_values = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "Points": []
        }

    RW_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    ALR_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    Error_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    ALRError_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    Learning_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    Full_estimations = {
        "Lr": [],
        "Temp": [],
        "Hybrid": [],
        "Cumul": [],
        "Hlr": [],
        "LogL": []
        }

    keylist = ["Lr", "Temp", "Hybrid", "Cumul", "Hlr"]
    for i in range(files):
        data = np.load(result_folder + "Recovery_data_{0}.npy".format(i), allow_pickle = True)
        dlen = len(data[()]["Performance"])

        for z in range(dlen):

            True_values["Points"].append(data[()]["Performance"][z])

            RW_estimations["LogL"].append(data[()]["RW_LogL"][z])
            Error_estimations["LogL"].append(data[()]["Error_LogL"][z])
            ALR_estimations["LogL"].append(data[()]["ALR_LogL"][z])
            ALRError_estimations["LogL"].append(data[()]["ALRError_LogL"][z])
            Learning_estimations["LogL"].append(data[()]["Learning_LogL"][z])
            Full_estimations["LogL"].append(data[()]["Full_LogL"][z])

            for j in range(len(keylist)):
                True_values[keylist[j]].append(data[()]["Real_pars"][z][j])
                RW_estimations[keylist[j]].append(data[()]["RW_Estpars"][z][j])
                Error_estimations[keylist[j]].append(data[()]["Error_Estpars"][z][j])
                ALR_estimations[keylist[j]].append(data[()]["ALR_Estpars"][z][j])
                ALRError_estimations[keylist[j]].append(data[()]["ALRError_Estpars"][z][j])
                Learning_estimations[keylist[j]].append(data[()]["Learning_Estpars"][z][j])
                Full_estimations[keylist[j]].append(data[()]["Full_Estpars"][z][j])


    if y == "RW":
        print(Learning_estimations["LogL"][216])

    df_true = pd.DataFrame.from_dict(True_values)
    df_RW = pd.DataFrame.from_dict(RW_estimations)
    df_Error = pd.DataFrame.from_dict(Error_estimations)
    df_ALR = pd.DataFrame.from_dict(ALR_estimations)
    df_ALRError = pd.DataFrame.from_dict(ALRError_estimations)
    df_Learning = pd.DataFrame.from_dict(Learning_estimations)
    df_Full = pd.DataFrame.from_dict(Full_estimations)

    df_true.to_csv(result_folder + "Truth_data.csv")
    df_RW.to_csv(result_folder + "RW_data.csv")
    df_Error.to_csv(result_folder + "Error_data.csv")
    df_ALR.to_csv(result_folder + "ALR_data.csv")
    df_ALRError.to_csv(result_folder + "ALRError_data.csv")
    df_Learning.to_csv(result_folder + "Learning_data.csv")
    df_Full.to_csv(result_folder + "Full_data.csv")
