import numpy as np
from   multiprocessing import Process, Pool
import Generalization_prepare as P
import Gen_twolayer_fun as T

Dir = "/Volumes/backupdisc/Modular_learning/Data_MNIST/"#"/data/gent/430/vsc43099/GatingModel_data/"
Models = ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]

cp = len(Models)
worker_pool = []

learning_rates = np.arange(0,0.11,0.01)
Rep = 50

def Gen_fun(core=0):
    done = False

    i=-1
    for lr in learning_rates:
        i+=1
        Result_dictionary={
            "Accuracy": np.zeros((Rep, 6, 500)),
            "Activation": np.zeros((Rep, 402, 6, 500)),
            "Contextorder": np.zeros((Rep, 6)),
            "Labels": np.zeros((Rep, 500)),
            "Overlap": np.zeros((Rep, 6,6))
            }
        for r in range(Rep):

            Dat = P.Generalization_preparation(nContexts = 6, Directory = Dir, Model=Models[core], Trial_percentage = 0.05, lr=lr, r=r)

            if core<2:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Hidden_weights"], Dat["Output_weights"], Dat["CorResp"])
            else:
                Result = T.Generalization_additive(Dat["Inputs"], Dat["Contexts"], Dat["Input_weights"], Dat["Hidden_weights"], Dat["Output_weights"], Dat["CorResp"])

            Result_dictionary["Accuracy"][r, :, :] = Result["accuracy"]
            Result_dictionary["Activation"][r, :, :, :] = Result["activation"]
            Result_dictionary["Contextorder"][r, :] = Dat["Order"]
            Result_dictionary["Labels"][r, :] = Dat["Number_labels"]
            Result_dictionary["Overlap"][r, :] = Dat["Overlap"]

        np.save(Dir + Models[core] + "/Generalization_data_lr_{:.2f}".format(lr), Result_dictionary)

    print("Generalization_accuracy of model " + Models[core] + " is:")
    print(np.mean(Result_dictionary["Accuracy"]))

    done = True

    return done

with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
