import tensorflow as tf
import numpy as np

def Generalization_preparation(nContexts = 5, nRepeats = 3, Directory = "", Model="Adaptive_mult", ntrep = 25, lr=0, r=0, resources=12):

    np.random.seed(r)

    nInput = 8
    nOutput = 3
    nPatterns = nOutput**2*2
    Part_trials= nPatterns *ntrep

    Input_act=np.zeros((nPatterns, nInput+1))
    Input_act[:,0:2]=np.tile(np.diag(np.ones((2))),(9,1))
    Input_act[:,2:5]=np.repeat(np.diag(np.ones((3))),6,0)
    Input_act[:,5:8]=np.repeat(np.tile(np.diag(np.ones((3))),(3,1)),2,0)
    Input_act[:,8]=np.ones((nPatterns)) #bias node is always active

    Inputs = np.tile(Input_act,(ntrep,1))

    Objectives=np.zeros((5,nPatterns,nOutput));
    Objectives[0,np.array([0,1,2,4,7,13]),:]=[1,0,0]
    Objectives[0,np.array([3,6,8,9,10,15]),:]=[0,1,0]
    Objectives[0,np.array([5,11,12,14,16,17]),:]=[0,0,1]

    Objectives[1,np.array([0,1,2,4,7,13]),:]=[0,1,0]
    Objectives[1,np.array([3,6,8,9,10,15]),:]=[0,0,1]
    Objectives[1,np.array([5,11,12,14,16,17]),:]=[1,0,0]

    Objectives[2,np.array([0,1,2,4,7,13]),:]=[0,0,1]
    Objectives[2,np.array([3,6,8,9,10,15]),:]=[1,0,0]
    Objectives[2,np.array([5,11,12,14,16,17]),:]=[0,1,0]

    Objectives[3,np.array([0,1,2,4,7,13]),:]=[0,0,1]
    Objectives[3,np.array([3,6,8,9,10,15]),:]=[0,1,0]
    Objectives[3,np.array([5,11,12,14,16,17]),:]=[1,0,0]

    Objectives[4,np.array([0,1,2,4,7,13]),:]=[1,0,0]
    Objectives[4,np.array([3,6,8,9,10,15]),:]=[0,1,0]
    Objectives[4,np.array([5,11,12,14,16,17]),:]=[0,0,1]

    Objectives = np.tile(Objectives, (1, ntrep,1))

    Overlap =  np.ones((5,5))
    for i in range(5):
        for i2 in range(5):
            Overlap[i,i2] = np.sum(np.all([Objectives[i,:,:]==Objectives[i2,:,:]], axis=1))/nOutput

    #Loading data after learning
    Data = np.load(Directory + Model +"/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle=True)

    Contexts = np.zeros((nContexts, nContexts))
    O = Data[()]["Contextorder"]
    for i in range(nContexts):
        Contexts[i, O[i]]=1

    CorResp = np.zeros((nContexts, Part_trials, nOutput))
    for i in range(nContexts):
        CorResp[i,:,:]=Objectives[O[i],:,:]

    Output = {
        "Inputs": Inputs,
        "Order": O,
        "Contexts": Contexts,
        "CorResp": CorResp,
        "Overlap": Overlap,
        "Input_weights": Data[()]["Trained_Input_Weights"][nRepeats-1,O[nContexts-1],:,:],
        "Context_weights": Data[()]["Trained_Context_Weights"][nRepeats-1,O[nContexts-1],:,:],
        "Output_weights": Data[()]["Trained_Output_Weights"][nRepeats-1,O[nContexts-1],:,:],
    }

    return Output
