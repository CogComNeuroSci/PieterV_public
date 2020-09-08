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
    nm=2
    data = pd.read_csv(file_name)   #Read data
    ntrials = data.shape[0]         #Number of trials

    logLik = 0      #Initialize loglikelihood
    Weights=np.random.random((nm,ns,nr))
    Value = np.ones((nm))*0.5
    module=data.iloc[0,1].astype(int)
    Switch_neuron=0
    PE_estimate=0
    
    for trial_loop in range(ntrials):
        stim=int(data.iloc[trial_loop,2])           #get stimulus from data
        stim_act=np.zeros(ns)                       #Initialize stimulus nodes
        stim_act[stim]=1                            #Activate stimulus nodes
        
        resp_act= np.matmul(stim_act,Weights[module,:,:])         #Compute response activation
        resp=int(data.iloc[trial_loop,3])           #get response from data
        
        #Update log likelihood
        logLik = logLik + (np.log( logit(parameter[4],resp_act[resp],resp_act[resp-1]) ) )
        
        Reward=data.iloc[trial_loop,4]
        
        PE_estimate=Reward- Value[module]
        PE_estimate_low=Reward- resp_act[resp]
        
        #Update weights/values
        Weights[module,stim,resp] = Weights[module,stim,resp] + parameter[1]*PE_estimate_low# Rescorla-Wagner update
        
        Value[module]=Value[module]+parameter[2]*Value[module]*PE_estimate
        
        if PE_estimate<0:
            Switch_neuron=parameter[0]*Switch_neuron-(1-parameter[0])*PE_estimate
        else:
            Switch_neuron=parameter[0]*Switch_neuron
        
        if Switch_neuron>parameter[3]:
            module=(module-1)**2        
        
    return -logLik
