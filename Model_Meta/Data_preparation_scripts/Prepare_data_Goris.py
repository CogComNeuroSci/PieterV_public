#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 13:56:14 2019

@author: pieter
"""

import pandas as pd
import os
import numpy as np

pplist=np.arange(1,190)
# The author informed us that these participants could be removed due to clinical scoring on questionnaires, data loss or bad performance
pplist=np.delete(pplist,[15, 17, 18, 22, 24, 34, 35, 36, 41, 46, 54, 57, 59, 62, 65, 68, 69, 70, 71, 72, 75, 79, 80, 84, 86, 90, 92, 93, 96, 97, 99, 109, 111, 112, 120, 125, 133, 135, 138, 140, 145, 149, 151, 161, 169, 186])
print(pplist)
column_list = ["Rule", "Stimulus", "Response", "CorResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
os.chdir("/Users/pieter/Desktop/Model_study/Raw_data/Goris")
write_folder = "/Users/pieter/Desktop/Model_study/Data_to_fit/Goris/"
start_stable = []
start_volatile = []
x=0
for p in pplist:
    x+=1
    filename = "S{0:02}.txt".format(p)

    data = pd.read_csv(filename, sep=" ",encoding='utf-8', header = None)

    trials = np.shape(data.values)[0]
    
    start_condition = data.values[0,0]
    print("subject {0}, started with condition {1}".format(p, start_condition))
    if start_condition==1:
        start_stable.append(x)
    if start_condition ==3:
        start_volatile.append(x)
        
        
    Rule=data.values[:,1]-1
    Stim=data.values[:,7]-1
    Resp=data.values[:,6]-1
    corr = data.values[:,10]
    CorResp = np.zeros((trials))
    CorResp[corr==1] =Resp[corr==1]
    CorResp[corr==0] =(Resp[corr==0]-1)*-1
    Rew=data.values[:,9]
    FB = (Rew == corr)*1

    new_data = pd.DataFrame({ 'Rule':Rule, 'Stimulus':Stim, 'Response':Resp, 'CorResp':CorResp, 'FBcon':FB, 'Reward':Rew, 'Expected value':np.zeros((trials)), 'PE estimate_low':np.zeros((trials)),  'PE estimate_high':np.zeros((trials)), "Response_likelihood": np.zeros((trials)), "Module":np.zeros((trials))}, columns = column_list)
    data_stat = new_data[:][data.values[:,0]==1]
    data_stat = data_stat[:][data_stat['Response']>-1]
    stat_filename= write_folder + "Stable/Data_subject_{0}.csv".format(int(x))
    data_stat.to_csv(stat_filename, columns = column_list, float_format ='%.3f')

    data_vol = new_data[:][data.values[:,0]==3]
    data_vol = data_vol[:][data_vol['Response']>-1]
    data_vol = data_vol[:][data_vol['Stimulus']<2]
    vol_filename= write_folder + "Volatile/Data_subject_{0}.csv".format(int(x))
    data_vol.to_csv(vol_filename, columns = column_list, float_format ='%.3f')

print(start_stable)
print(start_volatile)




