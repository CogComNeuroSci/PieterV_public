import numpy as np

def sigmoid_activation(inp, W, bias):
  net=inp @ W + bias
  act = 1/(1+np.exp(-net))
  return act

def relu_activation(inp, W, bias):
  net = inp @ W + bias
  act = np.maximum(0,net)
  return act

def Model_multiplicative(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = np.array([200,100,100])):

    #Define network size
    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    nHidden = resources+1
    nOutput =1

    #Initialize weights
    W_inp_hid=np.random.normal(size=(nInput,nHidden[0]-1))
    if gate_learning:
        W_cont_hid=np.random.uniform(size=(nContexts, nHidden[0]-1))
    else:
        W_cont_hid=np.random.normal(size=(nContexts, nHidden[0]-1))
    W_hidden1 = np.random.normal(size=(nHidden[0], nHidden[1]-1))
    W_hidden2 = np.random.normal(size=(nHidden[1], nHidden[2]-1))
    W_hid_out=np.random.normal(size=(nHidden[2], nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    cont_hid_start = W_cont_hid
    hid1_hid2_start = W_hidden1
    hid2_hid3_start = W_hidden2
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C=np.zeros((nContexts))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Hidden3=np.zeros((nHidden[2]))
    Hidden3[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, nInput, nHidden[0]-1))
    cont_hid_trained = np.zeros((nRepeats, nContexts, nContexts, nHidden[0]-1))
    hid1_hid2_trained = np.zeros((nRepeats, nContexts, nHidden[0], nHidden[1]-1))
    hid2_hid3_trained = np.zeros((nRepeats, nContexts, nHidden[1], nHidden[2]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[2], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):

                #Compute network activation
                In = Inputs[r,t,:]
                C = Contexts[c,:]
                H=sigmoid_activation(In, W_inp_hid, 0)
                G=relu_activation(C, W_cont_hid, 0)
                Hidden1[:nHidden[0]-1]=H*G
                Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, W_hidden1, 0)
                Hidden3[:nHidden[1]-1] = sigmoid_activation(Hidden2, W_hidden2, 0)
                Out = sigmoid_activation(Hidden3, W_hid_out, 0)

                #Compute network evaluation metrics
                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2, Hidden3))

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden3.reshape((nHidden[2],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_hidden2 = learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[2]-1] * (1-Hidden3[:nHidden[2]-1])).reshape((1,nHidden[2]-1))
                update_hidden1 = learning_rate * Hidden1.reshape((nHidden[0],1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[2]-1] * (1-Hidden3[:nHidden[2]-1]))@ np.transpose(W_hidden2[:-1,:]) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])).reshape((1,nHidden[1]-1))
                update_inp_hid = learning_rate * In.reshape((nInput,1)) @ ((((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[1]-1] * (1-Hidden3[:nHidden[1]-1])) @ np.transpose(W_hidden2[:-1,:]) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1]))@ np.transpose(W_hidden1[:-1,:]) * G * H * (1-H)).reshape((1,nHidden[0]-1))
                if gate_learning:
                    update_cont_hid = learning_rate * C.reshape((nContexts,1)) @ ((((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[1]-1] * (1-Hidden3[:nHidden[1]-1])) @ np.transpose(W_hidden2[:-1,:]) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1]))@ np.transpose(W_hidden1[:-1,:]) * H * (G>0)).reshape((1,nHidden[0]-1))
                else:
                    update_cont_hid = np.zeros((nContexts,nHidden[0]-1))

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_cont_hid = W_cont_hid + update_cont_hid
                W_hidden1 = W_hidden1 + update_hidden1
                W_hidden2 = W_hidden2 + update_hidden2

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            cont_hid_trained[r,c,:,:] = W_cont_hid
            hid_out_trained[r,c,:,:] = W_hid_out
            hid1_hid2_trained[r,c,:,:] = W_hidden1
            hid2_hid3_trained[r,c,:,:] = W_hidden2

    #save results
    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Context_Weights": cont_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Initial_Hidden1_Weights": hid1_hid2_start,
        "Initial_Hidden2_Weights": hid2_hid3_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Context_Weights": cont_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Trained_Hidden1_Weights": hid1_hid2_trained,
        "Trained_Hidden2_Weights": hid2_hid3_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy,
        "Criterion": Criterion
        }

    print("Simulation succesfully terminated")

    return result

