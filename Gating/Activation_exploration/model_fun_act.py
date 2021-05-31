import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Model_multiplicative(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, resources = 24, act = ["sig", "sig"]):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    nOutput = np.size(Objectives,2)

    if act[0]=="sig":
        W_inp_hid=np.random.normal(size=(nInput,nHidden-1))
    else:
        W_inp_hid=np.random.uniform(size=(nInput,nHidden-1))


    if act[1]=="sig":
        W_cont_hid=np.random.normal(size=(nContexts, nHidden-1))
    else:
        W_cont_hid=np.random.uniform(size=(nContexts, nHidden-1))

    W_hid_out=np.random.normal(size=(nHidden, nOutput))

    inp_hid_start = W_inp_hid
    cont_hid_start = W_cont_hid
    hid_out_start = W_hid_out

    In=np.zeros((nInput))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((nHidden, nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden-1))
    cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden, nOutput))

    rid = np.tile(np.arange(np.size(Inputs,0)),int(Part_trials/np.size(Inputs,0)))

    for r in range(nRepeats):
        for c in range(nContexts):

            for t in range(Part_trials):
                In = Inputs[rid[t],:]
                C = Contexts[c,:]
                if act[0]=="sig":
                    H=sigmoid_activation(In, W_inp_hid, 0)
                else:
                    H=relu_activation(In, W_inp_hid, 0)

                if act[0]=="sig":
                    G=sigmoid_activation(C, W_cont_hid, 0)
                else:
                    G=relu_activation(C, W_cont_hid, 0)

                Hidden[:nHidden-1]=H*G
                Out = sigmoid_activation(Hidden, W_hid_out, 0)

                response = np.argmax(Out)
                Obj = Objectives[c,rid[t],:]
                CorResp = np.argmax(Obj)
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = Hidden

                update_hid_out= learning_rate * Hidden.reshape((nHidden,1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                if act[0]=="sig":
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G * H * (1-H)).reshape(1,nHidden-1)
                else:
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G * (H>0)).reshape(1,nHidden-1)
                if act[1]=="sig":
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H * G * (1-G)).reshape(1,nHidden-1)
                else:
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H * (G>0)).reshape(1,nHidden-1)

                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_cont_hid = W_cont_hid + update_cont_hid

            inp_hid_trained[r,c,:,:] = W_inp_hid
            cont_hid_trained[r,c,:,:] = W_cont_hid
            hid_out_trained[r,c,:,:] = W_hid_out

    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Context_Weights": cont_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Context_Weights": cont_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy
        }

    print("Simulation succesfully terminated")

    return result

def Model_additive(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, resources = 24, act = "sig"):

    nInput = np.size(Inputs,1)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = resources+1
    nOutput = np.size(Objectives,2)

    if act =="sig":
        W_inp_hid=np.random.normal(size=(Tot_input,nHidden-1))
    else:
        W_inp_hid=np.random.uniform(size=(Tot_input,nHidden-1))

    W_hid_out=np.random.normal(size=(nHidden, nOutput))

    inp_hid_start = W_inp_hid
    hid_out_start = W_hid_out

    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))
    Hidden=np.zeros((nHidden))
    Hidden[nHidden-1]=1
    Out=np.zeros((nOutput))

    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((nHidden, nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))

    inp_hid_trained = np.zeros((nRepeats, nContexts, Tot_input, nHidden-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden, nOutput))

    rid = np.tile(np.arange(np.size(Inputs,0)),int(Part_trials/np.size(Inputs,0)))

    for r in range(nRepeats):
        for c in range(nContexts):

            for t in range(Part_trials):
                In = Inputs[rid[t],:]
                C = Contexts[c,:]
                tot = np.concatenate((C, In))
                if act =="sig":
                    Hidden[:nHidden-1]=sigmoid_activation(tot, W_inp_hid, 0)
                else:
                        Hidden[:nHidden-1]=relu_activation(tot, W_inp_hid, 0)

                Out = sigmoid_activation(Hidden, W_hid_out, 0)

                response = np.argmax(Out)
                Obj = Objectives[c,rid[t],:]
                CorResp = np.argmax(Obj)
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = Hidden

                update_hid_out= learning_rate * Hidden.reshape((nHidden,1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                if act == "sig":
                    update_inp_hid = learning_rate * tot.reshape((Tot_input,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden[:-1] * (1-Hidden[:-1])).reshape(1,nHidden-1)
                else:
                    update_inp_hid = learning_rate * tot.reshape((Tot_input,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * (Hidden[:-1]>0)).reshape(1,nHidden-1)

                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid

            inp_hid_trained[r,c,:,:] = W_inp_hid
            hid_out_trained[r,c,:,:] = W_hid_out

    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy
        }

    print("Simulation succesfully terminated")

    return result
