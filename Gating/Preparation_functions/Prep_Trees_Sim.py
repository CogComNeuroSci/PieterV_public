import numpy as np

def preparation(nContexts = 4, nRepeats = 3, Part_trials = 450, seed=0):
    # set seed for replication purposes
    np.random.seed(seed)

    #Define input patterns
    nInput = 3
    nOutput = 1
    Inputs = np.random.uniform(size=(nRepeats, Part_trials, nInput))
    Inputs[:,:,2]=np.ones((nRepeats, Part_trials))#bias node is always active

    #Define objectives corresponding to each context
    Rules = {
        "labels1": (Inputs[:,:,0]>.5)*1,
        "labels2": (Inputs[:,:,1]>.5)*1,
        "labels3": (((Inputs[:,:,1]>.5)*1 + (Inputs[:,:,0]>.5)*1)>0)*1,
        "labels4": (((Inputs[:,:,1]>.5)*1 + (Inputs[:,:,0]>.5)*1)==2)*1,
        }

    # Compute objective similarity
    Overlap =  np.ones((4,4))
    for i in range(4):
        for i2 in range(4):
            Overlap[i,i2] = np.sum(Rules["labels"+str(i+1)] == Rules["labels"+str(i2+1)])/(Part_trials)

    #Put everything in a dictionary and return
    Data_dictionary = {
        "Inputs": Inputs,
        "Objectives_C1": Rules["labels1"],
        "Objectives_C2": Rules["labels2"],
        "Objectives_C3": Rules["labels3"],
        "Objectives_C4": Rules["labels4"],
        "Part_trials": Part_trials,
        "True_overlap": Overlap,
        "Stim_labels": Inputs
    }
    return Data_dictionary
