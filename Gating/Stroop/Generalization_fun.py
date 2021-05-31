import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Output_weights, Objectives):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = np.size(Output_weights,0)
    nOutput = np.size(Objectives,2)

    In=np.zeros((nInput))

    Hidden=np.zeros((nHidden))
    Hidden[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):
            In = Inputs[t,:]
            C = Contexts[c,:]
            H=sigmoid_activation(In, Input_weights, 0)
            G=relu_activation(C, Context_weights, 0)
            Hidden[:nHidden-1]=H*G
            Out = sigmoid_activation(Hidden, Output_weights, 0)

            response = np.argmax(Out)
            Obj = Objectives[c,t,:]
            CorResp = np.argmax(Obj)
            Accuracy[c,t]=int(response == CorResp)

            Activation[:,c,t] = Hidden

    Data_dir = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return Data_dir

def Generalization_additive(Inputs, Contexts, Input_weights, Output_weights, Objectives):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = np.size(Output_weights,0)
    nOutput = np.size(Objectives,2)

    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))

    Hidden=np.zeros((nHidden))
    Hidden[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            In = Inputs[t,:]
            C = Contexts[c,:]
            tot = np.concatenate((C, In))
            Hidden[:nHidden-1]=sigmoid_activation(tot, Input_weights, 0)
            Out = sigmoid_activation(Hidden, Output_weights, 0)

            response = np.argmax(Out)
            Obj = Objectives[c,t,:]
            CorResp = np.argmax(Obj)
            Accuracy[c,t]=int(response == CorResp)

            Activation[:,c,t] = Hidden

    Data_dir = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return Data_dir
