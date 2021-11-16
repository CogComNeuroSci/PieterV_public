from Model_functions import model_sim_fun_initialize as mf

import numpy as np

def Simulation(nContexts = 5, nRepeats = 3, ntrep = 25, resources = 24, learning_rates = np.arange(0,1.1,0.1), Rep = [0,30], Model = 1, Directory = "/Volumes/backupdisc/Modular_learning/Data_Stroop/Revision/", mout=False, dat="Stroop"):
    if dat == "Stroop":
        from Preparation_functions import Prep_Stroop_Sim as D
    elif dat == "Trees":
        from Preparation_functions import Prep_Trees_Sim as D
    else:
        from Preparation_functions import Prep_MNIST_Sim as D
        data_dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/"#"/data/gent/430/vsc43099/GatingModel_data/"#
        datdict = np.load(data_dir + "data_MNIST.npy", allow_pickle = True)
        x_train = datdict[()]["x_train"]
        y_train = datdict[()]["y_train"]
        del datdict

    Order = np.arange(nContexts)
    for initial in ["normal", "uniform"]:
        for lr in learning_rates:
            for r in range(Rep[0],Rep[1]):

            #Prepare data
            if dat =="MNIST":
                Data = D.preparation(nContexts, nRepeats, ntrep, r, x_train, y_train)
            else:
                Data = D.preparation(nContexts, nRepeats, ntrep, r)

                #Shuffle context order, seed for replicability
                np.random.seed(r)
                np.random.shuffle(Order)

                #Determine context activation and learning objectives based on contextorder
                Contexts = np.zeros((nContexts, nContexts))
                for i in range(nContexts):
                    Contexts[i, Order[i]]=1

                if mout:
                    Objectives = np.zeros((nContexts, Data["Part_trials"],3))
                else:
                    Objectives = np.zeros((nContexts, nRepeats, Data["Part_trials"]))

                for i in range(nContexts):
                    Objectives[i,:,:]=Data["Objectives_C{}".format(Order[i]+1)]

                #Simulate 4 types of models and add contextorder and true overlap to data
                if Model ==0:
                    Adapt_mult = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, True, resources, mout, initial)
                    Adapt_mult["Contextorder"]=Order
                    Adapt_mult["Overlap"]=Data["True_overlap"]
                    Adapt_mult["Presented"]=Data["Stim_labels"]
                    print("Adaptive multiplicative model accuracy: {}".format(np.mean(Adapt_mult["Accuracy"])))
                    np.save(Directory + "Adaptive_mult/" + initial + "_lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Adapt_mult)
                elif Model == 1:
                    Nonadapt_mult = mf.Model_multiplicative(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, False, resources, mout, initial)
                    Nonadapt_mult["Contextorder"]=Order
                    Nonadapt_mult["Overlap"]=Data["True_overlap"]
                    Nonadapt_mult["Presented"]=Data["Stim_labels"]
                    print("Non adaptive multiplicative model accuracy: {}".format(np.mean(Nonadapt_mult["Accuracy"])))
                    np.save(Directory + "Non_adaptive_mult/" + initial + "_lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Nonadapt_mult)
                elif Model ==2:
                    Adapt_add = mf.Model_additive(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, True, resources, mout, initial)
                    Adapt_add["Contextorder"]=Order
                    Adapt_add["Overlap"]=Data["True_overlap"]
                    Adapt_add["Presented"]=Data["Stim_labels"]
                    print("Adaptive additive model accuracy: {}".format(np.mean(Adapt_add["Accuracy"])))
                    np.save(Directory + "Adaptive_add/" + initial + "_lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Adapt_add)
                elif Model ==3:
                    Nonadapt_add = mf.Model_additive(Data["Inputs"], Contexts, Objectives, nRepeats, Data["Part_trials"], lr, False, resources, mout, initial)
                    Nonadapt_add["Contextorder"]=Order
                    Nonadapt_add["Overlap"]=Data["True_overlap"]
                    Nonadapt_add["Presented"]=Data["Stim_labels"]
                    print("Non adaptive additive model accuracy: {}".format(np.mean(Nonadapt_add["Accuracy"])))
                    np.save(Directory + "Non_adaptive_add/" + initial + "_lr_{:.2f}_Rep_{:d}.npy".format(lr, r), Nonadapt_add)

    return
