import numpy as np
from multiprocessing import Process, Pool
from Preparation_functions import Prep_Stroop_test_actcomb as P
from Model_functions import model_test_fun_actcomb as T


#Define setings of previous simulations
resources = 12
Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/comb/Stroop/" #"/data/gent/430/vsc43099/GatingModel_data/"
Models = ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]

cp = 6
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
    if core%2 == 0:
        act = ["sig"]
    else:
        act = ["relu"]

    if core <4:
        act.append("sig")
    else:
        act.append("relu")

    for m in range(2):
        i=-1
        for lr in learning_rates:
            i+=1
            for r in range(Rep):

                if core < 2:
                    #Prepare data
                    Dat = P.Generalization_preparation(nContexts=5, Directory = Dir, Model=Models[m+2], ntrep = 5, lr=lr, r=r, resources=resources, act = act)
                    #Simulate network
                    Result = T.Generalization_additive(Dat["Inputs"], Dat["Contexts"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], True, act)

                else:
                    #Prepare data
                    Dat = P.Generalization_preparation(nContexts=5, Directory = Dir, Model=Models[m], ntrep = 5, lr=lr, r=r, resources=resources, act = act)
                    #Simulate network
                    Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Output_weights"], Dat["CorResp"], True, act)

                #Save data
                Result_dictionary["Accuracy"][i,r, :, :] = Result["accuracy"]
                Result_dictionary["Activation"][i,r, :, :, :] = Result["activation"]
                Result_dictionary["Contextorder"][i,r, :] = Dat["Order"]
                Result_dictionary["Presented"][i,r, :] = Dat["Stim_labels"]
                Result_dictionary["Overlap"][i,r, :] = Dat["Overlap"]

        if core<2:
            print("Generalization_accuracy of model " + Models[m+2] + " is:")
            print(np.mean(Result_dictionary["Accuracy"]))

            np.save(Dir + Models[m+2] + "/Generalization_data_"+ act[0], Result_dictionary)
        else:
            print("Generalization_accuracy of model " + Models[m] + " is:")
            print(np.mean(Result_dictionary["Accuracy"]))

            np.save(Dir + Models[m] + "/Generalization_data_"+ act[0]+ "_"+ act[1], Result_dictionary)

    done = True

    return done

#Use parallel computing
with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
