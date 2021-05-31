import numpy as np
from   multiprocessing import Process, Pool
import Generalization_prep as P
import Generalization_fun as T

resources = 24
Dir = "/Volumes/backupdisc/Modular_learning/Data_act/"
Models = ["SIGSIG", "RELURELU", "SIGRELU", "RELUSIG"]

cp = len(Models)
worker_pool = []

learning_rates = np.arange(0,1.1,0.1)
Rep = 50

Result_dictionary={
    "Accuracy": np.zeros((np.size(learning_rates),Rep, 5, 90)),
    "Activation": np.zeros((np.size(learning_rates),Rep, resources+1, 5, 90)),
    "Contextorder": np.zeros((np.size(learning_rates),Rep, 5)),
    "Overlap": np.zeros((np.size(learning_rates),Rep, 5,5))
    }

def Gen_fun(core=0):
    done = False

    i=-1
    for lr in learning_rates:
        i+=1
        for r in range(Rep):

            Dat = P.Generalization_preparation(nContexts=5, Directory = Dir, Model=Models[core], ntrep=5, lr=lr, r=r, resources=resources)

            if core==0:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], act=["sig","sig"])
            elif core ==1:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], act=["relu","relu"])
            elif core ==2:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], act=["sig","relu"])
            else:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], act=["relu","sig"])

            Result_dictionary["Accuracy"][i,r, :, :] = Result["accuracy"]
            Result_dictionary["Activation"][i,r, :, :, :] = Result["activation"]
            Result_dictionary["Contextorder"][i,r, :] = Dat["Order"]
            Result_dictionary["Overlap"][i,r, :] = Dat["Overlap"]

    print("Generalization_accuracy of model " + Models[core] + " is:")
    print(np.mean(Result_dictionary["Accuracy"]))

    np.save(Dir + Models[core] + "/Generalization_data", Result_dictionary)

    done = True

    return done

with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
