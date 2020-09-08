#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 25 11:17:01 2019

@author: pieter
"""
import numpy as np
import pandas as pd

def logit(beta_in,x1,x2):
    return np.exp(x1/beta_in)/(np.exp(x1/beta_in)+np.exp(x2/beta_in))

# generate data for the learning model
def simulate_data( alpha = 0.8, beta = 0.8, file_name = "sim_data.csv"):
    # initialize
    nstim=2
    nresp=2
    data = pd.read_csv(file_name)  
    ntrials = data.shape[0]
    value = np.random.random((nstim,nresp))
    column_list = ["Rule", "Stimulus", "Response", "Reward", "Expected value", "PE_estimate","Response_likelihood","value_difference"]
    estimated_data= pd.DataFrame(columns=column_list)
    LogLik=0
    # simulate data
    for loop in range(ntrials):
        # choose 1 stimulus out of nstim
        stim_act=np.zeros(nstim)                #Initialize stimulus activation matrix
        stim=int(data.iloc[loop,2])           #get stimulus from data
        stim_act[stim]=1                        #Activate the stimulus node
        
        rule=int(data.iloc[loop,1]) 
        
        #Compute activation of response nodes
        resp_act= np.matmul(stim_act,value) 
        #Softmax decision
        resp = int(data.iloc[loop,3]) #int(random.random()>p0)
        
        p0 = logit(beta,resp_act[resp],resp_act[resp-1])
        LogLik=LogLik+np.log(p0)

        Reward=int(data.iloc[loop,4]) 
        #Compute prediction error
        PE_estimate= Reward-value[stim,resp]
        
        #Write away data
        estimated_data.loc[loop] = [rule, stim, resp, Reward, value[stim,resp], PE_estimate, p0, value[stim,resp]-value[stim,resp-1]]
        
        #Compute new values/weights
        value[stim,resp] = value[stim,resp] + alpha*(Reward-resp_act[resp])# Rescorla-Wagner update 

    # write data to file
    estimated_data.to_csv(file_name, columns = column_list, float_format ='%.3f')
    return LogLik
