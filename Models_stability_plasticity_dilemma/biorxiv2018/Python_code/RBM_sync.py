#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  7 16:51:36 2018

@author: pieter
"""
import numpy as np
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
T=1000                          # trialtime
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
nM2=4                           #number of hidden units in module 2
nmod=2                          #number of modules
nResp=2                         #number of response options
nInput=(nStim//3)**3            #number of Input patterns
r2max=1                         #max amplitude
Cg=0.1                          #coupling gamma waves
damp=0.01                       #damping parameter
decay=0.9                       #decay parameter
bias=5                          #bias parameter

    #Control module  
r2_acc=1                        #radius ACC
Ct=0.01                         #coupling theta waves
damp_acc=0.01                   #damping parameter ACC
acc_slope=10                    #acc_slope

    #Critic
lp=0.01                          #learning rate critic

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
        Phase_Input_plus=np.zeros((nStim,2,T+1,Tr))    #Phase neurons of input layer
        Rate_Input_plus=np.zeros((nStim,T+1,Tr))       #rate neurons
        
        Phase_M1_plus=np.zeros((nM1,2,T+1,Tr))         #Phase neurons of hidden layer
        Rate_M1_plus=np.zeros((nM1,T+1,Tr))            #rate neurons        

        Phase_M2_plus=np.zeros((nM2,2,T+1,Tr))         #Phase neurons of hidden layer
        Rate_M2_plus=np.zeros((nM2,T+1,Tr))            #rate neurons  
        
        Phase_Out_plus=np.zeros((nResp,2,T+1,Tr))      #Phase neurons of output layer
        Rate_Out_plus=np.zeros((nResp,T+1,Tr))         #rate neurons
        
        #net inputs
        net_M1_plus=np.zeros((nM1,T,Tr))
        net_M2_plus=np.zeros((nM2,T,Tr))
        
        #negative phase
        Phase_Input_min=np.zeros((nStim,2,T+1,Tr,iterations,2))    #Phase neurons of input layer
        Rate_Input_min=np.zeros((nStim,T+1,Tr,iterations,2))       #rate neurons
        
        Phase_M1_min=np.zeros((nM1,2,T+1,Tr,iterations,2))         #Phase neurons of hidden layer
        Rate_M1_min=np.zeros((nM1,T+1,Tr,iterations,2))            #rate neurons        

        Phase_M2_min=np.zeros((nM2,2,T+1,Tr,iterations,2))         #Phase neurons of hidden layer
        Rate_M2_min=np.zeros((nM2,T+1,Tr,iterations,2))            #rate neurons  
        
        Phase_Out_min=np.zeros((nResp,2,T+1,Tr,iterations,2))      #Phase neurons of output layer
        Rate_Out_min=np.zeros((nResp,T+1,Tr,iterations,2))         #rate neurons
        
        #net inputs
        net_M1_min=np.zeros((nM1,T,Tr,iterations))
        net_M2_min=np.zeros((nM2,T,Tr,iterations))
        net_Out_min=np.zeros((nResp,T,Tr,iterations))
        
        #binarizations
        bin_M1=np.zeros((nM1,Tr,iterations))
        bin_M2=np.zeros((nM1,Tr,iterations))
        
        #weights
        W_IM1=np.zeros((nStim,nM1,Tr+1))
        W_IM2=np.zeros((nStim,nM2,Tr+1))
        W_M1O=np.zeros((nM1,nResp,Tr+1))
        W_M2O=np.zeros((nM2,nResp,Tr+1))
        #initial (random) weigth strengths
        W_IM1[:,:,0]=np.random.random((nStim,nM1))*5 
        W_IM2[:,:,0]=np.random.random((nStim,nM2))*5 
        W_M1O[:,:,0]=np.random.random((nM1,nResp))*5 
        W_M2O[:,:,0]=np.random.random((nM2,nResp))*5 
        
        #Control module
        LFC=np.zeros((nmod+1,Tr+1))               #LFC units
        #starting module choice
        if np.random.random()>0.5:
            LFC[0,0]=-1
            LFC[1,0]=1
        else:
            LFC[0,0]=1
            LFC[1,0]=-1 
        LFC[2,0]=1
        
        ACC_plus=np.zeros((2,T+1,Tr))                  #ACC phase units
        ACC_min=np.zeros((2,T+1,Tr,iterations,2))
        Be_plus=np.zeros((T,Tr))                     #Bernoulli (ACC rate)
        Be_min=np.zeros((T,Tr,iterations,2))
        
        #Critic
        rew=np.zeros((1,Tr))                    #reward
        V=np.zeros((1,Tr))                      #value unit
        S=np.zeros((1,Tr+1))                    #switch unit
        E=np.zeros((nmod,Tr+1))                 #value weights
        E[:,0]=0.5                              #initial values
        negPE=np.zeros((1,Tr))                  #negative prediction error
        posPE=np.zeros((1,Tr))                  #positive prediciton error
        
        #learning
        Errorscore=np.zeros((nResp,Tr))         #errorscore
        delta_M1out=np.zeros((nM1,nResp,Tr))    #delta hidden to output layer
        delta_M2out=np.zeros((nM2,nResp,Tr))    #delta hidden to output layer
        delta_M1=np.zeros((nStim,nM1,Tr));      #delta input to hidden layer M1
        delta_M2=np.zeros((nStim,nM2,Tr));      #delta input to hidden layer M2
        
        # Input
        #randomization of input patterns
        In=np.tile(range(nInput),(3,POT_1))
        Input=np.zeros((1,Tr))
        Input[0,part1]=In[0,np.random.permutation(POT_1)]
        Input[0,part2]=In[1,np.random.permutation(POT_1)]
        Input[0,part3]=In[2,np.random.permutation(POT_1)]

        # Other
        #starting points of oscillations
        start_Input=np.random.random((nStim,2)) #draw random starting points
        start_M1=np.random.random((nM1,2))
        start_M2=np.random.random((nM2,2))
        start_Out=np.random.random((nResp,2))
        start_ACC=np.random.random((2))         #acc starting points
            
            #assign starting values
        Phase_Input_plus[:,:,0,0]=start_Input
        Phase_M1_plus[:,:,0,0]=start_M1
        Phase_M1_plus[:,:,0,0]=start_M2
        Phase_Out_plus[:,:,0,0]=start_Out
        ACC_plus[:,0,0]=start_ACC
        
        #radius
        r2_Input_plus=np.zeros((nStim,T,Tr))         
        r2_M1_plus=np.zeros((nM1,T,Tr))
        r2_M2_plus=np.zeros((nM2,T,Tr))
        r2_Out_plus=np.zeros((nResp,T,Tr))
        r2_ACC_plus=np.zeros((T,Tr))
        
        r2_Input_min=np.zeros((nStim,T,Tr,iterations,2))         
        r2_M1_min=np.zeros((nM1,T,Tr,iterations,2))
        r2_M2_min=np.zeros((nM2,T,Tr,iterations,2))
        r2_Out_min=np.zeros((nResp,T,Tr,iterations,2))
        r2_ACC_min=np.zeros((T,Tr,iterations,2))
        
        #recordings
        Z=np.zeros((nStim,Tr))                              #input matrix
        Q=np.zeros((nResp,Tr))
        Q_min=np.zeros((nResp,Tr,iterations+1))
        response=np.zeros((nResp,Tr,iterations))           #response record
        sync_IM1=np.zeros((nInput,nM1,Tr))                 #sync matrix
        sync_IM2=np.zeros((nInput,nM2,Tr))
        Hit_plus=np.zeros((T,Tr))                          #hit record
        Hit_min=np.zeros((T,Tr,iterations,2))  
        
        # the model

        for trial in range(Tr):            #trial loop
            
            if trial>0:#starting points are end points previous trial
                Phase_Input_plus[:,:,0,trial]=Phase_Input_min[:,:,time,trial-1,iterations-1,1]
                Phase_M1_plus[:,:,0,trial]=Phase_M1_min[:,:,time,trial-1,iterations-1,1]
                Phase_M2_plus[:,:,0,trial]=Phase_M2_min[:,:,time,trial-1,iterations-1,1]
                Phase_Out_plus[:,:,0,trial]=Phase_Out_min[:,:,time,trial-1,iterations-1,1]
                ACC_plus[:,0,trial]=ACC_min[:,time,trial-1,iterations-1,1]
            
            #input and output
            Z[:,trial]=Activation[:,int(Input[0,trial])]
            Q[:,trial]=objective[:,int(Input[0,trial]),trial]
            
            #positive phase
            for time in range(T):
                
                #updating radius
                r2_Input_plus[:,time,trial]=np.sum(Phase_Input_plus[:,:,time,trial]*Phase_Input_plus[:,:,time,trial],axis=1)    
                r2_M1_plus[:,time,trial]=np.sum(Phase_M1_plus[:,:,time,trial]*Phase_M1_plus[:,:,time,trial],axis=1)  
                r2_M2_plus[:,time,trial]=np.sum(Phase_M2_plus[:,:,time,trial]*Phase_M2_plus[:,:,time,trial],axis=1)  
                r2_Out_plus[:,time,trial]=np.sum(Phase_Out_plus[:,:,time,trial]*Phase_Out_plus[:,:,time,trial],axis=1)  
                r2_ACC_plus[time,trial]=np.sum(ACC_plus[:,time,trial]*ACC_plus[:,time,trial]) 
                
                #updating phase code units
                Phase_Input_plus[:,0,time+1,trial]=Phase_Input_plus[:,0,time,trial]-Cg*Phase_Input_plus[:,1,time,trial]-damp*((r2_Input_plus[:,time,trial]>r2max).astype(int))*Phase_Input_plus[:,0,time,trial]  # excitatory cells
                Phase_Input_plus[:,1,time+1,trial]=Phase_Input_plus[:,1,time,trial]+Cg*Phase_Input_plus[:,0,time,trial]-damp*((r2_Input_plus[:,time,trial]>r2max).astype(int))*Phase_Input_plus[:,1,time,trial]  # inhibitory cells
                
                Phase_M1_plus[:,0,time+1,trial]=Phase_M1_plus[:,0,time,trial]-Cg*Phase_M1_plus[:,1,time,trial]-damp*((r2_M1_plus[:,time,trial]>r2max).astype(int))*Phase_M1_plus[:,0,time,trial]  # excitatory cells
                Phase_M1_plus[:,1,time+1,trial]=Phase_M1_plus[:,1,time,trial]+Cg*Phase_M1_plus[:,0,time,trial]-damp*((r2_M1_plus[:,time,trial]>r2max).astype(int))*Phase_M1_plus[:,1,time,trial]  # inhibitory cells
                
                Phase_M2_plus[:,0,time+1,trial]=Phase_M2_plus[:,0,time,trial]-Cg*Phase_M2_plus[:,1,time,trial]-damp*((r2_M2_plus[:,time,trial]>r2max).astype(int))*Phase_M2_plus[:,0,time,trial]  # excitatory cells
                Phase_M2_plus[:,1,time+1,trial]=Phase_M2_plus[:,1,time,trial]+Cg*Phase_M2_plus[:,0,time,trial]-damp*((r2_M2_plus[:,time,trial]>r2max).astype(int))*Phase_M2_plus[:,1,time,trial]  # inhibitory cells
                
                Phase_Out_plus[:,0,time+1,trial]=Phase_Out_plus[:,0,time,trial]-Cg*Phase_Out_plus[:,1,time,trial]-damp*((r2_Out_plus[:,time,trial]>r2max).astype(int))*Phase_Out_plus[:,0,time,trial]  # excitatory cells
                Phase_Out_plus[:,1,time+1,trial]=Phase_Out_plus[:,1,time,trial]+Cg*Phase_Out_plus[:,0,time,trial]-damp*((r2_Out_plus[:,time,trial]>r2max).astype(int))*Phase_Out_plus[:,1,time,trial]  # inhibitory cells
                                                                                                #radius ACC
                ACC_plus[0,time+1,trial]=ACC_plus[0,time,trial]-Ct*ACC_plus[1,time,trial]-damp_acc*(r2_ACC_plus[time,trial]>r2_acc).astype(int)*ACC_plus[0,time,trial]                              # ACC exc cell
                ACC_plus[1,time+1,trial]=ACC_plus[1,time,trial]+Ct*ACC_plus[0,time,trial]-damp_acc*(r2_ACC_plus[time,trial]>r2_acc).astype(int)*ACC_plus[1,time,trial]                              # ACC inh cell
            
                #bernoulli process in ACC rate
                Be_plus[time,trial]=1/(1+np.exp(-acc_slope*(ACC_plus[0,time,trial]-1)))
                prob=np.random.random()
            
                #burst
                if prob<Be_plus[time,trial]:
                    Hit_plus[time,trial]=1
                    Gaussian=np.random.normal(size=[1,2])
                    Phase_Input_plus[:,:,time+1,trial]=decay*Phase_Input_plus[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nStim,1)),Gaussian)
                    Phase_M1_plus[:,:,time+1,trial]=decay*Phase_M1_plus[:,:,time,trial]+np.matmul(LFC[0,trial]*np.ones((nM1,1)),Gaussian)
                    Phase_M2_plus[:,:,time+1,trial]=decay*Phase_M2_plus[:,:,time,trial]+np.matmul(LFC[1,trial]*np.ones((nM2,1)),Gaussian)
                    Phase_Out_plus[:,:,time+1,trial]=decay*Phase_Out_plus[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nResp,1)),Gaussian)
                        
                #updating rate code units
                Rate_Input_plus[:,time,trial]=Z[:,trial] *(1/(1+np.exp(-5*(Phase_Input_plus[:,0,time,trial]-0.6)))) 
                
                Rate_Out_plus[:,time,trial]=Q[:,trial]*(1/(1+np.exp(-5*(Phase_Out_plus[:,0,time,trial]-0.6))))
                
                net_M1_plus[:,time,trial]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input_plus[:,time,trial])+np.matmul(W_M1O[:,:,trial],Rate_Out_plus[:,time,trial])-bias
                Rate_M1_plus[:,time,trial]=(1/(1+np.exp(-net_M1_plus[:,time,trial])))*(1/(1+np.exp(-5*(Phase_M1_plus[:,0,time,trial]-0.6)))) 
                
                net_M2_plus[:,time,trial]=np.matmul(np.transpose(W_IM2[:,:,trial]),Rate_Input_plus[:,time,trial])+np.matmul(W_M2O[:,:,trial],Rate_Out_plus[:,time,trial])-bias
                Rate_M2_plus[:,time,trial]=(1/(1+np.exp(-net_M2_plus[:,time,trial])))*(1/(1+np.exp(-5*(Phase_M2_plus[:,0,time,trial]-0.6))))
        
            #negative phase
            for i in range(iterations):
                
                if i==0:                
                    Phase_Input_min[:,:,0,trial,0,0]=Phase_Input_plus[:,:,time,trial]
                    Phase_M1_min[:,:,0,trial,0,0]=Phase_M1_plus[:,:,time,trial]
                    Phase_M2_min[:,:,0,trial,0,0]=Phase_M2_plus[:,:,time,trial]
                    Phase_Out_min[:,:,0,trial,0,0]=Phase_Out_plus[:,:,time,trial]
                    ACC_min[:,0,trial,0,0]=ACC_plus[:,time,trial]
                else:
                    Phase_Input_min[:,:,0,trial,i,0]=Phase_Input_min[:,:,time,trial,i-1,1]
                    Phase_M1_min[:,:,0,trial,i,0]=Phase_M1_min[:,:,time,trial,i-1,1]
                    Phase_M2_min[:,:,0,trial,i,0]=Phase_M2_min[:,:,time,trial,i-1,1]
                    Phase_Out_min[:,:,0,trial,i,0]=Phase_Out_min[:,:,time,trial,i-1,1]
                    ACC_min[:,0,trial,i,0]=ACC_min[:,time,trial,i-1,1]  
                
                #from input and output to hidden layer     
                for time in range(T):
                
                    #updating radius
                    r2_Input_min[:,time,trial,i,0]=np.sum(Phase_Input_min[:,:,time,trial,i,0]*Phase_Input_min[:,:,time,trial,i,0],axis=1)    
                    r2_M1_min[:,time,trial,i,0]=np.sum(Phase_M1_min[:,:,time,trial,i,0]*Phase_M1_min[:,:,time,trial,i,0],axis=1)  
                    r2_M2_min[:,time,trial,i,0]=np.sum(Phase_M2_min[:,:,time,trial,i,0]*Phase_M2_min[:,:,time,trial,i,0],axis=1)  
                    r2_Out_min[:,time,trial,i,0]=np.sum(Phase_Out_min[:,:,time,trial,i,0]*Phase_Out_min[:,:,time,trial,i,0],axis=1)  
                    r2_ACC_min[time,trial,i,0]=np.sum(ACC_min[:,time,trial,i,0]*ACC_min[:,time,trial,i,0]) 
                
                    #updating phase code units
                    Phase_Input_min[:,0,time+1,trial,i,0]=Phase_Input_min[:,0,time,trial,i,0]-Cg*Phase_Input_min[:,1,time,trial,i,0]-damp*((r2_Input_min[:,time,trial,i,0]>r2max).astype(int))*Phase_Input_min[:,0,time,trial,i,0]  # excitatory cells
                    Phase_Input_min[:,1,time+1,trial,i,0]=Phase_Input_min[:,1,time,trial,i,0]+Cg*Phase_Input_min[:,0,time,trial,i,0]-damp*((r2_Input_min[:,time,trial,i,0]>r2max).astype(int))*Phase_Input_min[:,1,time,trial,i,0]  # inhibitory cells
                
                    Phase_M1_min[:,0,time+1,trial,i,0]=Phase_M1_min[:,0,time,trial,i,0]-Cg*Phase_M1_min[:,1,time,trial,i,0]-damp*((r2_M1_min[:,time,trial,i,0]>r2max).astype(int))*Phase_M1_min[:,0,time,trial,i,0]  # excitatory cells
                    Phase_M1_min[:,1,time+1,trial,i,0]=Phase_M1_min[:,1,time,trial,i,0]+Cg*Phase_M1_min[:,0,time,trial,i,0]-damp*((r2_M1_min[:,time,trial,i,0]>r2max).astype(int))*Phase_M1_min[:,1,time,trial,i,0]  # inhibitory cells
                
                    Phase_M2_min[:,0,time+1,trial,i,0]=Phase_M2_min[:,0,time,trial,i,0]-Cg*Phase_M2_min[:,1,time,trial,i,0]-damp*((r2_M2_min[:,time,trial,i,0]>r2max).astype(int))*Phase_M2_min[:,0,time,trial,i,0]  # excitatory cells
                    Phase_M2_min[:,1,time+1,trial,i,0]=Phase_M2_min[:,1,time,trial,i,0]+Cg*Phase_M2_min[:,0,time,trial,i,0]-damp*((r2_M2_min[:,time,trial,i,0]>r2max).astype(int))*Phase_M2_min[:,1,time,trial,i,0]  # inhibitory cells
                
                    Phase_Out_min[:,0,time+1,trial,i,0]=Phase_Out_min[:,0,time,trial,i,0]-Cg*Phase_Out_min[:,1,time,trial,i,0]-damp*((r2_Out_min[:,time,trial,i,0]>r2max).astype(int))*Phase_Out_min[:,0,time,trial,i,0]  # excitatory cells
                    Phase_Out_min[:,1,time+1,trial,i,0]=Phase_Out_min[:,1,time,trial,i,0]+Cg*Phase_Out_min[:,0,time,trial,i,0]-damp*((r2_Out_min[:,time,trial,i,0]>r2max).astype(int))*Phase_Out_min[:,1,time,trial,i,0]  # inhibitory cells
                    
                    #radius ACC
                    ACC_min[0,time+1,trial,i,0]=ACC_min[0,time,trial,i,0]-Ct*ACC_min[1,time,trial,i,0]-damp_acc*(r2_ACC_min[time,trial,i,0]>r2_acc).astype(int)*ACC_min[0,time,trial,i,0]                              # ACC exc cell
                    ACC_min[1,time+1,trial,i,0]=ACC_min[1,time,trial,i,0]+Ct*ACC_min[0,time,trial,i,0]-damp_acc*(r2_ACC_min[time,trial,i,0]>r2_acc).astype(int)*ACC_min[1,time,trial,i,0]                              # ACC inh cell
            
                    #bernoulli process in ACC rate
                    Be_min[time,trial,i,0]=1/(1+np.exp(-acc_slope*(ACC_min[0,time,trial,i,0]-1)))
                    prob=np.random.random()
            
                    #burst
                    if prob<Be_min[time,trial,i,0]:
                        Hit_plus[time,trial]=1
                        Gaussian=np.random.normal(size=[1,2])
                        Phase_Input_min[:,:,time+1,trial,i,0]=decay*Phase_Input_min[:,:,time,trial,i,0]+np.matmul(LFC[2,trial]*np.ones((nStim,1)),Gaussian)
                        Phase_M1_min[:,:,time+1,trial,i,0]=decay*Phase_M1_min[:,:,time,trial,i,0]+np.matmul(LFC[0,trial]*np.ones((nM1,1)),Gaussian)
                        Phase_M2_min[:,:,time+1,trial,i,0]=decay*Phase_M2_min[:,:,time,trial,i,0]+np.matmul(LFC[1,trial]*np.ones((nM2,1)),Gaussian)
                        Phase_Out_min[:,:,time+1,trial,i,0]=decay*Phase_Out_min[:,:,time,trial,i,0]+np.matmul(LFC[2,trial]*np.ones((nResp,1)),Gaussian)
                        
                    #updating rate code units
                    Rate_Input_min[:,time,trial,i,0]=Z[:,trial] *(1/(1+np.exp(-5*(Phase_Input_min[:,0,time,trial,i,0]-0.6)))) 
                
                    Rate_Out_min[:,time,trial,i,0]=Q_min[:,trial,i]*(1/(1+np.exp(-5*(Phase_Out_min[:,0,time,trial,i,0]-0.6))))
                
                    net_M1_min[:,time,trial,i]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input_min[:,time,trial,i,0])+np.matmul(W_M1O[:,:,trial],Rate_Out_min[:,time,trial,i,0])-bias
                    Rate_M1_min[:,time,trial,i,0]=(1/(1+np.exp(-net_M1_min[:,time,trial,i])))*(1/(1+np.exp(-5*(Phase_M1_min[:,0,time,trial,i,0]-0.6)))) 
                
                    net_M2_min[:,time,trial,i]=np.matmul(np.transpose(W_IM2[:,:,trial]),Rate_Input_min[:,time,trial,i,0])+np.matmul(W_M2O[:,:,trial],Rate_Out_min[:,time,trial,i,0])-bias
                    Rate_M2_min[:,time,trial,i,0]=(1/(1+np.exp(-net_M2_min[:,time,trial,i])))*(1/(1+np.exp(-5*(Phase_M2_min[:,0,time,trial,i,0]-0.6))))
     
                #binarization of hidden layer activation
                bin_M1[:,trial,i]=(np.amax(Rate_M1_min[:,:,trial,i,0],axis=1)>np.random.random()).astype(int)
                bin_M2[:,trial,i]=(np.amax(Rate_M2_min[:,:,trial,i,0],axis=1)>np.random.random()).astype(int)
            
                #continuing the oscillations
                Phase_Input_min[:,:,0,trial,i,0]=Phase_Input_min[:,:,time,trial,i,0]
                Phase_M1_min[:,:,0,trial,i,0]=Phase_M1_min[:,:,time,trial,i,0]
                Phase_M2_min[:,:,0,trial,i,0]=Phase_M2_min[:,:,time,trial,i,0]
                Phase_Out_min[:,:,0,trial,i,0]=Phase_Out_min[:,:,time,trial,i,0]
                ACC_min[:,0,trial,i,0]=ACC_min[:,time,trial,i,0] 
            
                #from hidden back to output
                for time in range(T):
                
                    #updating radius
                    r2_Input_min[:,time,trial,i,1]=np.sum(Phase_Input_min[:,:,time,trial,i,1]*Phase_Input_min[:,:,time,trial,i,1],axis=1)    
                    r2_M1_min[:,time,trial,i,1]=np.sum(Phase_M1_min[:,:,time,trial,i,1]*Phase_M1_min[:,:,time,trial,i,1],axis=1)  
                    r2_M2_min[:,time,trial,i,1]=np.sum(Phase_M2_min[:,:,time,trial,i,1]*Phase_M2_min[:,:,time,trial,i,1],axis=1)  
                    r2_Out_min[:,time,trial,i,1]=np.sum(Phase_Out_min[:,:,time,trial,i,1]*Phase_Out_min[:,:,time,trial,i,1],axis=1)  
                    r2_ACC_min[time,trial,i,1]=np.sum(ACC_min[:,time,trial,i,1]*ACC_min[:,time,trial,i,1]) 
                
                    #updating phase code units
                    Phase_Input_min[:,0,time+1,trial,i,1]=Phase_Input_min[:,0,time,trial,i,1]-Cg*Phase_Input_min[:,1,time,trial,i,1]-damp*((r2_Input_min[:,time,trial,i,1]>r2max).astype(int))*Phase_Input_min[:,0,time,trial,i,1]  # excitatory cells
                    Phase_Input_min[:,1,time+1,trial,i,1]=Phase_Input_min[:,1,time,trial,i,1]+Cg*Phase_Input_min[:,0,time,trial,i,1]-damp*((r2_Input_min[:,time,trial,i,1]>r2max).astype(int))*Phase_Input_min[:,1,time,trial,i,1]  # inhibitory cells
                    
                    Phase_M1_min[:,0,time+1,trial,i,1]=Phase_M1_min[:,0,time,trial,i,1]-Cg*Phase_M1_min[:,1,time,trial,i,1]-damp*((r2_M1_min[:,time,trial,i,1]>r2max).astype(int))*Phase_M1_min[:,0,time,trial,i,1]  # excitatory cells
                    Phase_M1_min[:,1,time+1,trial,i,1]=Phase_M1_min[:,1,time,trial,i,1]+Cg*Phase_M1_min[:,0,time,trial,i,1]-damp*((r2_M1_min[:,time,trial,i,1]>r2max).astype(int))*Phase_M1_min[:,1,time,trial,i,1]  # inhibitory cells
                
                    Phase_M2_min[:,0,time+1,trial,i,1]=Phase_M2_min[:,0,time,trial,i,1]-Cg*Phase_M2_min[:,1,time,trial,i,1]-damp*((r2_M2_min[:,time,trial,i,1]>r2max).astype(int))*Phase_M2_min[:,0,time,trial,i,1]  # excitatory cells
                    Phase_M2_min[:,1,time+1,trial,i,1]=Phase_M2_min[:,1,time,trial,i,1]+Cg*Phase_M2_min[:,0,time,trial,i,1]-damp*((r2_M2_min[:,time,trial,i,1]>r2max).astype(int))*Phase_M2_min[:,1,time,trial,i,1]  # inhibitory cells
                
                    Phase_Out_min[:,0,time+1,trial,i,1]=Phase_Out_min[:,0,time,trial,i,1]-Cg*Phase_Out_min[:,1,time,trial,i,1]-damp*((r2_Out_min[:,time,trial,i,1]>r2max).astype(int))*Phase_Out_min[:,0,time,trial,i,1]  # excitatory cells
                    Phase_Out_min[:,1,time+1,trial,i,1]=Phase_Out_min[:,1,time,trial,i,1]+Cg*Phase_Out_min[:,0,time,trial,i,1]-damp*((r2_Out_min[:,time,trial,i,1]>r2max).astype(int))*Phase_Out_min[:,1,time,trial,i,1]  # inhibitory cells
                    
                    #radius ACC
                    ACC_min[0,time+1,trial,i,1]=ACC_min[0,time,trial,i,1]-Ct*ACC_min[1,time,trial,i,1]-damp_acc*(r2_ACC_min[time,trial,i,1]>r2_acc).astype(int)*ACC_min[0,time,trial,i,1]                              # ACC exc cell
                    ACC_min[1,time+1,trial,i,1]=ACC_min[1,time,trial,i,1]+Ct*ACC_min[0,time,trial,i,1]-damp_acc*(r2_ACC_min[time,trial,i,1]>r2_acc).astype(int)*ACC_min[1,time,trial,i,1]                              # ACC inh cell
            
                    #bernoulli process in ACC rate
                    Be_min[time,trial,i,1]=1/(1+np.exp(-acc_slope*(ACC_min[0,time,trial,i,1]-1)))
                    prob=np.random.random()
            
                    #burst
                    if prob<Be_min[time,trial,i,1]:
                        Hit_plus[time,trial]=1
                        Gaussian=np.random.normal(size=[1,2])
                        Phase_Input_min[:,:,time+1,trial,i,1]=decay*Phase_Input_min[:,:,time,trial,i,1]+np.matmul(LFC[2,trial]*np.ones((nStim,1)),Gaussian)
                        Phase_M1_min[:,:,time+1,trial,i,1]=decay*Phase_M1_min[:,:,time,trial,i,1]+np.matmul(LFC[0,trial]*np.ones((nM1,1)),Gaussian)
                        Phase_M2_min[:,:,time+1,trial,i,1]=decay*Phase_M2_min[:,:,time,trial,i,1]+np.matmul(LFC[1,trial]*np.ones((nM2,1)),Gaussian)
                        Phase_Out_min[:,:,time+1,trial,i,1]=decay*Phase_Out_min[:,:,time,trial,i,1]+np.matmul(LFC[2,trial]*np.ones((nResp,1)),Gaussian)
                        
                    #updating rate code units
                    Rate_Input_min[:,time,trial,i,1]=Z[:,trial] *(1/(1+np.exp(-5*(Phase_Input_min[:,0,time,trial,i,1]-0.6)))) 
                
                    Rate_M1_min[:,time,trial,i,1]=bin_M1[:,trial,i]*(1/(1+np.exp(-5*(Phase_M1_min[:,0,time,trial,i,1]-0.6)))) 

                    Rate_M2_min[:,time,trial,i,1]=bin_M2[:,trial,i]*(1/(1+np.exp(-5*(Phase_M2_min[:,0,time,trial,i,1]-0.6))))
                
                    net_Out_min[:,time,trial,i]=np.matmul(np.transpose(W_M1O[:,:,trial]),Rate_M1_min[:,time,trial,i,1]) + np.matmul(np.transpose(W_M2O[:,:,trial]),Rate_M2_min[:,time,trial,i,1]) -bias
                    Rate_Out_min[:,time,trial,i,1]=(1/(1+np.exp(-net_Out_min[:,time,trial,i])))*(1/(1+np.exp(-5*(Phase_Out_min[:,0,time,trial,i,1]-0.6))))
            
                #response determination
                if np.amax(Rate_Out_min[0,:,trial,i,1])>np.amax(Rate_Out_min[1,:,trial,i,1]):
                    response[0,trial,i]=1
                else:
                    response[1,trial,i]=1
            
                Q_min[:,trial,i+1]=response[:,trial,i]

            #reward value determination
            if np.all(response[:,trial,i]==Q[:,trial]):
                rew[0,trial]=1
            else:
                rew[0,trial]=0 
            
            #value unit
            V[0,trial]=np.matmul(np.transpose(E[:,trial]),(0.5* LFC[0:nmod,trial]+1))
            
            #prediction errors
            negPE[0,trial]= np.maximum(0,V[0,trial]-rew[0,trial])
            posPE[0,trial]= np.maximum(0,rew[0,trial]-V[0,trial])
            
            #value weight update
            E[:,trial+1]= E[:,trial]+lp * V[0,trial] * (0.5* LFC[0:nmod,trial]+1) * (posPE[0,trial]-negPE[0,trial]) 
            
            #Switch unit update
            S[0,trial+1]=0.8*S[0,trial]+0.2*negPE[0,trial]
            
            #LFC update
            if S[0,trial]>0.5:
                LFC[0,trial+1]=-LFC[0,trial]
                LFC[1,trial+1]=-LFC[1,trial]
                S[0,trial+1]=0
            else:
                LFC[0,trial+1]=LFC[0,trial]
                LFC[1,trial+1]=LFC[1,trial]
        
            LFC[2,trial+1]=LFC[2,trial]
            
            #Weight updating
            #compute general errorscore at each output unit
            Errorscore[:,trial]=(objective[:,int(Input[0,trial]),trial]-(np.amax(Rate_Out_min[:,:,trial,i-1,1],axis=1)))**2
            #compute delta_output
            delta_M1out[:,:,trial]=np.matmul(np.amax(Rate_M1_plus[:,:,trial],axis=1)[:,None],np.amax(Rate_Out_plus[:,:,trial],axis=1)[None,:])-np.matmul(np.amax(Rate_M1_min[:,:,trial,i,0],axis=1)[:,None],np.amax(Rate_Out_min[:,:,trial,i-1,1],axis=1)[None,:])
            delta_M2out[:,:,trial]=np.matmul(np.amax(Rate_M2_plus[:,:,trial],axis=1)[:,None],np.amax(Rate_Out_plus[:,:,trial],axis=1)[None,:])-np.matmul(np.amax(Rate_M2_min[:,:,trial,i,0],axis=1)[:,None],np.amax(Rate_Out_min[:,:,trial,i-1,1],axis=1)[None,:])
            #update weights from hidden M1 to output layer
            W_M1O[:,:,trial+1]=W_M1O[:,:,trial] + Beta[b]* delta_M1out[:,:,trial] 
            #update weights from hidden M1 to output layer            
            W_M2O[:,:,trial+1]=W_M2O[:,:,trial]+Beta[b] * delta_M2out[:,:,trial]
            #compute delta hidden layer M1
            delta_M1[:,:,trial]=np.matmul(np.amax(Rate_Input_plus[:,:,trial],axis=1)[:,None],np.amax(Rate_M1_plus[:,:,trial],axis=1)[None,:])- np.matmul(np.amax(Rate_Input_min[:,:,trial,i,1],axis=1)[:,None],np.amax(Rate_M1_min[:,:,trial,i,0],axis=1)[None,:])
            #compute delta hidden layer M2
            delta_M2[:,:,trial]=np.matmul(np.amax(Rate_Input_plus[:,:,trial],axis=1)[:,None],np.amax(Rate_M2_plus[:,:,trial],axis=1)[None,:])- np.matmul(np.amax(Rate_Input_min[:,:,trial,i,1],axis=1)[:,None],np.amax(Rate_M2_min[:,:,trial,i,0],axis=1)[None,:])
            #update weights from input to hidden layer M1
            W_IM1[:,:,trial+1]=W_IM1[:,:,trial]+ Beta[b] * delta_M1[:,:,trial]
            #update weights from input to hidden layer M2
            W_IM2[:,:,trial+1]=W_IM2[:,:,trial]+ Beta[b] * delta_M2[:,:,trial]
        
            #check synchronization
            for p in range(nStim):
                for q in range(nM1):
                    #sync measure (cross correlation at phase lag zero)
                    sync_IM1[p,q,trial]=np.corrcoef((np.squeeze(Phase_Input_plus[p,0,0:time,trial])),(np.squeeze(Phase_M1_plus[q,0,0:time,trial])))[0,1]
                for M in range(nM2): 
                    #sync measure (cross correlation at phase lag zero)
                    sync_IM2[p,M,trial]=np.corrcoef((np.squeeze(Phase_Input_plus[p,0,0:time,trial]),np.squeeze(Phase_M2_plus[M,0,0:time,trial])))[0,1]

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
            
        data_pickle = "Beta"+str(b)+"_Rep"+str(r)+"_RBM_sync.p"

        variables_str = ["binned_Errorscore","binned_accuracy","sync_IM1","sync_IM2","S","LFC"]
        variables =     [binned_Errorscore, binned_accuracy,sync_IM1,sync_IM2,S,LFC]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)
