import numpy as np

def preparation(nContexts = 5, nRepeats = 3, ntrep = 25, seed = 0):

    np.random.seed(seed)
    
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

    overlap  = np.ones((5,5))
    for i in range(5):
        for i2 in range(5):
            overlap[i,i2]=np.sum(np.all([Objectives[i,:,:]==Objectives[i2,:,:]], axis=1))/nOutput

    #overlap = overlap[::nContexts, ::nContexts]

    Data_dictionary = {
        "Inputs": Inputs,
        "Objectives_C1": np.tile(Objectives[0,:,:],(ntrep,1)),
        "Objectives_C2": np.tile(Objectives[1,:,:],(ntrep,1)),
        "Objectives_C3": np.tile(Objectives[2,:,:],(ntrep,1)),
        "Objectives_C4": np.tile(Objectives[3,:,:],(ntrep,1)),
        "Objectives_C5": np.tile(Objectives[4,:,:],(ntrep,1)),
        "Part_trials": Part_trials,
        "True_overlap": overlap,
    }
    return Data_dictionary
