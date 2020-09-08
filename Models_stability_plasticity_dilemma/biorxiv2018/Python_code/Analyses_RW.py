#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 13:27:23 2018

@author: pieter
"""
import numpy as np
import pickle
import scipy
from scipy.signal import hilbert
from scipy.stats import pearsonr

betas=11
Rep=10
Tr=240

Accuracy_conn=np.zeros((Tr,betas,Rep))               #accuracy variable
Weights_conn=np.zeros((4,4,Tr+1,betas,Rep))          #weights variable

Accuracy_sync=np.zeros((Tr,betas,Rep))                 #accuracy variable
Weights_sync=np.zeros((6,6,Tr+1,betas,Rep))            #weights variable

Gamma=np.zeros((6,2,500,Tr,betas,Rep))                #gamma waves for pac measure 
Theta=np.zeros((2,500,Tr,betas,Rep))                  #theta waves for pac measure
Synchronization=np.zeros((4,4,Tr,betas,Rep))           #synchronization
module=np.zeros((betas,Rep))
Switcher=np.zeros((Tr+1,betas,Rep))

#load all data
for b in range(betas):
    for r in range(Rep):
        for i in range(3):
            myworkspaceconn = pickle.load(open("Beta"+str(b/10)+"_Rep"+str(r)+"_RWonly.p", "rb"))
        
        Accuracy_conn[:,b,r]=np.array(list(myworkspaceconn[1].values()))
        Weights_conn[:,:,:,b,r]=np.array(list(myworkspaceconn[2].values()))
        
        for i in range(6):
            myworkspacesync = pickle.load(open("Beta"+str(b/10)+"_Rep"+str(r)+"_RWsync.p", "rb"))
        
        Gamma[:,:,:,:,b,r]=np.array(list(myworkspacesync[0].values()))
        Theta[:,:,:,b,r]=np.array(list(myworkspacesync[1].values()))
        Synchronization[:,:,:,b,r]=np.array(list(myworkspacesync[2].values()))
        Accuracy_sync[:,b,r]=np.array(list(myworkspacesync[4].values()))
        Weights_sync[:,:,:,b,r]=np.array(list(myworkspacesync[5].values()))
        
#compute mean accuracy

#nosync
#trial by trial
mean_accuracy_conn=np.mean(Accuracy_conn,axis=2)*100
std_accuracy_conn=np.std((Accuracy_conn*100),axis=2)
CI_accuracy_conn=2*(std_accuracy_conn/np.sqrt(Rep))
#total
mean_ACC_conn=np.mean(mean_accuracy_conn,axis=0)
CI_ACC_conn=(2*(np.std(np.mean(Accuracy_conn,axis=0),axis=1))/np.sqrt(Rep))*100

#sync
#trial by trial
mean_accuracy_sync=np.mean(Accuracy_sync,axis=2)*100
std_accuracy_sync=np.std((Accuracy_sync*100),axis=2)
CI_accuracy_sync=2*(std_accuracy_sync/np.sqrt(Rep)) 
#total
mean_ACC_sync=np.mean(mean_accuracy_sync,axis=0)
CI_ACC_sync=(2*(np.std(np.mean(Accuracy_sync,axis=0),axis=1))/np.sqrt(Rep))*100
       
#determine critical moments        
start=np.arange(60,80)            #first 5 trials
Change_one=np.arange(80,100)     #first 5 trials after switch 1
Change_two=np.arange(160,180)     #first 5 trials after switch 2 

#compute mean accuracy for these moments
A=np.mean(Accuracy_conn[start,:,:],axis=0)
B=np.mean(Accuracy_conn[Change_one,:,:],axis=0)
C=np.mean(Accuracy_conn[Change_two,:,:],axis=0)

sync_A=np.mean(Accuracy_sync[start,:,:],axis=0)
sync_B=np.mean(Accuracy_sync[Change_one,:,:],axis=0)
sync_C=np.mean(Accuracy_sync[Change_two,:,:],axis=0)

plasticity_sync=sync_B
plasticity_conn=B
stability_sync=sync_C-sync_A
stability_conn=C-A

mean_plas_sync=np.mean(plasticity_sync,axis=1)*100
std_plas_sync=np.std(plasticity_sync,axis=1)
CI_plas_sync=(2*std_plas_sync/np.sqrt(Rep))*100
mean_stab_sync=np.mean(stability_sync,axis=1)*100
std_stab_sync=np.std(stability_sync,axis=1)
CI_stab_sync=(2*std_stab_sync/np.sqrt(Rep))*100

mean_plas_conn=np.mean(plasticity_conn,axis=1)*100
std_plas_conn=np.std(plasticity_conn,axis=1);
CI_plas_conn=(2*std_plas_conn/np.sqrt(Rep))*100
mean_stab_conn=np.mean(stability_conn,axis=1)*100
std_stab_conn=np.std(stability_conn,axis=1)
CI_stab_conn=(2*std_stab_conn/np.sqrt(Rep))*100   

mean_sync=np.mean(Synchronization,axis=4)
std_sync=np.std(Synchronization,axis=4)
CI_sync=2*std_sync/np.sqrt(Rep)
sync_rule1=(mean_sync[0,2,:,:]+mean_sync[1,3,:])/2
sync_rule2=(mean_sync[1,2,:,:]+mean_sync[0,3,:])/2
CI_sync_rule1=(CI_sync[0,2,:,:]+CI_sync[1,3,:,:])/2
CI_sync_rule2=(CI_sync[1,2,:,:]+CI_sync[0,3,:,:])/2

mean_weights_sync=np.mean(Weights_sync,axis=4)
std_weights_sync=np.std(Weights_sync,axis=4)
CI_weights_sync=2*std_weights_sync/np.sqrt(Rep)
weights_rule1_sync=(mean_weights_sync[0,2,:,:]+mean_weights_sync[1,3,:,:])/2
weights_rule2_sync=(mean_weights_sync[1,2,:,:]+mean_weights_sync[0,3,:,:])/2
CI_weights_rule1_sync=(CI_weights_sync[0,2,:,:]+CI_weights_sync[1,3,:,:])/2
CI_weights_rule2_sync=(CI_weights_sync[1,2,:,:]+CI_weights_sync[0,3,:,:])/2

mean_weights_conn=np.mean(Weights_conn,axis=4)
std_weights_conn=np.std(Weights_conn,axis=4)
CI_weights_conn=2*std_weights_conn/np.sqrt(Rep) 
weights_rule1_conn=(mean_weights_conn[0,2,:,:]+mean_weights_conn[1,3,:,:])/2
weights_rule2_conn=(mean_weights_conn[1,2,:,:]+mean_weights_conn[0,3,:,:])/2     
CI_weights_rule1_conn=(CI_weights_conn[0,2,:,:]+CI_weights_conn[1,3,:,:])/2
CI_weights_rule2_conn=(CI_weights_conn[1,2,:,:]+CI_weights_conn[0,3,:,:])/2 

#extract gamma-amplitude
relevant_Gamma=np.zeros((3000,Tr,betas,Rep))
for beta in range(betas):              #time,trial,rep
    for rep in range(Rep):
        for tr in range(Tr):
             relevant_Gamma[:,tr,beta,rep]=np.sum(abs(Gamma[:,0,:,tr,beta,rep]),axis=0)

#extract theta-phase
Theta_Phase=np.zeros((3000,Tr,betas,Rep))
for beta in range(betas):              #time,trial,rep
    for rep in range(Rep):
        for tr in range(Tr):
            #note we only extract phase until reaction time (after this oscillatory activation stops)
            Theta_Phase[:,tr,beta,rep]=np.angle(scipy.signal.hilbert(Theta[0,:,tr,beta,rep]))

#actual pac measure (dpac(Van driel et al., 2015))
dpac=np.zeros((Tr,betas,Rep))
for beta in range(betas):              #time,trial,rep
    for rep in range(Rep):
        for tr in range(Tr):
            #note again only data until reaction time is taken
            dpac[tr,beta,rep]=abs(np.mean((np.exp(1j*Theta_Phase[:,tr,beta,rep])-np.mean(np.exp(1j*Theta_Phase[:,tr,beta,rep])))*relevant_Gamma[:,tr,beta,rep]))


# compute mean, std and 95% CI
mean_pac=np.mean(dpac,axis=2)
std_pac=np.std(dpac,axis=2)
CI_pac=(2*std_pac)/np.sqrt(Rep)


ERN_dat=np.zeros(750,Tr*betas*Rep);
corr_dat=np.zeros(750,Tr*betas*Rep);
ERN_sim=np.zeros(750,betas,Rep);

prev_err=0
err=0
corr=0
for b in range(betas):
    for r in range(Rep):
        bet_err=0;
        for tr in range(1,240):
            if Accuracy_sync[tr-1,b,r]==1:
                corr_dat[:,corr]=np.concatenate(Theta[0,250:500,tr-1,b,r], Theta[0,0:500,tr,b,r])  
                corr=+1
            else:
                ERN_dat[:,err]=np.concatenate(Theta[1,250:500,tr-1,b,r], Theta[1,0:500,tr,b,r]) 
                err=+1
                bet_err=+1

        ERN_sim[:,b,r]=np.squeeze(np.mean(ERN_dat[:,prev_err:prev_err+bet_err],axis=1))
        prev_err=prev_err+bet_err

ERN_dat=ERN_dat[:,0:err]
corr_dat=corr_dat[:,0:corr]
ERN_all=np.mean(ERN_dat,axis=1)
ERN_lr=np.squeeze(np.mean(ERN_sim,axis=2))
CI_ernlr=2*np.std(ERN_sim,axis=2)/np.sqrt(Rep)

#for time-frequency, see matlab code