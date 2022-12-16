#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  8 11:31:45 2022

@author: pieter
"""

import pandas as pd
import os
import numpy as np

#Columns of datafile
column_list = ["Rule", "Stimulus", "Response", "CorrResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
os.chdir("/Users/pieter/Desktop/Model_study/Optimize_models")

#Parameters for environments
structures = ["Stable", "Reversal", "Stepwise"]
rewards = [1, .7]
ntrials = 300
mean_switch = 30

for i in structures:
    for r in rewards:

        #randomize stimuli
        stim = np.tile(np.array([0,1]),int(ntrials/2))
        np.random.shuffle(stim)
        #Implement rule switches and noisy feedback for each environment
        if i =="Stable":
            rule = np.zeros((ntrials))
            fbcon = np.concatenate((np.ones((int(ntrials*r))), np.zeros((int(ntrials*(1-r))))))
            np.random.shuffle(fbcon)
        elif i =="Reversal":
            rule = np.tile(np.concatenate((np.zeros((mean_switch)), np.ones((mean_switch)))), int(ntrials/(mean_switch*2)))
            fbcon = np.concatenate((np.ones((int(ntrials*r))), np.zeros((int(ntrials*(1-r))))))
            np.random.shuffle(fbcon)
        else:
            ruleI = np.repeat(np.array([0,1]), int(ntrials/(mean_switch*2)))
            fbconI = np.tile(np.array([.9, .7,.5, .7, .9 ]), int(ntrials/(mean_switch*5)))
            design = np.column_stack((ruleI, fbconI))
            np.random.shuffle(design)

            #Here, the rule and feedback noise changes in each change
            rule = np.empty((ntrials))
            fbcon = np.empty((ntrials))
            for b in range(len(design)):
                rule[mean_switch*b:mean_switch*(b+1)] = np.repeat(design[b,0], mean_switch)
                fb = np.concatenate((np.ones((int(mean_switch*design[b,1]))), np.zeros((int(np.round(mean_switch*(1-design[b,1])))))))
                np.random.shuffle(fb)
                fbcon[mean_switch*b:mean_switch*(b+1)] = fb

        #Deduce correct response
        CorResp = np.empty((ntrials))
        for t in range(ntrials):
            if rule[t] == stim[t]:
                CorResp[t]= 0
            else:
                CorResp[t]=1

        #Store datafile
        new_filename='Data_{0}_{1}.csv'.format(i, r)
        new_data=pd.DataFrame({"Rule":rule, 'Stimulus':stim, 'Response':np.zeros((ntrials)), "CorrResp":CorResp, "FBcon": fbcon, "Reward":np.zeros((ntrials)),"Expected value":np.zeros((ntrials)), "PE estimate_low":np.zeros((ntrials)), "PE estimate_high":np.zeros((ntrials)),"Response_Likelihood": np.zeros((ntrials)), "Module": np.zeros((ntrials))}, columns = column_list)
        new_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
