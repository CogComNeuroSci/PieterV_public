import tensorflow as tf
import numpy as np

def Generalization_preparation(nContexts = 5, nRepeats = 3, Directory = "", Model="Adaptive_mult", Trial_percentage = 0.05, lr=0, r=0, xdat = np.random.random((100,28,28)), ydat = np.random.random((100))):
    #Define random seed for replicability
    np.random.seed(r)

    #Loading data from tensorflow
    #(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

    #Normalizing pixel values
    xdat = xdat/ 255

    #Transform 28 by 28 matrix of image into vector
    Inputs = xdat.reshape((np.size(ydat),-1))

    #Define the number of trials that will be used on each repetition
    total_labels = int(np.round(np.size(ydat)*Trial_percentage))

    # extract random samples
    id = np.random.choice(np.arange(np.size(ydat)), size = total_labels, replace = False)
    Inputs = Inputs[id,:]

    #We define 6 possible task rules or contexts
    Rules = {
        "labels1": (ydat%2)[id],
        "labels2": ((ydat%2==0)*1)[id],
        "labels3": ((ydat>5)*1)[id],
        "labels4": ((ydat<5)*1)[id],
        "labels5": ((ydat>3)*1)[id],
        "labels6": ((ydat<7)*1)[id],
    }

    #Define objective overlap
    Overlap = np.ones((6,6))
    for i in range(6):
        for i2 in range(6):
            Overlap[i,i2] = np.sum(Rules["labels"+str(i+1)] == Rules["labels"+str(i2+1)])/(total_labels)

    Overlap = Overlap[:nContexts, :nContexts]

    #Loading data after learning
    Data = np.load(Directory + Model + "/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)

    #Extract contextorder
    Contexts = np.zeros((nContexts, nContexts))
    O = Data[()]["Contextorder"]
    for i in range(nContexts):
        Contexts[i, O[i]]=1

    #Define correct response based on labels
    CorResp = np.zeros((nContexts, total_labels))
    for i in range(nContexts):
        CorResp[i,:]=Rules["labels{}".format(O[i]+1)]

    if "add" in Model:
        Output = {
            "Inputs": Inputs,
            "Order": O,
            "Contexts": Contexts,
            "CorResp": CorResp,
            "Overlap": Overlap,
            "Input_weights": Data[()]["Trained_Input_Weights"][nRepeats-1,O[nContexts-1],:,:],
            "Output_weights": Data[()]["Trained_Output_Weights"][nRepeats-1,O[nContexts-1],:,:],
            "Stim_labels": ydat[id]
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
            "Stim_labels": ydat[id]
            }

    return Output
