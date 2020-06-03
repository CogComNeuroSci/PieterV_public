#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  6 14:49:31 2018

@author: pieter
"""
import numpy as np
import pickle

# Defining amount of loops
Rep=10                          # amount of replications
T=500                           # trialtime
Tr=2400                         # amount of trials
betas=11                        # beta iterations
Beta=np.arange(0,1.1,0.1)       #learning rate values
ITI=250                         #intertrial interval

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
Cg=0.58                         #coupling gamma waves
damp=0.3                        #damping parameter
decay=0.9                       #decay parameter
bias=5                          #bias parameter

    #Control module  
r2_acc=0.05                     #radius ACC
Ct=0.07                         #coupling theta waves
damp_acc=0.003                   #damping parameter ACC
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
        Phase_Input=np.zeros((nStim,2,T+1,Tr))    #Phase neurons of input layer
        Rate_Input=np.zeros((nStim,T+1,Tr))       #rate neurons
        
        Phase_M1=np.zeros((nM1,2,T+1,Tr))         #Phase neurons of input layer
        Rate_M1=np.zeros((nM1,T+1,Tr))            #rate neurons        

        Phase_M2=np.zeros((nM2,2,T+1,Tr))         #Phase neurons of input layer
        Rate_M2=np.zeros((nM2,T+1,Tr))            #rate neurons  
        
        Phase_Out=np.zeros((nResp,2,T+1,Tr))      #Phase neurons of input layer
        Rate_Out=np.zeros((nResp,T+1,Tr))         #rate neurons
        
        net_M1=np.zeros((nM1,T,Tr))               #net_input received by hidden units M1
        net_M2=np.zeros((nM2,T,Tr))               #net_input received by hidden units M2
        net_Out=np.zeros((nResp,T,Tr))            #net_input received by output units
        
        #weights
        W_IM1=np.zeros((nStim,nM1,Tr+1))          #input to hidden M1
        W_IM2=np.zeros((nStim,nM2,Tr+1))          #input to hidden M2
        W_M1O=np.zeros((nM1,nResp,Tr+1))          #hidden M1 to output
        W_M2O=np.zeros((nM2,nResp,Tr+1))          #hidden M2 to output
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
        
        ACC=np.zeros((2,T+1,Tr))                  #ACC phase units
        Be=np.zeros((T,Tr))                     #Bernoulli (ACC rate)
        
        #Critic
        rew=np.zeros((1,Tr))                    #reward
        V=np.zeros((1,Tr))                      #value unit
        S=np.zeros((1,Tr+1))                      #switch unit
        E=np.zeros((nmod,Tr+1))                 #value weights
        E[:,0]=0.5                              #initial values
        negPE=np.zeros((1,Tr))                  #negative prediction error
        posPE=np.zeros((1,Tr))                  #positive prediciton error
        
        #learning
        Errorscore=np.zeros((nResp,Tr))         #errorscore
        delta_out=np.zeros((nResp,Tr))          #delta hidden to output layer
        delta_M1=np.zeros((nM1,Tr));            #delta input to hidden layer M1
        delta_M2=np.zeros((nM2,Tr));            #delta input to hidden layer M2
        
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
        Phase_Input[:,:,0,0]=start_Input
        Phase_M1[:,:,0,0]=start_M1
        Phase_M1[:,:,0,0]=start_M2
        Phase_Out[:,:,0,0]=start_Out
        ACC[:,0,0]=start_ACC
        
        #radius
        r2_Input=np.zeros((nStim,T,Tr))         
        r2_M1=np.zeros((nM1,T,Tr))
        r2_M2=np.zeros((nM2,T,Tr))
        r2_Out=np.zeros((nResp,T,Tr))
        r2_ACC=np.zeros((T,Tr))
        
        #recordings
        Z=np.zeros((nStim,Tr))                 #input matrix
        response=np.zeros((nResp,Tr))           #response record
        sync_IM1=np.zeros((nInput,nM1,Tr))      #sync matrix
        sync_IM2=np.zeros((nInput,nM2,Tr))
        Hit=np.zeros((T,Tr))                    #hit record

        # the model

        for trial in range(Tr):            #trial loop
            
            if trial>0:#starting points are end points previous trial
                Phase_Input[:,:,0,trial]=Phase_Input[:,:,time,trial-1]
                Phase_M1[:,:,0,trial]=Phase_M1[:,:,time,trial-1]
                Phase_M2[:,:,0,trial]=Phase_M2[:,:,time,trial-1]
                Phase_Out[:,:,0,trial]=Phase_Out[:,:,time,trial-1]
                ACC[:,0,trial]=ACC[:,time,trial-1]
            
            #input
            Z[:,trial]=Activation[:,int(Input[0,trial])]
            
            for time in range(ITI):
                
                #updating radius
                r2_Input[:,time,trial]=np.sum(Phase_Input[:,:,time,trial]*Phase_Input[:,:,time,trial],axis=1)    
                r2_M1[:,time,trial]=np.sum(Phase_M1[:,:,time,trial]*Phase_M1[:,:,time,trial],axis=1)  
                r2_M2[:,time,trial]=np.sum(Phase_M2[:,:,time,trial]*Phase_M2[:,:,time,trial],axis=1)  
                r2_Out[:,time,trial]=np.sum(Phase_Out[:,:,time,trial]*Phase_Out[:,:,time,trial],axis=1)  
                r2_ACC[time,trial]=np.sum(ACC[:,time,trial]*ACC[:,time,trial]) 
                
                #updating phase code units
                Phase_Input[:,0,time+1,trial]=Phase_Input[:,0,time,trial]-Cg*Phase_Input[:,1,time,trial]-damp*((r2_Input[:,time,trial]>r2max).astype(int))*Phase_Input[:,0,time,trial]  # excitatory cells
                Phase_Input[:,1,time+1,trial]=Phase_Input[:,1,time,trial]+Cg*Phase_Input[:,0,time,trial]-damp*((r2_Input[:,time,trial]>r2max).astype(int))*Phase_Input[:,1,time,trial]  # inhibitory cells
                
                Phase_M1[:,0,time+1,trial]=Phase_M1[:,0,time,trial]-Cg*Phase_M1[:,1,time,trial]-damp*((r2_M1[:,time,trial]>r2max).astype(int))*Phase_M1[:,0,time,trial]  # excitatory cells
                Phase_M1[:,1,time+1,trial]=Phase_M1[:,1,time,trial]+Cg*Phase_M1[:,0,time,trial]-damp*((r2_M1[:,time,trial]>r2max).astype(int))*Phase_M1[:,1,time,trial]  # inhibitory cells
                
                Phase_M2[:,0,time+1,trial]=Phase_M2[:,0,time,trial]-Cg*Phase_M2[:,1,time,trial]-damp*((r2_M2[:,time,trial]>r2max).astype(int))*Phase_M2[:,0,time,trial]  # excitatory cells
                Phase_M2[:,1,time+1,trial]=Phase_M2[:,1,time,trial]+Cg*Phase_M2[:,0,time,trial]-damp*((r2_M2[:,time,trial]>r2max).astype(int))*Phase_M2[:,1,time,trial]  # inhibitory cells
                
                Phase_Out[:,0,time+1,trial]=Phase_Out[:,0,time,trial]-Cg*Phase_Out[:,1,time,trial]-damp*((r2_Out[:,time,trial]>r2max).astype(int))*Phase_Out[:,0,time,trial]  # excitatory cells
                Phase_Out[:,1,time+1,trial]=Phase_Out[:,1,time,trial]+Cg*Phase_Out[:,0,time,trial]-damp*((r2_Out[:,time,trial]>r2max).astype(int))*Phase_Out[:,1,time,trial]  # inhibitory cells
                                                                                                #radius ACC
                ACC[0,time+1,trial]=ACC[0,time,trial]-Ct*ACC[1,time,trial]-damp_acc*(r2_ACC[time,trial]>r2_acc).astype(int)*ACC[0,time,trial]                              # ACC exc cell
                ACC[1,time+1,trial]=ACC[1,time,trial]+Ct*ACC[0,time,trial]-damp_acc*(r2_ACC[time,trial]>r2_acc).astype(int)*ACC[1,time,trial]                              # ACC inh cell
                
                if trial>0:
                    if negPE[0,trial-1]>0: 
                        Be_ACC=np.exp(-(time-100)**2/(2*12.5**2))
                        prob_ACC=np.random.random()
                        if prob_ACC< Be_ACC:
                            Gaussian_ACC=np.random.normal(2,1)
                            ACC[:,time+1,trial]=decay*ACC[:,time,trial]-negPE[0,trial-1]*Gaussian_ACC
                            
                #bernoulli process in ACC rate
                Be[time,trial]=1/(1+np.exp(-acc_slope*(ACC[0,time,trial]-1)))
                prob=np.random.random()
            
                #burst
                if prob<Be[time,trial]:
                    Hit[time,trial]=1
                    Gaussian=np.random.normal(size=[1,2])
                    Phase_Input[:,:,time+1,trial]=decay*Phase_Input[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nStim,1)),Gaussian)
                    Phase_M1[:,:,time+1,trial]=decay*Phase_M1[:,:,time,trial]+np.matmul(LFC[0,trial]*np.ones((nM1,1)),Gaussian)
                    Phase_M2[:,:,time+1,trial]=decay*Phase_M2[:,:,time,trial]+np.matmul(LFC[1,trial]*np.ones((nM2,1)),Gaussian)
                    Phase_Out[:,:,time+1,trial]=decay*Phase_Out[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nResp,1)),Gaussian)
            
            for time in range(ITI,T):
                
                #updating radius
                r2_Input[:,time,trial]=np.sum(Phase_Input[:,:,time,trial]*Phase_Input[:,:,time,trial],axis=1)    
                r2_M1[:,time,trial]=np.sum(Phase_M1[:,:,time,trial]*Phase_M1[:,:,time,trial],axis=1)  
                r2_M2[:,time,trial]=np.sum(Phase_M2[:,:,time,trial]*Phase_M2[:,:,time,trial],axis=1)  
                r2_Out[:,time,trial]=np.sum(Phase_Out[:,:,time,trial]*Phase_Out[:,:,time,trial],axis=1)  
                r2_ACC[time,trial]=np.sum(ACC[:,time,trial]*ACC[:,time,trial]) 
                
                #updating phase code units
                Phase_Input[:,0,time+1,trial]=Phase_Input[:,0,time,trial]-Cg*Phase_Input[:,1,time,trial]-damp*((r2_Input[:,time,trial]>r2max).astype(int))*Phase_Input[:,0,time,trial]  # excitatory cells
                Phase_Input[:,1,time+1,trial]=Phase_Input[:,1,time,trial]+Cg*Phase_Input[:,0,time,trial]-damp*((r2_Input[:,time,trial]>r2max).astype(int))*Phase_Input[:,1,time,trial]  # inhibitory cells
                
                Phase_M1[:,0,time+1,trial]=Phase_M1[:,0,time,trial]-Cg*Phase_M1[:,1,time,trial]-damp*((r2_M1[:,time,trial]>r2max).astype(int))*Phase_M1[:,0,time,trial]  # excitatory cells
                Phase_M1[:,1,time+1,trial]=Phase_M1[:,1,time,trial]+Cg*Phase_M1[:,0,time,trial]-damp*((r2_M1[:,time,trial]>r2max).astype(int))*Phase_M1[:,1,time,trial]  # inhibitory cells
                
                Phase_M2[:,0,time+1,trial]=Phase_M2[:,0,time,trial]-Cg*Phase_M2[:,1,time,trial]-damp*((r2_M2[:,time,trial]>r2max).astype(int))*Phase_M2[:,0,time,trial]  # excitatory cells
                Phase_M2[:,1,time+1,trial]=Phase_M2[:,1,time,trial]+Cg*Phase_M2[:,0,time,trial]-damp*((r2_M2[:,time,trial]>r2max).astype(int))*Phase_M2[:,1,time,trial]  # inhibitory cells
                
                Phase_Out[:,0,time+1,trial]=Phase_Out[:,0,time,trial]-Cg*Phase_Out[:,1,time,trial]-damp*((r2_Out[:,time,trial]>r2max).astype(int))*Phase_Out[:,0,time,trial]  # excitatory cells
                Phase_Out[:,1,time+1,trial]=Phase_Out[:,1,time,trial]+Cg*Phase_Out[:,0,time,trial]-damp*((r2_Out[:,time,trial]>r2max).astype(int))*Phase_Out[:,1,time,trial]  # inhibitory cells
                                                                                                #radius ACC
                ACC[0,time+1,trial]=ACC[0,time,trial]-Ct*ACC[1,time,trial]-damp_acc*(r2_ACC[time,trial]>r2_acc).astype(int)*ACC[0,time,trial]                              # ACC exc cell
                ACC[1,time+1,trial]=ACC[1,time,trial]+Ct*ACC[0,time,trial]-damp_acc*(r2_ACC[time,trial]>r2_acc).astype(int)*ACC[1,time,trial]                              # ACC inh cell
            
                #bernoulli process in ACC rate
                Be[time,trial]=1/(1+np.exp(-acc_slope*(ACC[0,time,trial]-1)))
                prob=np.random.random()
            
                #burst
                if prob<Be[time,trial]:
                    Hit[time,trial]=1
                    Gaussian=np.random.normal(size=[1,2])
                    Phase_Input[:,:,time+1,trial]=decay*Phase_Input[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nStim,1)),Gaussian)
                    Phase_M1[:,:,time+1,trial]=decay*Phase_M1[:,:,time,trial]+np.matmul(LFC[0,trial]*np.ones((nM1,1)),Gaussian)
                    Phase_M2[:,:,time+1,trial]=decay*Phase_M2[:,:,time,trial]+np.matmul(LFC[1,trial]*np.ones((nM2,1)),Gaussian)
                    Phase_Out[:,:,time+1,trial]=decay*Phase_Out[:,:,time,trial]+np.matmul(LFC[2,trial]*np.ones((nResp,1)),Gaussian)
                        
                #updating rate code units
                Rate_Input[:,time,trial]=Z[:,trial] *(1/(1+np.exp(-5*(Phase_Input[:,0,time,trial]-0.6)))) 
                
                net_M1[:,time,trial]=np.matmul(np.transpose(W_IM1[:,:,trial]),Rate_Input[:,time,trial])-bias
                Rate_M1[:,time+1,trial]=(1/(1+np.exp(-net_M1[:,time,trial])))*(1/(1+np.exp(-5*(Phase_M1[:,0,time,trial]-0.6)))) 
                
                net_M2[:,time,trial]=np.matmul(np.transpose(W_IM2[:,:,trial]),Rate_Input[:,time,trial])-bias
                Rate_M2[:,time+1,trial]=(1/(1+np.exp(-net_M2[:,time,trial])))*(1/(1+np.exp(-5*(Phase_M2[:,0,time,trial]-0.6))))
                
                net_Out[:,time,trial]=np.matmul(np.transpose(W_M1O[:,:,trial]),Rate_M1[:,time,trial]) + np.matmul(np.transpose(W_M2O[:,:,trial]),Rate_M2[:,time,trial]) -bias
                Rate_Out[:,time+1,trial]=(1/(1+np.exp(-net_Out[:,time,trial])))*(1/(1+np.exp(-5*(Phase_Out[:,0,time,trial]-0.6))))
        
            #response determination
            if np.amax(Rate_Out[0,:,trial])>np.amax(Rate_Out[1,:,trial]):
                response[0,trial]=1
            else:
                response[1,trial]=1

            #reward value determination
            if np.all(response[:,trial]==objective[:,int(Input[0,trial]),trial]):
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
            Errorscore[:,trial]=(objective[:,int(Input[0,trial]),trial]-(np.amax(Rate_Out[:,:,trial],axis=1)))**2
            #compute delta_output
            delta_out[:,trial]=(objective[:,int(Input[0,trial]),trial]-(np.amax(Rate_Out[:,:,trial],axis=1))) * (np.amax(Rate_Out[:,:,trial],axis=1)) * (1-(np.amax(Rate_Out[:,:,trial],axis=1)))
            #update weights from hidden M1 to output layer
            W_M1O[:,:,trial+1]=W_M1O[:,:,trial] + Beta[b]* (np.matmul(np.amax(Rate_M1[:,:,trial],axis=1)[:,None], delta_out[:,trial][None,:])) 
            #update weights from hidden M1 to output layer            
            W_M2O[:,:,trial+1]=W_M2O[:,:,trial]+Beta[b] * (np.matmul(np.amax(Rate_M2[:,:,trial],axis=1)[:,None], delta_out[:,trial][None,:]))
            #compute delta hidden layer M1
            delta_M1[:,trial]=np.matmul(delta_out[:,trial][None,:],np.transpose(W_M1O[:,:,trial])) * np.amax(Rate_M1[:,:,trial],axis=1) * (1-np.amax(Rate_M1[:,:,trial],axis=1))
            #compute delta hidden layer M2
            delta_M2[:,trial]=np.matmul(delta_out[:,trial][None,:],np.transpose(W_M2O[:,:,trial])) * np.amax(Rate_M2[:,:,trial],axis=1) * (1-np.amax(Rate_M2[:,:,trial],axis=1))
            #update weights from input to hidden layer M1
            W_IM1[:,:,trial+1]=W_IM1[:,:,trial]+ Beta[b] * np.matmul(np.amax(Rate_Input[:,:,trial],axis=1)[:,None], delta_M1[:,trial][None,:])
            #update weights from input to hidden layer M2
            W_IM2[:,:,trial+1]=W_IM2[:,:,trial]+ Beta[b] * np.matmul(np.amax(Rate_Input[:,:,trial],axis=1)[:,None], delta_M2[:,trial][None,:])
        
            #check synchronization
            for p in range(nStim):
                for q in range(nM1):
                    #sync measure (cross correlation at phase lag zero)
                    sync_IM1[p,q,trial]=np.corrcoef((np.squeeze(Phase_Input[p,0,0:time,trial])),(np.squeeze(Phase_M1[q,0,0:time,trial])))[0,1]
                for M in range(nM2): 
                    #sync measure (cross correlation at phase lag zero)
                    sync_IM2[p,M,trial]=np.corrcoef((np.squeeze(Phase_Input[p,0,0:time,trial]),np.squeeze(Phase_M2[M,0,0:time,trial])))[0,1]

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
        
        data_pickle = "Beta"+str(b)+"_Rep"+str(r)+"_backprop_sync.p"

        variables_str = ["binned_Errorscore","binned_accuracy","sync_IM1","sync_IM2","S","LFC"]
        variables =     [binned_Errorscore, binned_accuracy,sync_IM1,sync_IM2,S,LFC]
        data = []
        for loop in range(len(variables)):
            data.append({variables_str[loop]: variables[loop]})
            #print(data)
            pickle.dump(data,open(data_pickle,"wb"))
            #myworkspacetoo = pickle.load(open(data_pickle, "rb"))
            #print(myworkspacetoo)
    