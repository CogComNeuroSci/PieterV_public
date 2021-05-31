import numpy as np
import model_fun_act as mf
import Dat as D
import os

def Simulation(nContexts = 5, nRepeats = 3, ntrep = 25, resources = 24, learning_rates = np.arange(0,1.1,0.1), Rep = 50, Model = 1):

    Order = np.arange(nContexts)
    Directory = "/Volumes/backupdisc/Modular_learning/Data_act/"

    for lr in learning_rates:
        for r in range(Rep):

            Data = D.preparation(nContexts, nRepeats, ntrep, r)

            np.random.shuffle(Order)
            Contexts = np.zeros((nContexts, nContexts))
            for i in range(nContexts):
                Contexts[i, Order[i]]=1

            Objectives = np.zeros((nContexts, Data["Part_trials"],3))
            for i in range(nContexts):
                Objectives[i,:,:]=Data["Objectives_C{}".format(Order[i]+1)]

            if Model ==0:
                sig_sig = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, resources, act=["sig","sig"])
                sig_sig["Contextorder"]=Order
                sig_sig["Overlap"]=Data["True_overlap"]
                print("Full sigmoid model accuracy: {}".format(np.mean(sig_sig["Accuracy"])))
                np.save(Directory + "SigSig/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), sig_sig)
            elif Model == 1:
                relu_relu = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, resources, act=["relu","relu"])
                relu_relu["Contextorder"]=Order
                relu_relu["Overlap"]=Data["True_overlap"]
                print("Full relu model accuracy: {}".format(np.mean(relu_relu["Accuracy"])))
                np.save(Directory + "RELURELU/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), relu_relu)
            elif Model ==2:
                relu_sig = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, resources, act=["relu","sig"])
                relu_sig["Contextorder"]=Order
                relu_sig["Overlap"]=Data["True_overlap"]
                print("RELU sig model accuracy: {}".format(np.mean(relu_sig["Accuracy"])))
                np.save(Directory + "RELUSIG/lr_{:.1f}_Rep_{:d}.npy".format(lr, r),relu_sig)
            elif Model ==3:
                sig_relu = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, resources, act=["sig","relu"])
                sig_relu["Contextorder"]=Order
                sig_relu["Overlap"]=Data["True_overlap"]
                print("Sig RELU model accuracy: {}".format(np.mean(sig_relu["Accuracy"])))
                np.save(Directory + "SIGRELU/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), sig_relu)

    return
