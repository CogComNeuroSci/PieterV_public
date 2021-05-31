import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Hidden_weights, Output_weights, Objectives):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = np.array(np.shape(Hidden_weights))
    nHidden[1]=nHidden[1]+1

    # We only use one output: on or off
    nOutput = 1

    In=np.zeros((nInput))

    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1

    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((np.sum(nHidden), nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):
            In = Inputs[t,:]
            C = Contexts[c,:]
            H=sigmoid_activation(In, Input_weights, 0)
            G=relu_activation(C, Context_weights, 0)
            Hidden1[:nHidden[0]-1]=H*G
            Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, Hidden_weights, 0)
            Out = sigmoid_activation(Hidden2, Output_weights, 0)

            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)

            Activation[:,c,t] = np.concatenate((Hidden1,Hidden2))

    Data_dir = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return Data_dir

def Generalization_additive(Inputs, Contexts, Input_weights, Hidden_weights, Output_weights, Objectives):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = np.array(np.shape(Hidden_weights))
    nHidden[1]=nHidden[1]+1
    
    # We only use one output: on or off
    nOutput = 1

    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))

    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1

    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((np.sum(nHidden), nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            In = Inputs[t,:]
            C = Contexts[c,:]
            tot = np.concatenate((C, In))
            Hidden1[:nHidden[0]-1]=sigmoid_activation(tot, Input_weights, 0)
            Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, Hidden_weights, 0)
            Out = sigmoid_activation(Hidden2, Output_weights, 0)

            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)

            Activation[:,c,t] = np.concatenate((Hidden1,Hidden2))

    Data_dir = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return Data_dir