def Model_additive(Inputs, Contexts, Objectives, nRepeats, Part_trials, learning_rate, gate_learning = True, resources = np.array([300,100])):

    #Define network size
    nInput = np.size(Inputs,2)
    nContexts = np.size(Contexts,1)
    Tot_input = nContexts+nInput
    nHidden = resources+1
    nOutput = 1

    #Initialize weights
    W_inp_hid=np.random.normal(size=(Tot_input,nHidden[0]-1))
    W_hidden1 = np.random.normal(size=(nHidden[0], nHidden[1]-1))
    W_hidden2 = np.random.normal(size=(nHidden[1], nHidden[2]-1))
    W_hid_out=np.random.normal(size=(nHidden[2], nOutput))

    #Store initial weights
    inp_hid_start = W_inp_hid
    hid1_hid2_start = W_hidden1
    hid2_hid3_start = W_hidden2
    hid_out_start = W_hid_out

    #Initialize network layers
    In=np.zeros((nInput))
    C = np.zeros((nContexts))
    tot = np.zeros((Tot_input))
    Hidden1=np.zeros((nHidden[0]))
    Hidden1[-1]=1
    Hidden2=np.zeros((nHidden[1]))
    Hidden2[-1]=1
    Hidden3=np.zeros((nHidden[2]))
    Hidden3[-1]=1
    Out=np.zeros((nOutput))

    #Evaluation metrics
    Accuracy = np.zeros((nRepeats, nContexts, Part_trials))
    Activation = np.zeros((np.sum(nHidden), nRepeats, nContexts, Part_trials))
    Error = np.zeros((nRepeats, nContexts, Part_trials))
    Criterion = np.zeros((nRepeats, nContexts))

    inp_hid_trained = np.zeros((nRepeats, nContexts, Tot_input, nHidden[0]-1))
    hid1_hid2_trained = np.zeros((nRepeats, nContexts, nHidden[0], nHidden[1]-1))
    hid2_hid3_trained = np.zeros((nRepeats, nContexts, nHidden[1], nHidden[2]-1))
    hid_out_trained = np.zeros((nRepeats, nContexts, nHidden[2], nOutput))

    for r in range(nRepeats):
        for c in range(nContexts):
            #If criterion is not reached it will hold the total amount of trials
            Criterion[r,c]=Part_trials
            for t in range(Part_trials):

                #Compute network activation
                In = Inputs[r,t,:]
                C = Contexts[c,:]
                tot = np.concatenate((C, In))
                Hidden1[:nHidden[0]-1]=sigmoid_activation(tot, W_inp_hid, 0)
                Hidden2[:nHidden[1]-1] = sigmoid_activation(Hidden1, W_hidden1, 0)
                Hidden3[:nHidden[2]-1] = sigmoid_activation(Hidden2, W_hidden2, 0)
                Out = sigmoid_activation(Hidden3, W_hid_out, 0)

                #Compute network evaluation metrics
                response = np.round(Out)
                Obj = Objectives[c,r,t]
                CorResp = Obj
                Accuracy[r,c,t]=int(response == CorResp)
                Error[r,c,t] = np.mean((Obj-Out)**2)
                Activation[:,r,c,t] = np.concatenate((Hidden1, Hidden2, Hidden3))

                #Check for criterion
                if t>20:
                    if np.mean(Accuracy[r,c,t-20:t])>.7 and Criterion[r,c]==Part_trials:
                        Criterion[r,c]=t

                #Compute weight updates
                update_hid_out= learning_rate * Hidden3.reshape((nHidden[2],1)) @ ((Obj-Out) * Out * (1-Out)).reshape((1,nOutput))
                update_hidden2 = learning_rate * Hidden2.reshape((nHidden[1],1)) @ ((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[2]-1] * (1-Hidden3[:nHidden[2]-1])).reshape((1,nHidden[2]-1))
                update_hidden1 = learning_rate * Hidden1.reshape((nHidden[0],1)) @ (((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[2]-1] * (1-Hidden3[:nHidden[2]-1]))@ np.transpose(W_hidden2[:-1,:]) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1])).reshape((1,nHidden[1]-1))
                update_inp_hid = learning_rate * tot.reshape((Tot_input,1)) @ ((((((Obj-Out) * Out * (1-Out)) @ np.transpose(W_hid_out[:-1,:])) * Hidden3[:nHidden[1]-1] * (1-Hidden3[:nHidden[1]-1])) @ np.transpose(W_hidden2[:-1,:]) * Hidden2[:nHidden[1]-1] * (1-Hidden2[:nHidden[1]-1]))@ np.transpose(W_hidden1[:-1,:]) * Hidden1[:nHidden[0]-1] * (1-Hidden1[:nHidden[0]-1])).reshape((1,nHidden[0]-1))
                if not gate_learning:
                    update_inp_hid[0:nContexts,:]=np.zeros((nContexts,nHidden[0]-1))

                #Update weights
                W_hid_out = W_hid_out + update_hid_out
                W_inp_hid = W_inp_hid + update_inp_hid
                W_hidden1 = W_hidden1 + update_hidden1
                W_hidden2 = W_hidden2 + update_hidden2

            #save final weights
            inp_hid_trained[r,c,:,:] = W_inp_hid
            hid_out_trained[r,c,:,:] = W_hid_out
            hid1_hid2_trained[r,c,:,:] = W_hidden1
            hid2_hid3_trained[r,c,:,:] = W_hidden2

    #save results
    result = {
        "Initial_Input_Weights": inp_hid_start,
        "Initial_Output_Weights": hid_out_start,
        "Initial_Hidden1_Weights": hid1_hid2_start,
        "Initial_Hidden2_Weights": hid2_hid3_start,
        "Trained_Input_Weights": inp_hid_trained,
        "Trained_Output_Weights": hid_out_trained,
        "Trained_Hidden1_Weights": hid1_hid2_trained,
        "Trained_Hidden2_Weights": hid2_hid3_trained,
        "Error": Error,
        "Activation": Activation,
        "Accuracy": Accuracy,
        "Criterion": Criterion
        }

    print("Simulation succesfully terminated")

    return result
