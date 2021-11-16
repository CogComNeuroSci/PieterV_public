import tensorflow as tf
import numpy as np

def preparation(nContexts = 6, nRepeats = 3, Trial_percentage = 1, seed=0, xdat = np.random.random((100,28,28)), ydat = np.random.random((100))):
    # we set a random seed to replicate results
    np.random.seed(seed)

    # we divide the percentage of samples over the task repetitions
    Trial_percentage = Trial_percentage/nRepeats
    #loading data from tensorflow
    #(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

    #Normalizing pixel values
    xdat= xdat / 255

    #Transform 28 by 28 matrix of image into vector
    Inputs = xdat.reshape((np.size(ydat),-1))

    #Define the number of trials that will be used on each repetition
    total_labels = int(np.round(np.size(ydat)*Trial_percentage))

    #Sample input patterns
    id = np.random.choice(np.arange(np.size(ydat)), size = total_labels*nRepeats, replace = False)
    Inputs = Inputs[id,:]

    Inputs = np.reshape(Inputs, (nRepeats, total_labels, -1))

    #Define corresponding objectives
    Rules = {
        "labels1": (ydat%2)[id], #odd
        "labels2": ((ydat%2==0)*1)[id], #even
        "labels3": ((ydat>5)*1)[id], #bigger than 5
        "labels4": ((ydat<5)*1)[id], #smaller than 5
        "labels5": ((ydat>3)*1)[id], #bigger than 3
        "labels6": ((ydat<7)*1)[id], #smaller than 7
    }

    # Compute objective task similarity
    Overlap = np.ones((6,6))
    for i in range(6):
        for i2 in range(6):
            Overlap[i,i2] = np.sum(Rules["labels"+str(i+1)] == Rules["labels"+str(i2+1)])/(total_labels*nRepeats)

    Overlap = Overlap[:nContexts, :nContexts]

    #Put everything in a dictionary and return
    Data_dictionary = {
        "Inputs": Inputs,
        "Objectives_C1": np.reshape(Rules["labels1"],(nRepeats,total_labels)),
        "Objectives_C2": np.reshape(Rules["labels2"],(nRepeats,total_labels)),
        "Objectives_C3": np.reshape(Rules["labels3"],(nRepeats,total_labels)),
        "Objectives_C4": np.reshape(Rules["labels4"],(nRepeats,total_labels)),
        "Objectives_C5": np.reshape(Rules["labels5"],(nRepeats,total_labels)),
        "Objectives_C6": np.reshape(Rules["labels6"],(nRepeats,total_labels)),
        "Part_trials": total_labels,
        "True_overlap": Overlap,
        "Stim_labels": np.reshape(ydat[id],(nRepeats,total_labels))
    }

    return Data_dictionary
