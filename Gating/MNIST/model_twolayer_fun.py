import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Model_multiplicative(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = np.array([300,100])):

    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    # We only use one output: on or off
    nOutput = 1

    W_inp_hid=np.random.normal(size=(nInput,nHidden[0]-1))
    if gate_learning:
        W_cont_hid=np.random.uniform(size=(nContexts, nHidden[0]-1))
    else:
        W_cont_hid=np.random.normal(size=(nContexts, nHidden[0]-1))

    W_hidden = np.random.normal(size=(nHidden[0], nHidden[1]-1))
    hid_hid_start = W_hidden
    W_hid_out=np.random.normal(size=(nHidden[1], nOutput))

    inp_hid_start = W_inp_hid
    cont_hid_start = W_cont_hid
    hid_out_start = W_hid_out

    In=np.zeros((nInput))

    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden[0]-1))
    cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden[0]-1))

    hid_hid_trained = np.zeros((nRepeats, nContexts, nHidden[0], nHidden[1]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[1], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            for t in range(Part_trials):

                In = Inputs[r,t,:]
                C = Contexts[c,:]
                H=sigmoid_activation(In, W_inp_hid, 0)
                G=relu_activation(C, W_cont_hid, 0)
                Hidden1[:nHidden[0]-1]=H*G
                Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, W_hidden, 0)
                Out = sigmoid_activation(Hidden2, W_hid_out, 0)

                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2))

                update_hid_out= learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_hidden = learning_rate * Hidden1.reshape((nHidden[0],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])).reshape((1,nHidden[1]-1))
                update_inp_hid = learning_rate * In.reshape((nInput,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])) @ np.transpose(W_hidden[:-1,:]) * G * H * (1-H)).reshape((1,nHidden[0]-1))
                if gate_learning:
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])) @ np.transpose(W_hidden[:-1,:]) * H * (G>0)).reshape((1,nHidden[0]-1))
                else:
                    update_cont_hid = np.zeros((nContexts,nHidden[0]-1))

                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_cont_hid = W_cont_hid + update_cont_hid

                W_hidden = W_hidden + update_hidden

            inp_hid_trained[r,c,:,:] = W_inp_hid
            cont_hid_trained[r,c,:,:] = W_cont_hid
            hid_out_trained[r,c,:,:] = W_hid_out

            hid_hid_trained[r,c,:,:] = W_hidden

    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Context_Weights": cont_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Initial_Hidden_Weights": hid_hid_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Context_Weights": cont_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Trained_Hidden_Weights": hid_hid_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy,
        }

    print("Simulation succesfully terminated")

    return result

def Model_additive(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = 24):

    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = resources+1
    # We only use one output: on or off
    nOutput = 1

    W_inp_hid=np.random.normal(size=(Tot_input,nHidden[0]-1))

    # For now we only take into account the possibility of 2 hidden layers
    W_hidden = np.random.normal(size=(nHidden[0], nHidden[1]-1))
    hid_hid_start = W_hidden
    W_hid_out=np.random.normal(size=(nHidden[1], nOutput))

    inp_hid_start = W_inp_hid
    hid_out_start = W_hid_out

    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))

    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1

    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))

    inp_hid_trained = np.zeros((nRepeats, nContexts, Tot_input, nHidden[0]-1))
    hid_hid_trained = np.zeros((nRepeats, nContexts, nHidden[0], nHidden[1]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[1], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            for t in range(Part_trials):

                In = Inputs[r,t,:]
                C = Contexts[c,:]
                tot = np.concatenate((C, In))
                Hidden1[:nHidden[0]-1]=sigmoid_activation(tot, W_inp_hid, 0)
                Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, W_hidden, 0)
                Out = sigmoid_activation(Hidden2, W_hid_out, 0)

                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2))

                update_hid_out= learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_hidden = learning_rate * Hidden1.reshape((nHidden[0],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])).reshape((1,nHidden[1]-1))
                update_inp_hid = learning_rate * tot.reshape((Tot_input,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])) @ np.transpose(W_hidden[:-1,:]) * Hidden1[:nHidden[0]-1] * (1-Hidden1[:nHidden[0]-1])).reshape((1,nHidden[0]-1))

                if not gate_learning:
                  update_inp_hid[0:nContexts,:]=np.zeros((nContexts,nHidden[0]-1))

                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid

                W_hidden = W_hidden + update_hidden

            inp_hid_trained[r,c,:,:] = W_inp_hid
            hid_out_trained[r,c,:,:] = W_hid_out
            hid_hid_trained[r,c,:,:] = W_hidden

    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Initial_Hidden_Weights": hid_hid_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Trained_Hidden_Weights": hid_hid_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy,
        }

    print("Simulation succesfully terminated")

    return result
