#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  5 13:57:31 2018

@author: pieter
"""
import numpy as np
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
Tr=240                          # amount of trials
betas=11                        # beta iterations
Beta=np.arange(0,1.1,0.1)       #learning rate values

# other variables
POT_1=Tr//3                     #point of switch to task rule 2 (trial 20)
POT_2=2*Tr//3                   #switch again to task rule 1    (trial 40)
part1=np.arange(POT_1)          #first part
part2=np.arange(POT_1,POT_2)    #second part
part3=np.arange(POT_2,Tr)       #third part
nUnits=4                        #model units

#Input patterns
Activation=np.zeros((nUnits,2))
Activation[:,0]=np.array([1,0,0,0])
Activation[:,1]=np.array([0,1,0,0])

#learning objectives
objective=np.zeros((nUnits,nUnits,Tr)) 
objective[0,2,part1]=1
objective[1,3,part1]=1
objective[1,2,part2]=1    
objective[0,3,part2]=1 
objective[1,3,part3]=1
objective[0,2,part3]=1

# simulation loops
for b in range(betas):           #gradual change of beta 
    for r in range(Rep):         #replication loop

        # model build-up
        #processing layer
        Rate=np.zeros((nUnits,Tr))        #rate neurons (matrix definieren)

        #weights
        W=np.zeros((nUnits,nUnits,Tr+1))          #matrix met gewichten definieren
        W[0:2,2:4,0]=np.random.random((2,2))    #initial weigth strengths

        # Input
        #randomization of input patterns
        In=np.tile([0,1],(3,POT_1))
        Input=np.zeros((1,Tr))
        Input[0,part1]=In[0,np.random.permutation(POT_1)]
        Input[0,part2]=In[1,np.random.permutation(POT_1)]
        Input[0,part3]=In[2,np.random.permutation(POT_1)]

        # Other
        Z=np.zeros((nUnits,Tr))            #input matrix
        response=np.zeros((nUnits//2,Tr))  #response record
        rew=np.zeros((1,Tr));              #reward or accuracy

        # the model

        for trial in range(Tr):            #trial loop
        
            Z[:,trial]=Activation[:,int(Input[0,trial])] 
                
            #updating rate code units
            for units in range(nUnits):
                Rate[units,trial]=Z[units,trial]+ np.matmul(np.transpose(Rate[:,trial]),np.squeeze(W[:,units,trial]))
                    
                #response determination:
                if Rate[2,trial]>Rate[3,trial]:   #responseone
                    response[0,trial]= 1
                    response[1,trial]= 0    
                else:  #responsetwo
                    response[0,trial]= 0
                    response[1,trial]= 1
        
            #reward value determination
            if np.all(np.transpose(np.squeeze(objective[int(Input[0,trial]),range(2,4),trial]))==response[:,trial]):
                rew[0,trial]=1
            else:
                rew[0,trial]=0 
        
            #RW learning
            for p in range(2):
                for q in range(2,4):
                    #weight updating (only for weights different than zero)
                    W[p,q,trial+1]=W[p,q,trial]+Beta[b]*(objective[p,q,trial]-Rate[q,trial])*Rate[p,trial]
        
        data_pickle = "Beta"+str(Beta[b])+"_Rep"+str(r)+"_RWonly.p"

        variables_str = ["rew","W"]
        variables =     [rew,W]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)
            
            