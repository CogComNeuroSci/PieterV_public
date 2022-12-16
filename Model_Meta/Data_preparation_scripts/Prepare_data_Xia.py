#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import os
import numpy as np

read_directory = "/Users/pieter/Desktop/ModelRecoveryExplore/Raw_data/Xia/"
write_directory = "/Users/pieter/Desktop/ModelRecoveryExplore/Data_to_fit/Xia/"

data = pd.read_csv(read_directory + "data_new.csv", sep=',',encoding='utf-8')
data = data[:][data["age"]>=18]

print(data.keys)
pplist = np.unique(data["subject"])
print(pplist)
column_list = ["Rule", "Stimulus", "Response", "CorResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]

x = 0

for p in pplist:
    x+=1
    d = data[:][data["subject"] == p]

    Rew=d['r'].values
    Rew[Rew ==-1]= 0

    Stim=d['s'].values -1

    Resp=d['a'].values -1
    Resp[Resp == -2] =0

    Corr = d['acc'].values

    CorrResp= np.zeros((120))
    for i in range(120):
        if Corr[i] == 1:
            CorrResp[i] = Resp[i]
        else:
            CorrResp[i] = (Resp[i] - 1)*-1

    FB = (Rew == Corr)*1

    new_filename='Data_subject_{0}.csv'.format(int(x))
    os.chdir("/Users/pieter/Desktop/ModelRecoveryExplore/Data_to_fit/Xia")

    new_data=pd.DataFrame({"Rule":np.zeros((120)), 'Stimulus':Stim, 'Response':Resp, "CorResp":CorrResp, "FBcon": FB,'Reward':Rew,'Expected value':np.zeros((120)), 'PE estimate_low':np.zeros((120)), 'PE estimate_high':np.zeros((120)),"Response_Likelihood": np.zeros((120)), "Module": np.zeros((120)),"Condition":np.repeat("Easy",120)}, columns = column_list)
    new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
