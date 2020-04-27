#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 13:56:14 2019

@author: pieter
"""

import pandas as pd
import os
import numpy as np

pplist=np.zeros((30))
pplist[0:8]=np.arange(3,11)
pplist[8]=12
pplist[9:31]=np.arange(14,35)



column_list = ["Rule", "Stimulus", "Response", "Reward", "Expected value", "PE_estimate"]

for p in pplist:
    os.chdir('/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Behavioral_data/Data')
    
    filename= "Probabilistic_Reversal_task_subject_{0}_Session_0_data.tsv".format(int(p))

    data = pd.read_csv(filename, sep='\t',encoding='utf-8')
    
    Rule=data.values[:,8]
    Stim=data.values[:,10]
    Resp=(data.values[:,11]=='f').astype(int)
    Rew=data.values[:,14]
    Rew[Rew==2]=0
    
    new_filename='Behavioral_data_subject_{0}_Hybrid.csv'.format(int(p))
    
    new_data=pd.DataFrame({ 'Rule':Rule, 'Stimulus':Stim, 'Response':Resp, 'Reward':Rew, 'Expected value':np.zeros((480)), 'PE estimate':np.zeros((480))}, columns = column_list)
    
    os.chdir('/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Hybrid_data')
    new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
    
    
