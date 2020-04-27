#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 26 12:10:14 2019

@author: pieter
"""

import pandas as pd
import numpy as np

file_name ="sim_data.csv"

def logit(beta_in,x1, x2):
    return np.exp(x1/beta_in)/(np.exp(x1/beta_in)+np.exp(x2/beta_in))

# likelihood for the learning model
def logL(parameter, file_name):
    #initialize variables
    ns=2            #Number of stimuli
    nr=2            #Number of responses
    data = pd.read_csv(file_name)   #Read data
    ntrials = data.shape[0]         #Number of trials

    logLik = 0      #Initialize loglikelihood
    value = np.random.random((int(ns),int(nr)))     #Initialize random starting weights/values
    for trial_loop in range(ntrials):
        stim=int(data.iloc[trial_loop,2])           #get stimulus from data
        stim_act=np.zeros(ns)                       #Initialize stimulus nodes
        stim_act[stim]=1                            #Activate stimulus nodes
        
        resp_act= np.matmul(stim_act,value)         #Compute response activation
        resp=int(data.iloc[trial_loop,3])           #get response from data
        
        #Update log likelihood
        logLik = logLik + (np.log( logit(parameter[1],resp_act[resp],resp_act[resp-1]) ) )
        
        #Update weights/values
        value[stim,resp] = value[stim,resp] + (parameter[0]*(data.iloc[trial_loop,4]-resp_act[resp]) )
        
    return -logLik
