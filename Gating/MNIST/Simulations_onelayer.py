import numpy as np
import Dat as Dat
import model_onelayer_fun as mf

def Simulation(nContexts = 6, nRepeats = 3, Trial_percentage = 0.2, resources = 400, learning_rates = np.arange(0,0.11,0.01), Rep = 50, Model = 1):

    Order = np.arange(nContexts)
    Directory = "/Volumes/backupdisc/Modular_learning/Data_MNIST/Onelayer/"#"/data/gent/430/vsc43099/GatingModel_data/"

    for lr in learning_rates:
        for r in range(Rep):
            Data = Dat.preparation(nContexts, nRepeats, Trial_percentage, r)

            np.random.shuffle(Order)
            Contexts = np.zeros((nContexts, nContexts))
            for i in range(nContexts):
                Contexts[i, Order[i]]=1

            Objectives = np.zeros((nContexts, nRepeats, Data["Part_trials"]))
            for i in range(nContexts):
                Objectives[i,:,:]=Data["Objectives_C{}".format(Order[i]+1)]

            if Model ==0:
                Adapt_mult = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, True, resources)
                Adapt_mult["Contextorder"]=Order
                Adapt_mult["Overlap"]=Data["True_overlap"]
                Adapt_mult["Presented_numbers"]=Data["Number_labels"]
                print("Adaptive multiplicative model accuracy: {}".format(np.mean(Adapt_mult["Accuracy"])))
                np.save(Directory + "Adaptive_mult/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Adapt_mult)
            elif Model == 1:
                Nonadapt_mult = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, False, resources)
                Nonadapt_mult["Contextorder"]=Order
                Nonadapt_mult["Overlap"]=Data["True_overlap"]
                Nonadapt_mult["Presented_numbers"]=Data["Number_labels"]
                print("Non adaptive multiplicative model accuracy: {}".format(np.mean(Nonadapt_mult["Accuracy"])))
                np.save(Directory + "Non_adaptive_mult/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Nonadapt_mult)
            elif Model ==2:
                Adapt_add = mf.Model_additive(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, True, resources)
                Adapt_add["Contextorder"]=Order
                Adapt_add["Overlap"]=Data["True_overlap"]
                Adapt_add["Presented_numbers"]=Data["Number_labels"]
                print("Adaptive additive model accuracy: {}".format(np.mean(Adapt_add["Accuracy"])))
                np.save(Directory + "Adaptive_add/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Adapt_add)
            elif Model ==3:
                Nonadapt_add = mf.Model_additive(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, False, resources)
                Nonadapt_add["Contextorder"]=Order
                Nonadapt_add["Overlap"]=Data["True_overlap"]
                Nonadapt_add["Presented_numbers"]=Data["Number_labels"]
                print("Non adaptive additive model accuracy: {}".format(np.mean(Nonadapt_add["Accuracy"])))
                np.save(Directory + "Non_adaptive_add/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Nonadapt_add)

    return
