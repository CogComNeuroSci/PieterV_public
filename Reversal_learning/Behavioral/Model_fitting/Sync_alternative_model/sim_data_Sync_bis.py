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
def simulate_data( alpha = 0.2, beta = 0.7, lr=0.2, Threshold=0.5, explore=2.5, file_name = "sim_data.csv"):
    # initialize
    nstim=2
    nresp=2
    nrule=2
    data = pd.read_csv(file_name)
    ntrials = data.shape[0]
    Weights=np.random.random((nrule,nstim,nresp))
    Value = np.ones((nrule))*0.5
    column_list = ["Rule", "Stimulus", "Response", "Reward", "Expected value", "PE_estimate","Response_likelihood","Module","PE_low"]
    estimated_data= pd.DataFrame(columns=column_list)
    module =data.iloc[0,1].astype(int)
    Switch_neuron=0
    LogLik=0
    # simulate data
    for loop in range(ntrials):
        # choose 1 stimulus out of nstim
        stim_act=np.zeros(nstim)                #Initialize stimulus activation matrix
        stim=int(data.iloc[loop,2])             #get stimulus from data
        stim_act[stim]=1                        #Activate the stimulus node

        rule=int(data.iloc[loop,1])

        #Compute activation of response nodes
        resp_act= np.matmul(stim_act,Weights[module,:,:])

        #Softmax decision
        resp = int(data.iloc[loop,3]) #int(random.random()>p0)

        p0 = logit(explore,resp_act[resp],resp_act[resp-1])
        LogLik=LogLik+np.log(p0)

        Reward=int(data.iloc[loop,4])

        #Compute prediction error
        PE_estimate= Reward-Value[module]
        PE_estimate_low=Reward-resp_act[resp]

        #Write away data
        estimated_data.loc[loop] = [rule, stim, resp, Reward, Value[module], PE_estimate, p0, module, PE_estimate_low]

        #Compute new values/weights
        Weights[module,stim,resp] = Weights[module,stim,resp] + beta*PE_estimate_low# Rescorla-Wagner update

        Value[module]=Value[module]+lr*Value[module]*PE_estimate


        Switch_neuron=alpha*Switch_neuron-(1-alpha)*PE_estimate


        if Switch_neuron>Threshold:
            module=(module-1)**2

    # write data to file
    estimated_data.to_csv(file_name, columns = column_list, float_format ='%.3f')
    return LogLik
