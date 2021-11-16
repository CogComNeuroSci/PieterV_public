import numpy as np
from   multiprocessing import Process, Pool
from Preparation_functions import Prep_MNIST_test_twolayer as P
from Model_functions import model_test_fun_twolayer as T

Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/twolayer/"#"/data/gent/430/vsc43099/GatingModel_data/"
Models = ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]

cp = len(Models)
worker_pool = []

learning_rates = np.arange(0,0.11,0.02)
Rep = 25

data_dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/" #"/Volumes/backupdisc/Modular_learning/Data_Revision/"#"/data/gent/vo/001/gvo00145/vsc43099/"#
datdict = np.load(data_dir + "data_MNIST.npy", allow_pickle = True)
x_test = datdict[()]["x_test"]
y_test = datdict[()]["y_test"]

def Gen_fun(core=0):
    done = False

    Result_dictionary={
        "Accuracy": np.zeros((np.size(learning_rates),Rep, 6, 500)),
        "Activation": np.zeros((np.size(learning_rates),Rep, 402, 6, 500)),
        "Contextorder": np.zeros((np.size(learning_rates),Rep, 6)),
        "Presented": np.zeros((np.size(learning_rates),Rep, 500)),
        "Overlap": np.zeros((np.size(learning_rates),Rep, 6,6))
        }
    i=-1
    for lr in learning_rates:
        i+=1
        for r in range(Rep):

            Dat = P.Generalization_preparation(nContexts = 6, Directory = Dir, Model=Models[core], Trial_percentage = 0.05, lr=lr, r=r, xdat = x_test, ydat = y_test)

            if core<2:
                Result = T.Generalization_multiplicative(Dat["Inputs"], Dat["Contexts"], Dat["Context_weights"], Dat["Input_weights"], Dat["Hidden_weights"], Dat["Output_weights"], Dat["CorResp"])
            else:
                Result = T.Generalization_additive(Dat["Inputs"], Dat["Contexts"], Dat["Input_weights"], Dat["Hidden_weights"], Dat["Output_weights"], Dat["CorResp"])

            Result_dictionary["Accuracy"][i, r, :, :] = Result["accuracy"]
            Result_dictionary["Activation"][i,r, :, :, :] = Result["activation"]
            Result_dictionary["Contextorder"][i,r, :] = Dat["Order"]
            Result_dictionary["Presented"][i,r, :] = Dat["Stim_labels"]
            Result_dictionary["Overlap"][i,r, :] = Dat["Overlap"]

    np.save(Dir + Models[core] + "/Generalization_data", Result_dictionary)

    print("Generalization_accuracy of model " + Models[core] + " is:")
    print(np.mean(Result_dictionary["Accuracy"]))

    done = True

    return done

with Pool(cp) as pool:
    result = pool.map(Gen_fun, np.arange(cp))
    print(result)
