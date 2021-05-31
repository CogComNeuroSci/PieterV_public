import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Output_weights, Objectives, act=["sig","sig"]):

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

            if act[0]=="sig":
                H=sigmoid_activation(In, Input_weights, 0)
            else:
                H=relu_activation(In, Input_weights, 0)

            if act[1]=="sig":
                G=sigmoid_activation(C, Context_weights, 0)
            else:
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
