#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np

def softmax(temp,r1, r2):
    return np.exp(r1/temp)/(np.exp(r1/temp)+np.exp(r2/temp))

# Optimizing parameters for accumulated reward model
def Optim_rew(parameter, file_name, nstim):

    #Initialize variables
    ns=nstim                                #Number of stimuli
    nr=2                                    #Number of responses
    nm=2                                    #Number of modules
    data = pd.read_csv(file_name)           #Read data
    ntrials = data.shape[0]                 #Number of trials

    cumulated_reward = 0                    #Initialize cumulated reward
    Weights=np.ones((nm,ns,nr))*0.5         #Initialize weights
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

        resp_act = np.matmul(stim_act,Weights[module,:,:])      #Compute response activation
        p0 = softmax(parameter[1],resp_act[0],resp_act[1])      #get probability for response 0
        resp = int(np.random.random() > p0)                     #If that probability is smaller than a random number we give response 1 else, we give response 0

        accuracy = (resp ==data.iloc[trial_loop,4])*1 #Compute accuracy
        #Determine reward based on accuracy and feedback congruency
        if accuracy == data.iloc[trial_loop,5]:
            Reward = 1
        else:
            Reward = 0

        #Update cumulated reward
        cumulated_reward = cumulated_reward + Reward

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

    return -cumulated_reward
