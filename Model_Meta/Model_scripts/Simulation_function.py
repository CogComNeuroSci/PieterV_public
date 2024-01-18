#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd

def softmax(temp,r1, r2):
    return np.exp(r1/temp)/(np.exp(r1/temp)+np.exp(r2/temp))

# generate data for the learning model
# For RW model: hybrid, cumul and hlr should be zero
# For simulations, fit = False
def simulate_data( lr = 0.8, temp = 0.4, hybrid = 0, cumul = 0, hlr = 0, threshold = .49, file_name = "Data_subject_3.csv", folder ="/Users/pieter/Desktop/Model_study/Designs/", simnr=1, sub = 5, fit = False, nstim = 2):

    #Initialize parameters
    nresp=2                                         #Number of responses
    nrule=2                                         #Number of rules

    data = pd.read_csv(file_name)                   #Reading in design
    ntrials = data.shape[0]                         #Number of trials
    Weights = np.ones((nrule,nstim,nresp))*0.5      #Initialize weights
    Value = np.ones((nrule))/nresp                  #Initialize module/rule set values

    #Load in simulated data file
    if fit:
        if sub>9:
            new_filename = folder + file_name[-19:-4]+ "_" + str(simnr) + ".csv"
        elif sub > 99:
            new_filename = folder + file_name[-21:-4]+ "_" + str(simnr) + ".csv"
        else:
            new_filename = folder + file_name[-18:-4]+ "_" + str(simnr) + ".csv"
    else:
        new_filename = folder + "Data_subject_" + str(sub) + "_" + str(simnr) + ".csv" #file_name[0:-4] + "_Simulation" + str(simnr)+ ".csv"

    column_list = ["Rule", "Stimulus", "Response", "CorResp", "FBcon", "Reward", "Expected value", "PE_estimate_low", "PE_estimate_high","Response_likelihood","Module"]
    simulated_data = pd.DataFrame(columns=column_list)

    module = 0                                      #Initialize module/ rule set
    Switch_neuron = 0                               #Initialize switch neuron
    cumulated_reward = 0                            #Initialize cumulated reward

    # simulate data
    for loop in range(ntrials):

        if loop == 0:
            learning_rate = lr

        # choose 1 stimulus out of nstim
        stim_act=np.zeros(nstim)                #Initialize stimulus activation matrix
        stim=int(data.iloc[loop,2])             #get stimulus from data
        stim_act[stim]=1                        #Activate the stimulus node

        rule=int(data.iloc[loop,1])             #get rule from data

        #Compute activation of response nodes
        resp_act= np.matmul(stim_act,Weights[module,:,:]) # get response activation

        #Softmax decision
        if fit:
            resp = int(data.iloc[loop,3])
            p0 = softmax(temp,resp_act[resp],resp_act[resp-1])
            Accuracy = (resp == data.iloc[loop,4])*1
            Reward = int(data.iloc[loop,6])
        else:
            p0 = softmax(temp,resp_act[0],resp_act[1])  #get probability for response 0
            resp = int(np.random.random() > p0)         #If that probability is smaller than a random number we give response 1 else, we give response 0
            #Define feedback
            Accuracy = (resp == data.iloc[loop,4])*1    #Accuracy is based on the correct response which i get from data
            if data.iloc[loop,5] == Accuracy:           #Reward is determined by your accuracy and whether feedback is congruent with your accuracy
                Reward = 1
            else:
                Reward = 0

        # Keep track of cumulated reward
        cumulated_reward += Reward*10

        #Compute prediction error
        PE_high = Reward - Value[module]
        PE_low = Reward - resp_act[resp]

        #Write away data
        simulated_data.loc[loop] = [rule, stim, resp, data.iloc[loop,4], data.iloc[loop,5], Reward, resp_act[resp], PE_low, PE_high, p0, module]

        #Update weights, module values and learning rate
        Weights[module,stim,resp] = Weights[module,stim,resp] + learning_rate * PE_low

        #Adapting the learning rate
        learning_rate = hybrid * abs(PE_low) + (1 - hybrid) * learning_rate

        #Value of rule sets/ module
        Value[module]=Value[module]+ hlr * Value[module] * PE_high

        #Cumulate errors to decide when to switch
        PE_cumul = np.maximum(0, -PE_high)
        Switch_neuron = cumul * PE_cumul + (1-cumul) * Switch_neuron

        #switching
        if Switch_neuron>threshold:
            module=(module-1)**2
            Switch_neuron = 0

    # write data to file
    simulated_data.to_csv(new_filename, columns = column_list, float_format ='%.3f')
    return cumulated_reward
