#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar  8 14:15:08 2018

@author: pieter
"""

import numpy as np
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
iterations=5                    # number of iterations in negative phase
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
for b in range(10,11):          #gradual change of beta 
    for r in range(1):          #replication loop

        # model initialization
        #processing module
        #positive phase
        Rate_Input_plus=np.zeros((nStim,Tr))                    #rate neurons
        
        Rate_M1_plus=np.zeros((nM1,Tr))                         #rate neurons        
        
        Rate_Out_plus=np.zeros((nResp,Tr))                      #rate neurons
        
        #net inputs
        net_M1_plus=np.zeros((nM1,Tr))
        
        #negative phase
        Rate_Input_min=np.zeros((nStim,Tr,iterations))       #rate neurons
        
        Rate_M1_min=np.zeros((nM1,Tr,iterations))            #rate neurons         
        
        Rate_Out_min=np.zeros((nResp,Tr,iterations))         #rate neurons
        
        #net inputs
        net_M1_min=np.zeros((nM1,Tr,iterations))
        net_Out_min=np.zeros((nResp,Tr,iterations))
        
        #binarizations
        bin_M1=np.zeros((nM1,Tr,iterations))
        
        #weights
        W_IM1=np.zeros((nStim,nM1,Tr+1))
        W_M1O=np.zeros((nM1,nResp,Tr+1))
        #initial (random) weigth strengths
        W_IM1[:,:,0]=np.random.random((nStim,nM1))*5 
        W_M1O[:,:,0]=np.random.random((nM1,nResp))*5 

        #learning
        Errorscore=np.zeros((nResp,Tr))                     #errorscore
        delta_M1out=np.zeros((nM1,nResp,Tr))                #delta hidden to output layer
        delta_M1=np.zeros((nStim,nM1,Tr));                  #delta input to hidden layer M1
        
        # Input
        #randomization of input patterns
        In=np.tile(range(nInput),(3,POT_1))
        Input=np.zeros((1,Tr))
        Input[0,part1]=In[0,np.random.permutation(POT_1)]
        Input[0,part2]=In[1,np.random.permutation(POT_1)]
        Input[0,part3]=In[2,np.random.permutation(POT_1)]
        
        #recordings
        Z=np.zeros((nStim,Tr))                              #input matrix
        Q=np.zeros((nResp,Tr))
        Q_min=np.zeros((nResp,Tr,iterations+1))
        response=np.zeros((nResp,Tr,iterations))           #response record 
        rew=np.zeros((1,Tr))                               #reward
        
        # the model

        for trial in range(Tr):            #trial loop
    
            #input and output
            Z[:,trial]=Activation[:,int(Input[0,trial])]
            Q[:,trial]=objective[:,int(Input[0,trial]),trial]
                        
            #updating rate code units
            Rate_Input_plus[:,trial]=Z[:,trial] 
                
            Rate_Out_plus[:,trial]=Q[:,trial]
                
            net_M1_plus[:,trial]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input_plus[:,trial])+np.matmul(W_M1O[:,:,trial],Rate_Out_plus[:,trial])-bias
            Rate_M1_plus[:,trial]=1/(1+np.exp(-net_M1_plus[:,trial]))
            
            #negative phase
            for i in range(iterations):
                #from input and output to hidden layer
                #updating rate code units
                Rate_Input_min[:,trial,i]=Z[:,trial]
                
                net_M1_min[:,trial,i]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input_min[:,trial,i])+np.matmul(W_M1O[:,:,trial],Q_min[:,trial,i])-bias
                Rate_M1_min[:,trial,i]=1/(1+np.exp(-net_M1_min[:,trial,i])) 
                
                #binarization of hidden layer activation
                bin_M1[:,trial,i]=(Rate_M1_min[:,trial,i]>np.random.random()).astype(int)
            
                #from hidden back to output
                net_Out_min[:,trial,i]=np.matmul(np.transpose(W_M1O[:,:,trial]),bin_M1[:,trial,i]) -bias
                Rate_Out_min[:,trial,i]=1/(1+np.exp(-net_Out_min[:,trial,i]))
            
                #response determination
                if Rate_Out_min[0,trial,i]>Rate_Out_min[1,trial,i]:
                    response[0,trial,i]=1
                else:
                    response[1,trial,i]=1
            
                Q_min[:,trial,i+1]=response[:,trial,i]

            #reward value determination
            if np.all(response[:,trial,i]==Q[:,trial]):
                rew[0,trial]=1
            else:
                rew[0,trial]=0 
            
            #Weight updating
            #compute general errorscore at each output unit
            Errorscore[:,trial]=(objective[:,int(Input[0,trial]),trial]-(Rate_Out_min[:,trial,i-1]))**2
            #compute delta_output
            delta_M1out[:,:,trial]=np.matmul(Rate_M1_plus[:,trial][:,None],Rate_Out_plus[:,trial][None,:])-np.matmul(Rate_M1_min[:,trial,i][:,None],Rate_Out_min[:,trial,i-1][None,:])
            #update weights from hidden M1 to output layer
            W_M1O[:,:,trial+1]=W_M1O[:,:,trial] + Beta[b]* delta_M1out[:,:,trial] 
            #compute delta hidden layer M1
            delta_M1[:,:,trial]=np.matmul(Rate_Input_plus[:,trial][:,None],Rate_M1_plus[:,trial][None,:])- np.matmul(Rate_Input_min[:,trial,i][:,None],Rate_M1_min[:,trial,i][None,:])
            #update weights from input to hidden layer M1
            W_IM1[:,:,trial+1]=W_IM1[:,:,trial]+ Beta[b] * delta_M1[:,:,trial]

            print(trial) 
         
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

        data_pickle = "Beta"+str(b)+"_Rep"+str(r)+"_RBM_nosync.p"

        variables_str = ["binned_Errorscore","binned_accuracy"]
        variables =     [binned_Errorscore, binned_accuracy]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)