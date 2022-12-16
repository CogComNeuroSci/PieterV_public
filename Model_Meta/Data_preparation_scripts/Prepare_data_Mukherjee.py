#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 13:56:14 2019

@author: pieter
"""

import pandas as pd
import os
import numpy as np

column_list = ["Rule", "Stimulus", "Response", "CorrResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
os.chdir("/Users/pieter/Desktop/Model_study/Raw_data/Mukherjee")
filename = "RL_MDD_All.csv"
data = pd.read_csv(filename, sep=',',encoding='utf-8')
print(np.unique(data['SubNum']))
print(np.unique(data['Group']))
print(np.unique(data['Condition']))
d = data[data["Group"]=="Healthy Controls"]
print(d["Group"])
print(d["SubNum"])
print(np.unique(d['SubNum']))
d2 = d[d["Condition"]=="Reward"]
print(np.unique(d2['SubNum']))
pplist = np.unique(d2['SubNum'])

x = 0
for p in pplist:
    print(p)
    x +=1

    d3 = d2[d2['SubNum']==p]

    trial_id = np.arange((np.shape(d3)[0]))
    print(len(trial_id))

    Rew=d3['Reward'].values
    print(len(Rew))

    Rule=d3['RichFrac'].values-1
    print(len(Rule))

    Stim=np.zeros(np.shape(d3)[0])
    print(len(Stim))

    Resp=d3['SubChoice'].values-1
    print(len(Resp))

    CorrResp = d3['RichFrac'].values-1
    print(len(CorrResp))

    Corr = d3['RichFracChoice'].values
    print(len(Corr))

    FB = (d3['RichFracChoice'].values == d3['Reward'].values)*1
    print(len(FB))

    new_filename='Data_subject_{0}.csv'.format(int(x))
    os.chdir("/Users/pieter/Desktop/Model_study/Data_to_fit/Mukherjee")
    new_data=pd.DataFrame({"Rule":Rule, 'Stimulus':Stim, 'Response':Resp, "CorrResp":CorrResp, "FBcon": FB,'Reward':Rew,'Expected value':np.zeros((len(trial_id))), 'PE estimate_low':np.zeros((len(trial_id))), 'PE estimate_high':np.zeros((len(trial_id))),"Response_Likelihood": np.zeros((len(trial_id))), "Module": np.zeros((len(trial_id)))}, columns = column_list)
    new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
