#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  6 09:50:56 2018

@author: pieter
"""
import numpy as np

# Defining amount of loops
T=500                           # trialtime: 1 timestep = 2ms so a trial is here 500 X 2 ms= 1 sec
Tr=60                           # amount of trials

#model build-up
    #Processing module
nUnits=4                        #model units: 4 nodes in the network: 2 stimuli and 2 response options
r2max=1                         #max amplitude for the oscillations
Cg=0.58                         #coupling gamma waves: de coupling parameter for gamma-oscillations (equation 1 en 2 in biorxiv paper)

###############################################################################

# Note: here stimuli and responses have the exact same frequency:
# once synchronized they stay that way forever.

###############################################################################

damp=0.3                        #damping parameter: parameter D in equation 1 and 2 of paper
decay=0.9                       #decay parameter:
    #Control module
Ct=0.07                         #coupling theta waves: for theta frequency

MFC_slope=10                                #MFC_slope: see equation 11 in paper

#Input patterns
Activation=np.zeros((nUnits,2))             #possible activations:
Activation[:,0]=np.array([1,0,0,0])         # 4 nodes of which first one is activated = presenting stimulus 1
Activation[:,1]=np.array([0,1,0,0])         # 4 nodes of which second one is activated = presenting stimulus 2
# other 2 units are responses

# model initialization
#processing layer
Phase=np.zeros((nUnits,2,T+1,Tr))           #Phase neurons: I en E in figure 5 paper
Rate=np.zeros((nUnits,T+1,Tr))              #rate neurons: X in figure 5 paper

#weights
W=np.zeros((nUnits,nUnits))
W[0:2,2:4]=np.random.random((2,2))          #initial weigth strengths

#Control module
LFC=np.zeros((nUnits,1))                    #LFC units
LFC[0,0]=1                                  #Here I always synchronize 1 and 3 and also 2 en 4.
LFC[1,0]=-1                                 #Note that the pairs are orthogonal to each other (1 and -1)
LFC[2,0]=1
LFC[3,0]=-1

MFC=np.zeros((2,T+1,Tr))                  #MFC phase units
Be=np.zeros((T+1,Tr))                     #Bernoulli (MFC rate)

# Input
#randomization of input patterns
In=np.tile([0,1],(1,Tr))
Input=np.zeros((1,Tr))
Input[0,:]=In[0,np.random.permutation(Tr)]

# Other
#starting points of oscillations: only for trial 1 they start at random point
start=np.random.random((nUnits,2))          #draw random starting points
start_MFC=np.random.random((2))             #MFC starting points
#assign starting values
Phase[:,:,0,0]=start
MFC[:,0,0]=start_MFC

r2=np.zeros((nUnits+1,T,Tr))            #radius (see again equation 1 and 2)

#recordings
Z=np.zeros((nUnits,Tr))                 #input matrix
response=np.zeros((1,Tr))               #response record
corr=np.zeros((1,Tr))                   #MFCuracy record
Hit=np.zeros((T,Tr))                    #burst record

# the model

for trial in range(Tr):            #trial loop

    if trial>0:#starting points oscillations at new trial are end points previous trial
        Phase[:,:,0,trial]=Phase[:,:,time,trial-1]
        MFC[:,0,trial]=MFC[:,time,trial-1]

    #input
    Z[:,trial]=Activation[:,int(Input[0,trial])]

    for time in range(T):

        #updating phase code units
        r2[0:nUnits,time,trial]=np.sum(Phase[:,:,time,trial]*Phase[:,:,time,trial],axis=1)                                                                     #radius = dot product
        Phase[:,0,time+1,trial]=Phase[:,0,time,trial]-Cg*Phase[:,1,time,trial]-damp*(r2[0:nUnits,time,trial]>r2max).astype(int)*Phase[:,0,time,trial]          # excitatory cells (equation 1)
        Phase[:,1,time+1,trial]=Phase[:,1,time,trial]+Cg*Phase[:,0,time,trial]-damp*(r2[0:nUnits,time,trial]>r2max).astype(int)*Phase[:,1,time,trial]          # inhibitory cells (equation 2)

        #updating phase code units in MFC
        r2[nUnits,time,trial]=np.sum(MFC[:,time,trial]*MFC[:,time,trial])                                                                                #radius MFC
        MFC[0,time+1,trial]=MFC[0,time,trial]-Ct*MFC[1,time,trial]-damp*(r2[nUnits,time,trial]>r2max).astype(int)*MFC[0,time,trial]                      # MFC exc cell (equation 1 with adapted parameters)
        MFC[1,time+1,trial]=MFC[1,time,trial]+Ct*MFC[0,time,trial]-damp*(r2[nUnits,time,trial]>r2max).astype(int)*MFC[1,time,trial]                      # MFC inh cell (equation 2 with adapted parameters)

        #bernoulli process in MFC rate
        Be[time,trial]=1/(1+np.exp(-MFC_slope*(MFC[0,time,trial]-1))) #equation 11
        prob=np.random.random()

        #burst
        if prob<Be[time,trial]: #equation 10
            Hit[time,trial]=1
            Gaussian=np.random.normal(size=[1,2])
            Phase[:,:,time+1,trial]=decay*Phase[:,:,time,trial]+np.matmul(LFC,Gaussian) #This is the burst: Phase + MFC (1) * LFC *N

        #equation 4
        Rate[:,time+1,trial]=(Z[:,trial]+ np.matmul(np.transpose(Rate[:,time,trial]),W[:,:]))*(1/(1+np.exp(-5*(Phase[:,0,time,trial]-0.6))))


    #end of trial time loop

    #determine response: the response node with highest (mean) activation
    maxi=np.mean(Rate[2::,:,trial],axis=1)
    rid=np.argmax(maxi)
    if rid==0:
        response[0,trial]=0
    else:
        response[0,trial]=1

    # is response correct?
    if Input[0,trial]==response[0,trial]:
        corr[0,trial]=1
    else:
        corr[0,trial]=0
