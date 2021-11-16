import numpy as np

def Generalization_preparation(nContexts = 4, nRepeats = 3, Directory = "", Model="Adaptive_mult", Part_trials = 100, lr=0.1, r=1, resources = 12):

    #Set random seed for replicability
    np.random.seed(r+100)

    #Define input patterns
    nInput = 3
    nOutput = 1
    Inputs = np.random.uniform(size=(Part_trials, nInput))
    Inputs[:,2]=np.ones((Part_trials))

    #Define corresponding objectives
    Rules = {
        "labels1": (Inputs[:,0]>.5)*1,
        "labels2": (Inputs[:,1]>.5)*1,
        "labels3": (((Inputs[:,1]>.5)*1 + (Inputs[:,0]>.5)*1)>0)*1,
        "labels4": (((Inputs[:,1]>.5)*1 + (Inputs[:,0]>.5)*1)==2)*1,
        }

    # Compute objective similarity
    Overlap =  np.ones((4,4))
    for i in range(4):
        for i2 in range(4):
            Overlap[i,i2] = np.sum(Rules["labels"+str(i+1)] == Rules["labels"+str(i2+1)])/(Part_trials)

    #Loading data after learning
    Data = np.load(Directory + Model + "/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle=True)

    #Get contextorder and determine objectives (CorResp)
    Contexts = np.zeros((nContexts, nContexts))
    O = Data[()]["Contextorder"]
    for i in range(nContexts):
        Contexts[i, O[i]]=1

    CorResp = np.zeros((nContexts, Part_trials))
    for i in range(nContexts):
        CorResp[i,:]=Rules["labels{}".format(O[i]+1)]

    #Make function output
    if "add" in Model:
        Output = {
            "Inputs": Inputs,
            "Order": O,
            "Contexts": Contexts,
            "CorResp": CorResp,
            "Overlap": Overlap,
            "Input_weights": Data[()]["Trained_Input_Weights"][nRepeats-1,O[nContexts-1],:,:], # Get weights at last repeat of last context
            "Output_weights": Data[()]["Trained_Output_Weights"][nRepeats-1,O[nContexts-1],:,:],
            "Stim_labels": Inputs
            }
    else:
        Output = {
        "Inputs": Inputs,
        "Order": O,
        "Contexts": Contexts,
        "CorResp": CorResp,
        "Overlap": Overlap,
        "Input_weights": Data[()]["Trained_Input_Weights"][nRepeats-1,O[nContexts-1],:,:],
        "Context_weights": Data[()]["Trained_Context_Weights"][nRepeats-1,O[nContexts-1],:,:],
        "Output_weights": Data[()]["Trained_Output_Weights"][nRepeats-1,O[nContexts-1],:,:],
        "Stim_labels": Inputs
        }

    return Output
