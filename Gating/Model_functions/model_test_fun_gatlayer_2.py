import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Generalization_multiplicative(Inputs, Contexts, Context_weights, Input_weights, Hidden_weights, Output_weights, Objectives, gatlayer =0):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = np.array(np.shape(Hidden_weights))
    nHidden[1]=nHidden[1]+1
    nOutput =1

    CH1 = np.ones((nContexts, nHidden[0]-1))
    CH2 = np.ones((nContexts, nHidden[1]-1))
    if gatlayer ==1:
        CH1 = Context_weights
    elif gatlayer ==2:
        CH2 = Context_weights
    elif gatlayer ==3:
        CH1 = Context_weights[0]
        CH2 = Context_weights[1]

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((np.sum(nHidden), nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]
            H1=sigmoid_activation(In, Input_weights, 0)
            G1=relu_activation(C, CH1, 0)
            Hidden1[:nHidden[0]-1]=H1*G1
            H2 = sigmoid_activation(Hidden1, Hidden_weights, 0)
            G2=relu_activation(C, CH2, 0)
            Hidden2[:nHidden[1]-1]=H2*G2
            Out = sigmoid_activation(Hidden2, Output_weights, 0)

            #Compute network evaluation metrics
            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = np.concatenate((Hidden1, Hidden2))

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return result

def Generalization_additive(Inputs, Contexts, Input_weights, Hidden_weights, Output_weights, Objectives, gatlayer =0):

    #Define network size
    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = np.zeros((2))
    nHidden[0] = int(np.shape(Input_weights)[1]+1)
    nHidden[1]= int(np.shape(Hidden_weights)[1]+1)
    nHidden = nHidden.astype(int)
    Tot_hidden = nContexts+ nHidden[0]
    nOutput = 1

    #Initialize network layers
    if gatlayer == 1 or gatlayer ==3:
        totI = nContexts+nInput
    else:
        totI = nInput
    if gatlayer == 2 or gatlayer ==3:
        totH = nContexts+ nHidden[0]
    else:
        totH = nHidden[0]

    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nContexts, np.size(Inputs,0)))
    Activation = np.zeros((np.sum(nHidden), nContexts, np.size(Inputs,0)))

    for c in range(nContexts):
        for t in range(np.size(Inputs,0)):

            #Compute network activation
            In = Inputs[t,:]
            C = Contexts[c,:]

            if gatlayer ==1 or gatlayer ==3:
                totI = np.concatenate((C, In))
            else:
                totI = In

            Hidden1[:nHidden[0]-1]=sigmoid_activation(totI, Input_weights, 0)

            if gatlayer ==2 or gatlayer ==3:
                totH = np.concatenate((C, Hidden1))
            else:
                totH = Hidden1

            Hidden2[:nHidden[1]-1] = sigmoid_activation(totH, Hidden_weights, 0)

            Out = sigmoid_activation(Hidden2, Output_weights, 0)

            #Compute network evaluation metrics
            response = np.round(Out)
            Obj = Objectives[c,t]
            CorResp = Obj
            Accuracy[c,t]=int(response == CorResp)
            Activation[:,c,t] = np.concatenate((Hidden1, Hidden2))

    #save results
    result = {
        "accuracy": Accuracy,
        "activation": Activation
        }

    print("Simulation succesfully terminated")

    return result
