#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  7 13:55:19 2018

@author: pieter
"""

import numpy as np
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
Tr=2400                         # amount of trials
betas=11                        # beta iterations
Beta=np.arange(0,1.1,0.1)       #learning rate values

# other variables
POT_1=Tr//3                     #point of switch to task rule 2 (trial 20)
POT_2=2*Tr//3                   #switch again to task rule 1    (trial 40)
part1=np.arange(POT_1)          #first part
part2=np.arange(POT_1,POT_2)    #second part
part3=np.arange(POT_2,Tr)       #third part

#model build-up
    #Processing module
nStim=6                         #number of input units
nM1=4                           #number of hidden units in module 1
nResp=2                         #number of response options
nInput=(nStim//3)**3            #number of Input patterns
bias=5                          #bias parameter

#Input patterns
Activation=np.zeros((nStim,nInput))
Activation[:,0]=[1,0,1,0,1,0]   #blue left circle
Activation[:,1]=[1,0,0,1,1,0]   #blue right circle
Activation[:,2]=[0,1,1,0,1,0]   #red left circle
Activation[:,3]=[0,1,0,1,1,0]   #red right circle
Activation[:,4]=[1,0,1,0,0,1]   #blue left square
Activation[:,5]=[1,0,0,1,0,1]   #blue right square
Activation[:,6]=[0,1,1,0,0,1]   #red left square
Activation[:,7]=[0,1,0,1,0,1]   #red right square

#learning objectives
objective=np.zeros((nResp,nInput,Tr)) 
objective[0,[[0],[1],[4],[6]],part1]=1
objective[1,[[2],[3],[5],[7]],part1]=1
objective[1,[[0],[1],[4],[6]],part2]=1
objective[0,[[2],[3],[5],[7]],part2]=1
objective[0,[[0],[1],[4],[6]],part3]=1
objective[1,[[2],[3],[5],[7]],part3]=1

# simulation loops
for b in range(betas):          #gradual change of beta 
    for r in range(Rep):          #replication loop

        # model initialization
        #processing module
        Rate_Input=np.zeros((nStim,Tr))       #Input rate neurons
        Rate_M1=np.zeros((nM1,Tr))            #Hidden rate neurons         
        Rate_Out=np.zeros((nResp,Tr))         #Output rate neurons
        
        net_M1=np.zeros((nM1,Tr))             #net input for the hidden neurons
        net_Out=np.zeros((nResp,Tr))          #net input for the output neurons
        
        #weights
        W_IM1=np.zeros((nStim,nM1,Tr+1))
        W_M1O=np.zeros((nM1,nResp,Tr+1))
        #initial (random) weigth strengths
        W_IM1[:,:,0]=np.random.random((nStim,nM1))*5  
        W_M1O[:,:,0]=np.random.random((nM1,nResp))*5
        
        #learning
        Errorscore=np.zeros((nResp,Tr))         #errorscore
        delta_out=np.zeros((nResp,Tr))          #delta hidden to output layer
        delta_M1=np.zeros((nM1,Tr));            #delta input to hidden layer M1
        
        # Input
        #randomization of input patterns
        In=np.tile(range(nInput),(3,POT_1))
        Input=np.zeros((1,Tr))
        Input[0,part1]=In[0,np.random.permutation(POT_1)]
        Input[0,part2]=In[1,np.random.permutation(POT_1)]
        Input[0,part3]=In[2,np.random.permutation(POT_1)]

        #recordings
        Z=np.zeros((nStim,Tr))                  #input matrix
        response=np.zeros((nResp,Tr))           #response record
        rew=np.zeros((1,Tr))                    #reward
        
        # the model

        for trial in range(Tr):            #trial loop
            
            #input
            Z[:,trial]=Activation[:,int(Input[0,trial])]
                        
            #updating rate code units
            Rate_Input[:,trial]=Z[:,trial] 
                
            net_M1[:,trial]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input[:,trial])-bias
            Rate_M1[:,trial]=(1/(1+np.exp(-net_M1[:,trial])))
                
            net_Out[:,trial]=np.matmul(np.transpose(W_M1O[:,:,trial]),Rate_M1[:,trial]) -bias
            Rate_Out[:,trial]=(1/(1+np.exp(-net_Out[:,trial])))
        
            #response determination
            if Rate_Out[0,trial]>Rate_Out[1,trial]:
                response[0,trial]=1
            else:
                response[1,trial]=1

            #reward value determination
            if np.all(response[:,trial]==objective[:,int(Input[0,trial]),trial]):
                rew[0,trial]=1
            else:
                rew[0,trial]=0 
            
            #Weight updating
            #compute general errorscore at each output unit
            Errorscore[:,trial]=(objective[:,int(Input[0,trial]),trial]-Rate_Out[:,trial])**2
            #compute delta_output
            delta_out[:,trial]=(objective[:,int(Input[0,trial]),trial]-Rate_Out[:,trial]) * Rate_Out[:,trial] * (1-Rate_Out[:,trial])
            #update weights from hidden M1 to output layer
            W_M1O[:,:,trial+1]=W_M1O[:,:,trial] + Beta[b]* (np.matmul(Rate_M1[:,trial][:,None], delta_out[:,trial][None,:])) 
            #compute delta hidden layer M1
            delta_M1[:,trial]=np.matmul(delta_out[:,trial][None,:],np.transpose(W_M1O[:,:,trial])) * Rate_M1[:,trial] * (1-Rate_M1[:,trial])
            #update weights from input to hidden layer M1
            W_IM1[:,:,trial+1]=W_IM1[:,:,trial]+ Beta[b] * np.matmul(Rate_Input[:,trial][:,None], delta_M1[:,trial][None,:])
            
            #print(trial)  
        nbins=20
        binned_Errorscore=np.zeros((1,nbins*3))
        binned_accuracy=np.zeros((1,nbins*3))
        bin_edges=np.zeros((1,(nbins*3)+1))
 
        bin_edges[0,range(nbins)]=np.arange(0,POT_1,POT_1//nbins)
        bin_edges[0,range(nbins,nbins*2)]=np.arange(POT_1,POT_2,POT_1//nbins)
        bin_edges[0,range(2*nbins,nbins*3+1)]=np.arange(POT_2,Tr+1,POT_1//nbins) 
  
        for bins in range(nbins*3):
            binned_Errorscore[0,bins]=np.mean(np.mean(Errorscore[:,range(int(bin_edges[0,bins]),int(bin_edges[0,bins+1]))],axis=1))
            binned_accuracy[0,bins]=np.mean(rew[0,range(int(bin_edges[0,bins]),int(bin_edges[0,bins+1]))])
      
        data_pickle = "Beta"+str(b)+"_Rep"+str(r)+"_backprop_nosync.p"

        variables_str = ["binned_Errorscore","binned_accuracy"]
        variables =     [binned_Errorscore, binned_accuracy]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)
    