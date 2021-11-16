import numpy as np
from multiprocessing import Process, Pool
from Preparation_functions import Prep_Trees_test_consep as P


#Define setings of previous simulations
resources = 12
Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/conc/Trees/" #"/data/gent/430/vsc43099/GatingModel_data/"
Models = ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]

cp = len(Models)*2
worker_pool = []

learning_rates = np.arange(0,1.1,0.2)
Rep = 25

#Make result dictionary
Result_dictionary={
    "Accuracy": np.zeros((np.size(learning_rates),Rep, 4, 100)),
    "Activation": np.zeros((np.size(learning_rates),Rep, resources+1,  4, 100)),
    "Contextorder": np.zeros((np.size(learning_rates),Rep, 4)),
    "Presented": np.zeros((np.size(learning_rates),Rep, 100,3)),
    "Overlap": np.zeros((np.size(learning_rates),Rep, 4, 4))
    }

def Gen_fun(core=0):
    done = False
    if core <4:
        from Model_functions import model_test_fun_conc as T
        method = "conc"
    else:
        from Model_functions import model_test_fun_sep as T
        method = "sep"

    Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/"+ method +"/Trees/"
    i=-1
    for lr in learning_rates:
        i+=1
        for r in range(Rep):

            #Prepare data
            Dat = P.Generalization_preparation(nContexts=4, Directory = Dir, Model=Models[core%4], Part_trials=100, lr=lr, r=r, resources=resources)

            #Simulate network
            if (core%4)<2:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], False)
            else:
                Result = T.Generalization_additive(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], False)

            #Save data
            Result_dictionary["Accuracy"][i,r, :, :] = Result["accuracy"]
            Result_dictionary["Activation"][i,r, :, :, :] = Result["activation"]
            Result_dictionary["Contextorder"][i,r, :] = Dat["Order"]
            Result_dictionary["Presented"][i,r, :, :] = Dat["Stim_labels"]
            Result_dictionary["Overlap"][i,r, :] = Dat["Overlap"]

    print("Generalization_accuracy of model " + Models[core%4] + " is:")
    print(np.mean(Result_dictionary["Accuracy"]))

    np.save(Dir + Models[core%4] + "/Generalization_data", Result_dictionary)

    done = True

    return done

#Use parallel computing
with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
