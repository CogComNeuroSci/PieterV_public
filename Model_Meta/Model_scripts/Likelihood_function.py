#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#Load modules
import pandas as pd
import numpy as np

#Softmax function for action selection
def softmax(temp,r1, r2):
    return np.exp(r1/temp)/(np.exp(r1/temp)+np.exp(r2/temp))

# likelihood for the learning model
def logL(parameter, file_name, nstim):

    #Initialize variables
    ns=nstim                                #Number of stimuli
    nr=2                                    #Number of responses
    nm=2                                    #Number of modules
    data = pd.read_csv(file_name)           #Read data
    ntrials = data.shape[0]                 #Number of trials

    logLik = 0                              #Initialize loglikelihood
    Weights=np.ones(nm,ns,nr)) * 0.5        #Initialize weights
    Value = np.ones((nm))/nr                #Initialize reward expectation
    module = 0                              #Initialize module
    Switch_neuron = 0                       #Initialize switch neuron
    PE_low = 0                              #Initialize lower prediction error
    PE_high = 0                             #Initialize higher prediction error

    #Loop over trials
    for trial_loop in range(ntrials):

        if trial_loop == 0:
            learning_rate = parameter[0]

        stim = int(data.iloc[trial_loop,2]) #Get stimulus from data
        stim_act = np.zeros(ns)             #Initialize stimulus nodes
        stim_act[stim] = 1                  #Activate stimulus nodes

        resp_act = np.matmul(stim_act,Weights[module,:,:])   #Compute response activation
        resp = int(data.iloc[trial_loop,3]) #Get response from data

        #Update log likelihood
        logLik = logLik + (np.log( softmax(parameter[1],resp_act[resp],resp_act[resp-1]) ) )

        Reward=data.iloc[trial_loop,6]  #Get reward from data

        PE_high=Reward - Value[module]  #Compute higher level prediction error
        PE_low=Reward - resp_act[resp]  #Compute lower level prediction error

        #Update weights, module values and learning rate
        Weights[module,stim,resp] = Weights[module,stim,resp] + learning_rate * PE_low

        #Adapt learning rate
        learning_rate = parameter[2] * abs(PE_low) + (1 - parameter[2]) * learning_rate

        #Value of rule sets/ module
        Value[module] = Value[module] + parameter[4] * Value[module] * PE_high

        #Cumulate errors to decide when to switch
        PE_cumul = np.maximum(0, -PE_high)
        Switch_neuron = parameter[3] * PE_cumul + (1-parameter[3]) * Switch_neuron

        #switching
        if Switch_neuron>parameter[5]:
            module=(module-1)**2
            Switch_neuron = 0

    return -logLik
