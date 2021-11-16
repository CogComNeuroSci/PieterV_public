import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Hidden1_weights, Hidden2_weights, Output_weights, Objectives):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden1 = np.size(Hidden1_weights,0)
    nHidden2 = np.size(Hidden2_weights,0)
    nHidden3 = np.size(Output_weights,0)
    nOutput =1

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden1=np.zeros((nHidden1))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden2))
    Hidden2[-1]=1
    Hidden3=np.zeros((nHidden3))
    Hidden3[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden1 + nHidden2 + nHidden3, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]
            H=sigmoid_activation(In, Input_weights, 0)
            G=relu_activation(C, Context_weights, 0)
            Hidden1[:nHidden1-1]=H*G
            Hidden2[:nHidden2-1] = sigmoid_activation(Hidden1, Hidden1_weights, 0)
            Hidden3[:nHidden3-1] = sigmoid_activation(Hidden2, Hidden2_weights, 0)
            Out = sigmoid_activation(Hidden3, Output_weights, 0)

            #Compute network evaluation metrics
            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = np.concatenate((Hidden1, Hidden2, Hidden3))

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
      }

    print("Simulation succesfully terminated")

    return result

def Generalization_additive(Inputs, Contexts, Input_weights, Hidden1_weights, Hidden2_weights, Output_weights, Objectives):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden1 = np.size(Hidden1_weights,0)
    nHidden2 = np.size(Hidden2_weights,0)
    nHidden3 = np.size(Output_weights,0)
    Tot_input = nContexts+nInput
    nOutput = 1

    #Initialize network layers
    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))
    Hidden1=np.zeros((nHidden1))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden2))
    Hidden2[-1]=1
    Hidden3=np.zeros((nHidden3))
    Hidden3[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((nHidden1 + nHidden2 + nHidden3, nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]
            tot = np.concatenate((C, In))
            Hidden1[:nHidden1-1]=sigmoid_activation(tot, Input_weights, 0)
            Hidden2[:nHidden2-1] = sigmoid_activation(Hidden1, Hidden1_weights, 0)
            Hidden3[:nHidden3-1] = sigmoid_activation(Hidden2, Hidden2_weights, 0)
            Out = sigmoid_activation(Hidden2, Output_weights, 0)

            #Compute network evaluation metrics
            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = np.concatenate((Hidden1, Hidden2, Hidden3))

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return result
