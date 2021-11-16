import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Output_weights, Objectives, multout=True):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = np.size(Output_weights,0)
    if multout:
        nOutput = np.size(Objectives,2)
    else:
        nOutput = 1

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]
            H=sigmoid_activation(In, Input_weights, 0)
            G=relu_activation(C, Context_weights, 0)
            Hidden[:nHidden-1]=H*G
            Out = sigmoid_activation(Hidden, Output_weights, 0)

            #Compute network evaluation metrics
            if multout:
                response = np.argmax(Out)
                Obj = Objectives[c,t,:]
                CorResp = np.argmax(Obj)
            else:
                response = np.round(Out)
                Obj = Objectives[c,t]
                CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = Hidden

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
      }

    print("Simulation succesfully terminated")

    return result

def Generalization_additive(Inputs, Contexts, Context_weights, Input_weights, Output_weights, Objectives, multout=True):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = np.size(Output_weights,0)
    if multout:
        nOutput = np.size(Objectives,2)
    else:
        nOutput = 1

    #Initialize network layers
    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]
            H=sigmoid_activation(In, Input_weights, 0)
            G=relu_activation(C, Context_weights, 0)
            Hidden[:nHidden-1]=H+G
            Out = sigmoid_activation(Hidden, Output_weights, 0)

            #Compute network evaluation metrics
            if multout:
                response = np.argmax(Out)
                Obj = Objectives[c,t,:]
                CorResp = np.argmax(Obj)
            else:
                response = np.round(Out)
                Obj = Objectives[c,t]
                CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = Hidden

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
      }

    print("Simulation succesfully terminated")

    return result
