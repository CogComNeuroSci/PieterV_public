#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  6 09:50:56 2018

@author: pieter
"""
import numpy as np
import math
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
T=500                           # trialtime
Tr=240                          # amount of trials
betas=11                        # beta iterations
Beta=np.arange(0,1.1,0.1)       #learning rate values
ITI=250;                        #intertrial interval

# other variables
POT_1=Tr//3                     #point of switch to task rule 2 (trial 20)
POT_2=2*Tr//3                   #switch again to task rule 1    (trial 40)
part1=np.arange(POT_1)          #first part
part2=np.arange(POT_1,POT_2)    #second part
part3=np.arange(POT_2,Tr)       #third part

#model build-up
    #Processing module
nUnits=6                        #model units
r2max=1                         #max amplitude
Cg=0.58                         #coupling gamma waves
damp=0.3                        #damping parameter
decay=0.9                       #decay parameter

    #Control module  
r2_acc=0.05                     #radius ACC
Ct=0.07                         #coupling theta waves
damp_acc=0.003                  #damping parameter ACC
acc_slope=10                    #acc_slope

    #Critic
lp=0.2                          #learning rate critic

#Input patterns
Activation=np.zeros((nUnits,2))
Activation[:,0]=np.array([1,0,0,0,0,0])
Activation[:,1]=np.array([0,1,0,0,0,0])

#learning objectives
objective=np.zeros((nUnits,nUnits,Tr)) 
objective[0,2,part1]=1
objective[1,3,part1]=1
objective[1,2,part2]=1    
objective[0,3,part2]=1 
objective[1,3,part3]=1
objective[0,2,part3]=1
objective[0,4:6,:]=objective[0,2:4,:]
objective[1,4:6,:]=objective[1,2:4,:]

# simulation loops
for b in range(betas):          #gradual change of beta 
    for r in range(Rep):          #replication loop

        # model initialization
        #processing layer
        Phase=np.zeros((nUnits,2,T+1,Tr))         #Phase neurons
        Rate=np.zeros((nUnits,T+1,Tr))            #rate neurons

        #weights
        W=np.zeros((nUnits,nUnits,Tr+1))
        W[0:2,2:6,0]=np.random.random((2,4))    #initial weigth strengths    
        
        #Control module
        LFC=np.zeros((3,Tr+1))                  #LFC units
        LFC[0,0]=1
        if np.random.random()>0.5:
            LFC[2,0]=-1
            LFC[1,0]=1
        else:
            LFC[2,0]=1
            LFC[1,0]=-1

        ACC=np.zeros((2,T+1,Tr))                  #ACC phase units
        Be=np.zeros((T+1,Tr))                     #Bernoulli (ACC rate)
        
        #Critic
        rew=np.zeros((1,Tr))                    #reward
        V=np.zeros((1,Tr))                      #value unit
        E=np.zeros((2,Tr+1))                    #value weights
        E[:,0]=0.5                              #initial values
        negPE=np.zeros((1,Tr))                  #negative prediction error
        posPE=np.zeros((1,Tr))                  #positive prediciton error
        S=np.zeros((1,Tr+1))                    #Switch neuron
        
        # Input
        #randomization of input patterns
        In=np.tile([0,1],(3,POT_1))
        Input=np.zeros((1,Tr))
        Input[0,part1]=In[0,np.random.permutation(POT_1)]
        Input[0,part2]=In[1,np.random.permutation(POT_1)]
        Input[0,part3]=In[2,np.random.permutation(POT_1)]

        # Other
        #starting points of oscillations
        start=np.random.random((nUnits,2))  #draw random starting points
        start_ACC=np.random.random((2))     #acc starting points
            #assign starting values
        Phase[:,:,0,0]=start
        ACC[:,0,0]=start_ACC
        
        r2=np.zeros((nUnits+1,T,Tr))            #radius
        #recordings
        Z=np.zeros((nUnits,Tr))                 #input matrix
        response=np.zeros((nUnits//2,Tr))       #response record
        sync=np.zeros((nUnits,nUnits,Tr))       #sync matrix
        Hit=np.zeros((T,Tr))                    #hit record

        # the model

        for trial in range(Tr):            #trial loop
            
            if trial>0:#starting points are end points previous trial
                Phase[:,:,0,trial]=Phase[:,:,time,trial-1]
                ACC[:,0,trial]=ACC[:,time,trial-1]
            
            #input
            Z[:,trial]=Activation[:,int(Input[0,trial])]
            
            for time in range(ITI):
                #updating phase code units
                for units in range(nUnits):
                    r2[units,time,trial]=np.sum(Phase[units,:,time,trial]*Phase[units,:,time,trial])                                                                #radius
                    Phase[units,0,time+1,trial]=Phase[units,0,time,trial]-Cg*Phase[units,1,time,trial]-damp*(r2[units,time,trial]>r2max).astype(int)*Phase[units,0,time,trial]  # excitatory cells
                    Phase[units,1,time+1,trial]=Phase[units,1,time,trial]+Cg*Phase[units,0,time,trial]-damp*(r2[units,time,trial]>r2max).astype(int)*Phase[units,1,time,trial]  # inhibitory cells
                
                #updating phase code units in ACC
                r2[nUnits,time,trial]=np.sum(ACC[:,time,trial]*ACC[:,time,trial])                                                                                 #radius ACC
                ACC[0,time+1,trial]=ACC[0,time,trial]-Ct*ACC[1,time,trial]-damp_acc*(r2[nUnits,time,trial]>r2_acc).astype(int)*ACC[0,time,trial]                              # ACC exc cell
                ACC[1,time+1,trial]=ACC[1,time,trial]+Ct*ACC[0,time,trial]-damp_acc*(r2[nUnits,time,trial]>r2_acc).astype(int)*ACC[1,time,trial]                              # ACC inh cell
            
                #bernoulli process in ACC rate
                Be[time,trial]=1/(1+np.exp(-acc_slope*(ACC[0,time,trial]-1)))
                prob=np.random.random()
                
                if trial>0:
                    if negPE[0,trial-1]>0: 
                        Be_ACC=np.exp(-(time-100)**2/(2*12.5**2))
                        prob_ACC=np.random.random()
                        if prob_ACC< Be_ACC:
                            Gaussian_ACC=np.random.normal(2,1)
                            ACC[:,time+1,trial]=decay*ACC[:,time,trial]-negPE[0,trial-1]*Gaussian_ACC

                #burst
                if prob<Be[time,trial]:
                    Hit[time,trial]=1
                    Gaussian=np.random.normal(size=[1,2])
                    for units in range(nUnits):
                        lfc=math.floor(units/2)
                        Phase[units,:,time+1,trial]=decay*Phase[units,:,time,trial]+LFC[lfc,trial]*Gaussian
                 
                Rate[:,time+1,trial]=np.zeros((nUnits))
            
            #loop until response 
            for time in range(ITI,T): 

                #updating phase code units
                for units in range(nUnits):
                    r2[units,time,trial]=np.sum(Phase[units,:,time,trial]*Phase[units,:,time,trial])                                                                #radius
                    Phase[units,0,time+1,trial]=Phase[units,0,time,trial]-Cg*Phase[units,1,time,trial]-damp*(r2[units,time,trial]>r2max).astype(int)*Phase[units,0,time,trial]  # excitatory cells
                    Phase[units,1,time+1,trial]=Phase[units,1,time,trial]+Cg*Phase[units,0,time,trial]-damp*(r2[units,time,trial]>r2max).astype(int)*Phase[units,1,time,trial]  # inhibitory cells
                
                #updating phase code units in ACC
                r2[nUnits,time,trial]=np.sum(ACC[:,time,trial]*ACC[:,time,trial])                                                                                 #radius ACC
                ACC[0,time+1,trial]=ACC[0,time,trial]-Ct*ACC[1,time,trial]-damp_acc*(r2[nUnits,time,trial]>r2_acc).astype(int)*ACC[0,time,trial]                              # ACC exc cell
                ACC[1,time+1,trial]=ACC[1,time,trial]+Ct*ACC[0,time,trial]-damp_acc*(r2[nUnits,time,trial]>r2_acc).astype(int)*ACC[1,time,trial]                              # ACC inh cell
            
                #bernoulli process in ACC rate
                Be[time,trial]=1/(1+np.exp(-acc_slope*(ACC[0,time,trial]-1)))
                prob=np.random.random()
            
                #burst
                if prob<Be[time,trial]:
                    Hit[time,trial]=1
                    Gaussian=np.random.normal(size=[1,2])
                    for units in range(nUnits):
                        lfc=math.floor(units/2)                                                  
                        Phase[units,:,time+1,trial]=decay*Phase[units,:,time,trial]+LFC[lfc,trial]*Gaussian

                        

                #updating rate code units
                for units in range(nUnits):
                    Rate[units,time+1,trial]=(Z[units,trial]+ np.matmul(np.transpose(Rate[:,time,trial]),np.squeeze(W[:,units,trial])))*(1/(1+np.exp(-5*(Phase[units,0,time,trial]-0.6)))) 
            
            #end of trial time loop
        
            maxi=np.max(Rate[:,:,trial],axis=1)
            rid=np.argmax(maxi)
            if rid==0 or rid==2:
                response[0,trial]=1
                response[1,trial]=0
            else:
                response[0,trial]=0
                response[1,trial]=1
                
            #reward value determination
            if np.all(np.transpose(np.squeeze(objective[int(Input[0,trial]),range(2,4),trial]))==response[:,trial]):
                rew[0,trial]=1
            else:
                rew[0,trial]=0 
            
            #value unit
            V[0,trial]=np.matmul(np.transpose(E[:,trial]), 0.5* (LFC[1:3,trial]+1))
            
            #prediction errors
            negPE[0,trial]= np.maximum(0,V[0,trial]-rew[0,trial])
            posPE[0,trial]= np.maximum(0,rew[0,trial]-V[0,trial])
            
            #value weight update
            E[:,trial+1]= E[:,trial]+lp * V[0,trial] * 0.5 * (LFC[1:3,trial] +np.ones((2)))* (posPE[0,trial]-negPE[0,trial]) 
            
            #Switch neuron update
            S[0,trial+1]=0.5*S[0,trial]+0.5*negPE[0,trial]
            
            #LFC neurons updat
            if (S[0,trial+1])>0.5:
                LFC[2,trial+1]=-LFC[2,trial]
                LFC[1,trial+1]=-LFC[1,trial]
                S[0,trial+1]=0
            else:
                LFC[2,trial+1]=-LFC[2,trial]
                LFC[1,trial+1]=-LFC[1,trial]

            LFC[0,trial+1]=LFC[0,trial]   
            
            #RW learning
            for p in range(2):
                for q in range(2,4):
                    #weight updating (only for weights different than zero)
                    W[p,q,trial+1]=W[p,q,trial]+Beta[b]*(objective[p,q,trial]-np.amax(Rate[q,:,trial]))*np.amax(Rate[p,:,trial])*np.amax(Rate[q,:,trial])
                    
            for p in range(nUnits):
                for q in range(nUnits):
                    sync[p,q,trial]=np.corrcoef(np.squeeze(Phase[p,0,0:time,trial]),np.squeeze(Phase[q,0,0:time,trial]))[1,0]
                
        data_pickle = "Beta"+str(b)+"_Rep"+str(r)+"_RWsync.p"

        variables_str = ["Phase","ACC","sync","rew","W"]
        variables =     [Phase,ACC,sync,rew,W]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)