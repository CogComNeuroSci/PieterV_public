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
os.chdir("/Users/pieter/Desktop/Model_study/Raw_data/Online")
directory = os.getcwd()
listdirectory = os.listdir(directory)
write_dir ="/Users/pieter/Desktop/Model_study/Data_to_fit/Online/"
code_id = np.where(np.array(listdirectory) == "Prepare_data.py")[0][0]
listdirectory.pop(code_id)

pplist = np.arange(len(listdirectory))
x=-1
for p in pplist:
    print(p)

    data = pd.read_csv(listdirectory[p], sep=',',encoding='utf-8')
    practice_data = data[data['Rule']<3]
    print(len(practice_data))
    data = data[data['Rule']>2]
    print(np.mean(data['Accuracy']))
    
    check_practice = len(practice_data)>80
    check_test = np.mean(data['Accuracy'])<.65
    
    if (check_practice + check_test)>0:
        print("Ignoring subject {}".format(p))
        continue
    x+=1
    trial_id = data["trial_index"].values-1
    Rew=data['Accuracy'].values
    Rule=data["Rule"].values-3
    Stim=data["Stimulus"].values
    Resp=np.zeros((len(trial_id)))
    
    for i in trial_id:
        Stim[i]=int(Stim[i][-1])%2
        if Rule[i]==1:
            if Rew[i] ==1:
                Resp[i]= Stim[i]
            else:
                Resp[i]= -1*(Stim[i]-1)
        else:
           if Rew[i] ==1:
               Resp[i]= -1*(Stim[i]-1) 
           else:
               Resp[i]= Stim[i]    

    CorrResp = np.zeros((len(trial_id)))
    CorrResp[Rew == 1] = Resp[Rew == 1]
    CorrResp[Rew == 0] = (Resp[Rew == 0]-1)* -1

    Corr = Rew

    FB = np.ones((len(trial_id)))

    new_filename='Data_subject_{0}.csv'.format(int(x))
    new_data=pd.DataFrame({"Rule":Rule, 'Stimulus':Stim, 'Response':Resp, "CorrResp":CorrResp, "FBcon": FB,'Reward':Rew,'Expected value':np.zeros((len(trial_id))), 'PE estimate_low':np.zeros((len(trial_id))), 'PE estimate_high':np.zeros((len(trial_id))),"Response_Likelihood": np.zeros((len(trial_id))), "Module": np.zeros((len(trial_id)))}, columns = column_list)
    new_data.to_csv(write_dir + new_filename, columns = column_list, float_format ='%.3f')
