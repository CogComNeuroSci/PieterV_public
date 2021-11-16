import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Model_multiplicative(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = np.array([300,100]), gatlayer=0):

    #Define network size
    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    nOutput =1

    #Initialize weights
    W_inp_hid=np.random.normal(size=(nInput,nHidden[0]-1))
    if gatlayer ==3:
        if gate_learning:
            W_cont_hid1=np.random.uniform(size=(nContexts, nHidden[0]-1))
            W_cont_hid2=np.random.uniform(size=(nContexts, nHidden[1]-1))
        else:
            W_cont_hid1=np.random.normal(size=(nContexts, nHidden[0]-1))
            W_cont_hid2=np.random.uniform(size=(nContexts, nHidden[1]-1))
    elif gatlayer >0:
        if gate_learning:
            W_cont_hid=np.random.uniform(size=(nContexts, nHidden[gatlayer-1]-1))
        else:
            W_cont_hid=np.random.normal(size=(nContexts, nHidden[gatlayer-1]-1))


    W_hidden = np.random.normal(size=(nHidden[0], nHidden[1]-1))
    W_hid_out=np.random.normal(size=(nHidden[1], nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    if gatlayer ==3:
        cont_hid1_start = W_cont_hid1
        cont_hid2_start = W_cont_hid2
    elif gatlayer >0:
        cont_hid_start = W_cont_hid
    hid_hid_start = W_hidden
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden[0]-1))
    if gatlayer ==3:
        cont_hid1_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden[0]-1))
        cont_hid2_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden[1]-1))
    elif gatlayer>0:
        cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden[gatlayer-1]-1))
    hid_hid_trained = np.zeros((nRepeats, nContexts, nHidden[0], nHidden[1]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[1], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):

                #Compute network activation
                In = Inputs[r,t,:]
                C = Contexts[c,:]
                H1=sigmoid_activation(In, W_inp_hid, 0)
                if gatlayer ==3:
                    G1=relu_activation(C, W_cont_hid1, 0)
                    G2=relu_activation(C, W_cont_hid2, 0)
                elif gatlayer >0:
                    G = relu_activation(C, W_cont_hid, 0)

                if gatlayer ==1:
                    Hidden1[:nHidden[0]-1]=H1*G
                elif gatlayer ==3:
                    Hidden1[:nHidden[0]-1]=H1*G1
                else:
                    Hidden1[:nHidden[0]-1]=H1

                H2 = sigmoid_activation(Hidden1, W_hidden, 0)
                if gatlayer ==2:
                    Hidden2[:nHidden[1]-1]=H2*G
                elif gatlayer ==3:
                    Hidden2[:nHidden[1]-1]=H2*G2
                else:
                    Hidden2[:nHidden[1]-1]=H2

                Out = sigmoid_activation(Hidden2, W_hid_out, 0)

                #Compute network evaluation metrics
                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2))

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                if gatlayer ==2:
                    update_hidden = learning_rate * Hidden1.reshape((nHidden[0],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G * H2 * (1-H2)).reshape((1,nHidden[1]-1))
                elif gatlayer ==3:
                    update_hidden = learning_rate * Hidden1.reshape((nHidden[0],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G2 * H2 * (1-H2)).reshape((1,nHidden[1]-1))
                else:
                    update_hidden = learning_rate * Hidden1.reshape((nHidden[0],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H2 * (1-H2)).reshape((1,nHidden[1]-1))

                if gatlayer ==1:
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:]) * G * H1 * (1-H1)).reshape((1,nHidden[0]-1))
                elif gatlayer ==2:
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G * H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:]) * H1 * (1-H1)).reshape((1,nHidden[0]-1))
                elif gatlayer ==3:
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:]))* G2 * H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:])* G1 * H1 * (1-H1)).reshape((1,nHidden[0]-1))
                else:
                    update_inp_hid = learning_rate * In.reshape((nInput,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:]))* H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:]) * H1 * (1-H1)).reshape((1,nHidden[0]-1))


                if gate_learning:
                    if gatlayer ==1:
                        update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:]) * H1 * (G>0)).reshape((1,nHidden[0]-1))
                    elif gatlayer ==2:
                        update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H2 * (G>0)).reshape((1,nHidden[1]-1))
                    elif gatlayer ==3:
                        update_cont_hid2 = learning_rate * C.reshape((nContexts,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * H2 * (G2>0)).reshape((1,nHidden[1]-1))
                        update_cont_hid1 = learning_rate * C.reshape((nContexts,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * G2 * H2 * (1-H2)) @ np.transpose(W_hidden[:-1,:]) * H1 * (G1>0)).reshape((1,nHidden[0]-1))
                    else:
                        pass
                else:
                    if gatlayer ==3:
                        update_cont_hid1 = np.zeros((nContexts,nHidden[0]-1))
                        update_cont_hid2 = np.zeros((nContexts,nHidden[1]-1))
                    elif gatlayer >0:
                        update_cont_hid = np.zeros((nContexts,nHidden[gatlayer-1]-1))
                    else:
                        pass

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_hidden = W_hidden + update_hidden
                if gatlayer ==3:
                    W_cont_hid1 = W_cont_hid1 + update_cont_hid1
                    W_cont_hid2 = W_cont_hid2 + update_cont_hid2
                elif gatlayer >0:
                    W_cont_hid = W_cont_hid + update_cont_hid

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            hid_out_trained[r,c,:,:] = W_hid_out
            hid_hid_trained[r,c,:,:] = W_hidden
            if gatlayer ==3:
                cont_hid1_trained[r,c,:,:] = W_cont_hid1
                cont_hid2_trained[r,c,:,:] = W_cont_hid2
            elif gatlayer >0:
                cont_hid_trained[r,c,:,:] = W_cont_hid

    #save results
    if gatlayer ==3:
        result = {
            "Initial_Input_Weights": inp_hid_start,
            "Initial_Context_Weights_1": cont_hid1_start,
            "Initial_Context_Weights_2": cont_hid2_start,
            "Initial_Output_Weights": hid_out_start,
            "Initial_Hidden_Weights": hid_hid_start,
            "Trained_Input_Weights": inp_hid_trained,
            "Trained_Context_Weights_1": cont_hid1_trained,
            "Trained_Context_Weights_2": cont_hid2_trained,
            "Trained_Output_Weights": hid_out_trained,
            "Trained_Hidden_Weights": hid_hid_trained,
            "Error": Error,
            "Activation": Activation,
            "Accuracy": Accuracy,
            }
    elif gatlayer>0:
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
    else:
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

def Model_additive(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = np.array([300,100]), gatlayer = 0):
    #Define network size
    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    nOutput = 1

    if gatlayer == 1 or gatlayer ==3:
        Tot_input = nContexts+nInput
    else:
        Tot_input = nInput
    if gatlayer == 2 or gatlayer ==3:
        Tot_hidden = nContexts+ nHidden[0]
    else:
        Tot_hidden = nHidden[0]

    #Initialize weights
    W_inp_hid=np.random.normal(size=(Tot_input,nHidden[0]-1))
    W_hidden = np.random.normal(size=(Tot_hidden, nHidden[1]-1))
    W_hid_out=np.random.normal(size=(nHidden[1], nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    hid_hid_start = W_hidden
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, Tot_input, nHidden[0]-1))
    hid_hid_trained = np.zeros((nRepeats, nContexts, Tot_hidden, nHidden[1]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[1], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):
                #Compute network activation
                In = Inputs[r,t,:]
                C = Contexts[c,:]

                if gatlayer ==1 or gatlayer ==3:
                    totI = np.concatenate((C, In))
                else:
                    totI = In

                Hidden1[:nHidden[0]-1]=sigmoid_activation(totI, W_inp_hid, 0)

                if gatlayer ==2 or gatlayer ==3:
                    totH = np.concatenate((C, Hidden1))
                else:
                    totH = Hidden1

                Hidden2[:nHidden[1]-1] = sigmoid_activation(totH, W_hidden, 0)

                Out = sigmoid_activation(Hidden2, W_hid_out, 0)

                #Compute network evaluation metrics
                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2))

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_hidden = learning_rate * totH.reshape((Tot_hidden,1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])).reshape((1,nHidden[1]-1))
                update_inp_hid = learning_rate * totI.reshape((Tot_input,1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])) @ np.transpose(W_hidden[:nHidden[0]-1,:]) * Hidden1[:nHidden[0]-1] * (1-Hidden1[:nHidden[0]-1])).reshape((1,nHidden[0]-1))
                if not gate_learning:
                    if gatlayer ==1 or gatlayer ==3:
                        update_inp_hid[0:nContexts,:]=np.zeros((nContexts,nHidden[0]-1))
                    if gatlayer ==2 or gatlayer ==3:
                        update_hidden[0:nContexts,:]=np.zeros((nContexts,nHidden[1]-1))

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_hidden = W_hidden + update_hidden

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            hid_out_trained[r,c,:,:] = W_hid_out
            hid_hid_trained[r,c,:,:] = W_hidden

    #save results
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
