import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Model_multiplicative(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = 24, multout=True):

    #Define network size
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    if multout:
        nInput = np.size(Inputs,1)
        nOutput = np.size(Objectives,2)
    else:
        nInput = np.size(Inputs,2)
        nOutput = 1

    #Initialize weights
    W_inp_hid=np.random.normal(size=(nInput,nHidden-1))
    if gate_learning:
        W_cont_hid=np.random.uniform(size=(nContexts, nHidden-1))
    else:
        W_cont_hid=np.random.normal(size=(nContexts, nHidden-1))
    W_hid_out=np.random.normal(size=(nHidden, nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    cont_hid_start = W_cont_hid
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((nHidden, nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden-1))
    cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden, nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):

                #Compute network activation
                if multout:
                    In = Inputs[t,:]
                else:
                    In = Inputs[r,t,:]
                C = Contexts[c,:]
                H=sigmoid_activation(In, W_inp_hid, 0)
                G=relu_activation(C, W_cont_hid, 0)
                Hidden[:nHidden-1]=H*G
                Out = sigmoid_activation(Hidden, W_hid_out, 0)

                #Compute network evaluation metrics
                if multout:
                    response = np.argmax(Out)
                    Obj = Objectives[c,t,:]
                    CorResp = np.argmax(Obj)
                else:
                    response = np.round(Out)
                    Obj = Objectives[c,r,t]
                    CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = Hidden

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden.reshape((nHidden,1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_inp_hid = learning_rate * In.reshape((nInput,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G * H * (1-H)).reshape(1,nHidden-1)
                if gate_learning:
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H * (G>0)).reshape(1,nHidden-1)
                else:
                    update_cont_hid = np.zeros((nContexts,nHidden-1))

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_cont_hid = W_cont_hid + update_cont_hid

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            cont_hid_trained[r,c,:,:] = W_cont_hid
            hid_out_trained[r,c,:,:] = W_hid_out

    #save results
    result = {
      "Initial_Input_Weights": inp_hid_start,
      "Initial_Context_Weights": cont_hid_start,
      "Initial_Output_Weights": hid_out_start,
      "Trained_Input_Weights": inp_hid_trained,
      "Trained_Context_Weights": cont_hid_trained,
      "Trained_Output_Weights": hid_out_trained,
      "Error": Error,
      "Activation": Activation,
      "Accuracy": Accuracy,
      "Criterion": Criterion
      }

    print("Simulation succesfully terminated")

    return result

def Model_additive(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = 24, multout=True):

    #Define network size
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    if multout:
        nInput = np.size(Inputs,1)
        nOutput = np.size(Objectives,2)
    else:
        nInput = np.size(Inputs,2)
        nOutput = 1

    #Initialize weights
    W_inp_hid=np.random.normal(size=(nInput,nHidden-1))
    if gate_learning:
        W_cont_hid=np.random.uniform(size=(nContexts, nHidden-1))
    else:
        W_cont_hid=np.random.normal(size=(nContexts, nHidden-1))
    W_hid_out=np.random.normal(size=(nHidden, nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    cont_hid_start = W_cont_hid
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((nHidden, nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden-1))
    cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden, nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):
                #Compute network activation
                if multout:
                    In = Inputs[t,:]
                else:
                    In = Inputs[r,t,:]
                C = Contexts[c,:]
                H=sigmoid_activation(In, W_inp_hid, 0)
                G=relu_activation(C, W_cont_hid, 0)
                Hidden[:nHidden-1]=H+G
                Out = sigmoid_activation(Hidden, W_hid_out, 0)

                #Compute network evaluation metrics
                if multout:
                    response = np.argmax(Out)
                    Obj = Objectives[c,t,:]
                    CorResp = np.argmax(Obj)
                else:
                    response = np.round(Out)
                    Obj = Objectives[c,r,t]
                    CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = Hidden

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden.reshape((nHidden,1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_inp_hid = learning_rate * In.reshape((nInput,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H * (1-H)).reshape(1,nHidden-1)
                if gate_learning:
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * (G>0)).reshape(1,nHidden-1)
                else:
                    update_cont_hid = np.zeros((nContexts,nHidden-1))

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_cont_hid = W_cont_hid + update_cont_hid

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            cont_hid_trained[r,c,:,:] = W_cont_hid
            hid_out_trained[r,c,:,:] = W_hid_out

    #save results
    result = {
      "Initial_Input_Weights": inp_hid_start,
      "Initial_Context_Weights": cont_hid_start,
      "Initial_Output_Weights": hid_out_start,
      "Trained_Input_Weights": inp_hid_trained,
      "Trained_Context_Weights": cont_hid_trained,
      "Trained_Output_Weights": hid_out_trained,
      "Error": Error,
      "Activation": Activation,
      "Accuracy": Accuracy,
      "Criterion": Criterion
      }

    print("Simulation succesfully terminated")

    return result
