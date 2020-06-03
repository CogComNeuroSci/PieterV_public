#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 18:07:26 2018

@author: pieter
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 17:39:29 2018

@author: pieter
"""
import numpy as np
import pickle

Rep=10
betas=11
bins=60
Tr=2400

Accuracy_conn=np.zeros((bins,betas,Rep))
ERR_conn=np.zeros((bins,betas,Rep))
Accuracy_sync=np.zeros((bins,betas,Rep))
ERR_sync=np.zeros((bins,betas,Rep))
synchronization_IM1=np.zeros((6,4,Tr,betas,Rep))
synchronization_IM2=np.zeros((6,4,Tr,betas,Rep))
module=np.zeros((betas,Rep))
Switcher=np.zeros((Tr,betas,Rep))

for b in range(betas):
    for r in range(Rep):
        for i in range(2):
            myworkspaceconn = pickle.load(open("Beta"+str(b/10)+"_Rep"+str(r)+"_RBM_nosync.p", "rb"))
            
        Accuracy_conn[:,b,r]=np.array(list(myworkspaceconn[1].values()))*100
        ERR_conn[:,b,r]=np.array(list(myworkspaceconn[0].values()))
        
        for i in range(2):
            myworkspacesync = pickle.load(open("Beta"+str(b/10)+"_Rep"+str(r)+"_RBM_sync.p", "rb"))
        
        Accuracy_sync[:,b,r]=np.array(list(myworkspacesync[1].values()))*100
        ERR_sync[:,b,r]=np.array(list(myworkspacesync[0].values()))
        Switcher[:,b,r]=np.array(list(myworkspacesync[4].values()))
        synchronization_IM1[:,:,:,b,r]=np.array(list(myworkspacesync[2].values()))
        synchronization_IM2[:,:,:,b,r]=np.array(list(myworkspacesync[3].values()))
        LFC=np.array(list(myworkspacesync[5].values()))
        if LFC[0,0]==1:
            module[b,r]=1
        else:
            module[b,r]=2


mean_ACC_conn=np.mean(Accuracy_conn,axis=2)
mean_ERR_conn=np.mean(ERR_conn,axis=2)
CI_ACC_conn=2*np.std(Accuracy_conn,axis=2)/np.sqrt(Rep)
CI_ERR_conn=2*np.std(ERR_conn,axis=2)/np.sqrt(Rep)
overall_ACC_conn=np.mean(mean_ACC_conn,axis=0)
CI_all_acc_conn=2*np.std(np.mean(Accuracy_conn,axis=0),axis=2)/np.sqrt(Rep)

mean_ACC_sync=np.mean(Accuracy_sync,axis=2)
mean_ERR_sync=np.mean(ERR_sync,axis=2)
CI_ACC_sync=2*np.std(Accuracy_sync,axis=2)/np.sqrt(Rep)
CI_ERR_sync=2*np.std(ERR_sync,axis=2)/np.sqrt(Rep)
overall_ACC_sync=np.mean(mean_ACC_sync,axis=0)
CI_all_acc_sync=2*np.std(np.mean(Accuracy_sync,axis=0),axis=2)/np.sqrt(Rep)

#determine critical moments        
start=np.arange(0,5)            #first 5 trials
end_one=np.arange(15,20)        #last 5 trials before switch 1
Change_one=np.arange(20,25)     #first 5 trials after switch 1
end_two=np.arange(35,40)        #last 5 trials before switch 2
Change_two=np.arange(40,45)     #first 5 trials after switch 2
final=np.arange(55,60)          #last 5 trials    

#compute mean accuracy for these moments
A=np.mean(Accuracy_conn[start,:,:],axis=0)
B=np.mean(Accuracy_conn[Change_one,:,:],axis=0)
C=np.mean(Accuracy_conn[Change_two,:,:],axis=0)

sync_A=np.mean(Accuracy_sync[start,:,:],axis=0)
sync_B=np.mean(Accuracy_sync[Change_one,:,:],axis=0)
sync_C=np.mean(Accuracy_sync[Change_two,:,:],axis=0)

plasticity_sync=sync_B
plasticity_conn=B
stability_sync=sync_C-sync_B
stability_conn=C-B

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

#if you also want to analyse synchronization here
relevant_sync=np.zeros((2,Tr,betas,Rep))
for b in range(betas):
    for r in range(Rep):
        if module[b,r]==1:
            relevant_sync[0,:,b,r]=np.mean(np.mean(synchronization_IM1[:,:,:,b,r],axis=0),axis=0)
            relevant_sync[1,:,b,r]=np.mean(np.mean(synchronization_IM2[:,:,:,b,r],axis=0),axis=0)
        else:
            relevant_sync[0,:,b,r]=np.mean(np.mean(synchronization_IM2[:,:,:,b,r],axis=0),axis=0)
            relevant_sync[1,:,b,r]=np.mean(np.mean(synchronization_IM1[:,:,:,b,r],axis=0),axis=0)

mean_synchronization=np.mean(relevant_sync,axis=3)
CI_synchronization=2*np.std(relevant_sync,axis=3)/np.sqrt(Rep)