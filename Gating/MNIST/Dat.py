import tensorflow as tf
import numpy as np

def preparation(nContexts = 6, nRepeats = 3, Trial_percentage = 1, seed=0):
    np.random.seed(seed)

    Trial_percentage = Trial_percentage/nRepeats
    #loading data from tensorflow
    (x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

    #Normalizing pixel values
    x_train = x_train / 255

    #Transform 28 by 28 matrix of image into vector
    Inputs = x_train.reshape((np.size(y_train),-1))

    #Define the number of trials that will be used on each repetition
    total_labels = int(np.round(np.size(y_train)*Trial_percentage))

    id = np.random.choice(np.arange(np.size(y_train)), size = total_labels*nRepeats, replace = False)
    Inputs = Inputs[id,:]

    Inputs = np.reshape(Inputs, (nRepeats, total_labels, -1))

    #We define 6 possible task rules or contexts
    Rules = {
        "labels1": (y_train%2)[id], #odd
        "labels2": ((y_train%2==0)*1)[id], #even
        "labels3": ((y_train>5)*1)[id], #bigger than 5
        "labels4": ((y_train<5)*1)[id], #smaller than 5
        "labels5": ((y_train>3)*1)[id], #bigger than 3
        "labels6": ((y_train<7)*1)[id], #smaller than 7
    }

    Overlap = np.ones((6,6))
    for i in range(6):
        for i2 in range(6):
            Overlap[i,i2] = np.sum(Rules["labels"+str(i+1)] == Rules["labels"+str(i2+1)])/(total_labels*nRepeats)

    Overlap = Overlap[:nContexts, :nContexts]

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
        "Number_labels": np.reshape(y_train[id],(nRepeats,total_labels))
    }

    return Data_dictionary
