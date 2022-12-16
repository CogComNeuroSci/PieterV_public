#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 13:56:14 2019

@author: pieter
"""

import pandas as pd
import os
import numpy as np

pplist=np.arange(1,31)
print(pplist)
#pplist=np.delete(pplist,[3,4,16,18,20,21,27,34])

column_list = ["Rule", "Stimulus", "Response", "CorrResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
os.chdir("/Users/pieter/Desktop/ModelRecoveryExplore/Raw_data/Huycke")
filename = "theta_alpha_beta_behavioural.csv"
data = pd.read_csv(filename, sep=',',encoding='utf-8')
pplist = np.unique(data['Subject_nr'])

x = 0
for p in pplist:
    print(p)
    x +=1

    d = data[data['Subject_nr']==p]

    trial_id = np.arange((np.shape(d)[0]))

    Rew=(d['Accuracy_int'].values)

    Rule=np.zeros((np.shape(d)[0]))

    Stim=d['Stimulus_ID'].values

    Resp=d['Response'].values
    Resp[Resp == 'Left'] = 1
    Resp[Resp == 'Right'] = 0

    CorrResp = np.zeros((np.shape(d)[0]))
    CorrResp[Rew == 1] = Resp[Rew == 1]
    CorrResp[Rew == 0] = (Resp[Rew == 0]-1)* -1

    Corr = Rew

    FB = np.ones((np.shape(d)[0]))

    new_filename='Data_subject_{0}.csv'.format(int(x))
    os.chdir("/Users/pieter/Desktop/ModelRecoveryExplore/Data_to_fit/Huycke")
    new_data=pd.DataFrame({"Rule":Rule, 'Stimulus':Stim, 'Response':Resp, "CorrResp":CorrResp, "FBcon": FB,'Reward':Rew,'Expected value':np.zeros((len(trial_id))), 'PE estimate_low':np.zeros((len(trial_id))), 'PE estimate_high':np.zeros((len(trial_id))),"Response_Likelihood": np.zeros((len(trial_id))), "Module": np.zeros((len(trial_id)))}, columns = column_list)
    new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
