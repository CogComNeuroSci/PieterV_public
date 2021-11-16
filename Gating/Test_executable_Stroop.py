import numpy as np
from multiprocessing import Process, Pool
from Preparation_functions import Prep_Stroop_test as P
from Model_functions import model_test_fun_basic as T

#Define setings of previous simulations
resources = 12
Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/Stroop/"+ str(resources)+"/" #"/data/gent/430/vsc43099/GatingModel_data/"
Models = ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]

cp = len(Models)
worker_pool = []

learning_rates = np.arange(0,1.1,0.2)
Rep = 25

#Make result dictionary
Result_dictionary={
    "Accuracy": np.zeros((np.size(learning_rates),Rep, 5, 90)),
    "Activation": np.zeros((np.size(learning_rates),Rep, resources+1, 5, 90)),
    "Contextorder": np.zeros((np.size(learning_rates),Rep, 5)),
    "Presented": np.zeros((np.size(learning_rates),Rep, 90)),
    "Overlap": np.zeros((np.size(learning_rates),Rep, 5,5))
    }

def Gen_fun(core=0):
    done = False

    i=-1
    for lr in learning_rates:
        i+=1
        for r in range(Rep):

            #Prepare data
            Dat = P.Generalization_preparation(nContexts=5, Directory = Dir, Model=Models[core], ntrep=5, lr=lr, r=r, resources=resources)

            #Simulate network
            if core<2:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], True)
            else:
                Result = T.Generalization_additive(Dat["Inputs"], Dat["Contexts"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], True)

            #Save data
            Result_dictionary["Accuracy"][i,r, :, :] = Result["accuracy"]
            Result_dictionary["Activation"][i,r, :, :, :] = Result["activation"]
            Result_dictionary["Contextorder"][i,r, :] = Dat["Order"]
            Result_dictionary["Presented"][i,r, :] = Dat["Stim_labels"]
            Result_dictionary["Overlap"][i,r, :] = Dat["Overlap"]

    print("Generalization_accuracy of model " + Models[core] + " is:")
    print(np.mean(Result_dictionary["Accuracy"]))

    np.save(Dir + Models[core] + "/Generalization_data", Result_dictionary)

    done = True

    return done

#Use parallel computing
with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
