#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 29 11:52:51 2023

@author: pieter
"""

import numpy as np
import pandas as pd
import tensorflow as tf
from scipy.stats import kde
import matplotlib.pyplot as plt
from tensorflow import keras as k
from sklearn.decomposition import PCA

#specify dataset
dataset = "Hein"

Design_folder = "/Users/pieter/Desktop/Model_study/Data_to_fit/"+dataset+"/"     #"/data/gent/430/vsc43099/Model_study/Behavioral_data/"+ dataset +"/"
result_folder = "/Users/pieter/Desktop/Model_study/Optimize_models/"+dataset+"/" #"/data/gent/430/vsc43099/Model_study/Optimal_data/"+ dataset +"/"

if dataset =="Verbeke":
    pplist=np.zeros((30))
    pplist[0:8]=np.arange(3,11)
    pplist[8]=12
    pplist[9:31]=np.arange(14,35)
    pplist = pplist.astype(int)
    nstim = 2
elif dataset =="Liu":
    pplist=np.arange(1,24)
    nstim = 2
elif dataset =="Online":
    pplist=np.arange(49)
    nstim = 2
elif dataset =="Xia":
    pplist=np.arange(1,108)
    nstim = 4
elif dataset =="Hein":
    pplist=np.arange(1,21)
    nstim = 1
elif dataset =="Huycke":
    pplist = np.arange(1,25)
    nstim = 36
elif dataset =="Cohen":
    pplist = np.arange(1,16)
    nstim = 1
elif dataset =="Goris/Stable":
    pplist=np.array([5, 7, 9, 10, 13, 18, 21, 24, 25, 27, 30, 31, 32, 33, 44, 46, 47, 49, 50, 51, 53, 63, 66, 72, 73, 78, 85, 87, 95, 98, 105, 107, 109, 113, 116, 119, 129, 132, 134, 135, 136, 138, 140, 143])
    nstim = 4
elif dataset =="Goris/Volatile":
    pplist=np.array([3, 4, 8, 11, 12, 16, 19, 23, 26, 29, 34, 36, 37, 40, 42, 52, 54, 55, 56, 61, 62, 64, 68, 69, 70, 71, 74, 75, 79, 80, 82, 83, 86, 92, 93, 94, 96, 97, 102, 106, 110, 112, 114, 117, 120, 121, 122, 124, 125, 126, 127, 128, 130, 139, 141, 142])
    nstim = 4
elif dataset =="Mukherjee":
    pplist = np.arange(1,65)
    nstim = 1

# build the model
def Model_construction(nStim = 2, nHidden=5, nTimesteps=10, pp = 1, bs =1):

    tf.random.set_seed(pp)

    S_T_1 = k.Input(shape=(nTimesteps, nStim,), batch_size = bs, name = "S_T-1")
    R_T_1 = k.Input(shape=(nTimesteps, 2,), batch_size = bs, name = "R_T-1")
    S_T = k.Input(shape=(nTimesteps, nStim,), batch_size = bs, name = "S_T")

    Inputs = k.layers.Concatenate()([S_T_1, R_T_1, S_T])

    Hidden = k.layers.GRU(nHidden, return_sequences= True, stateful = True, name = "Hidden", batch_input_shape=(bs,nTimesteps,nStim*2+2))(Inputs)

    Outputs = k.layers.Dense(2, activation = "softmax", name = "Output")(Hidden)

    model = k.Model(inputs=[S_T_1, R_T_1, S_T], outputs=Outputs)

    return model

#build the model again until the hidden layer, this can be used to extract hidden layer activity
def Hidden_model_build(nStim = 2, nHidden=5, nTimesteps=10, pp = 1, bs =1, bins=9, weights = []):

    tf.random.set_seed(pp)

    S_T_1 = k.Input(batch_input_shape = (bins, nTimesteps, nStim), name = "S_T-1")
    R_T_1 = k.Input(batch_input_shape = (bins, nTimesteps, 2), name = "R_T-1")
    S_T = k.Input(batch_input_shape = (bins, nTimesteps, nStim), name = "S_T")

    Inputs = k.layers.Concatenate()([S_T_1, R_T_1, S_T])

    print((bs,nTimesteps,nStim*2+2))
    Hidden = k.layers.GRU(nHidden, return_sequences= True, stateful = True, name = "Hidden", batch_input_shape=(bs,nTimesteps,nStim*2+2))(Inputs)

    model = k.Model(inputs=[S_T_1, R_T_1, S_T], outputs=Hidden)

    model.set_weights(weights[0:3])

    return model

# Prepare the data for running the neural network
def Prepare_data(pp = 1, binsize = 10):

    filename = Design_folder + "Data_subject_{}.csv".format(pp)

    data = pd.read_csv(filename, sep=",",encoding='utf-8')
    trials = np.shape(data.values)[0]

    nbins = trials/binsize

    if nbins %1 != 0:

        print("Warning: unapropriate binsize: nbins = {0:.3}".format(nbins))

        while nbins%1!=0:
            binsize -= 1
            nbins = trials/binsize

        print("new binsize is {0}".format(binsize))

    Stimuli = np.reshape(np.array(data.iloc[:,2])[0:trials],  (int(nbins), int(binsize)))
    nStim = len(np.unique(np.array(data.iloc[:,2])[0:trials]))
    Stimuli_act = tf.one_hot(Stimuli, nStim)

    Stimuli_previous = np.reshape(np.concatenate((np.zeros((1)), np.array(data.iloc[:,2])[:trials-1])),  (int(nbins), int(binsize)))
    Stimuli_act_T1 = tf.one_hot(Stimuli_previous, nStim).numpy()
    Stimuli_act_T1[0,0,:] = np.zeros((nStim))
    Stimuli_act_T1 = tf.convert_to_tensor(Stimuli_act_T1)

    Rewarded_response = np.zeros((trials))
    for t in range(trials):
        if np.array(data.iloc[:,4])[t] == np.array(data.iloc[:,5])[t]:
            Rewarded_response[t] = 1
        else:
            Rewarded_response[t] = 0

    Resp = np.reshape(Rewarded_response,  (int(nbins), int(binsize)))
    Resp_targets = tf.one_hot(Resp, 2)

    Resp_previous = np.reshape(np.concatenate((np.zeros((1)), Rewarded_response[:-1])),  (int(nbins), int(binsize)))
    Resp_act = tf.one_hot(Resp_previous, 2).numpy()
    Resp_act[0,0,:] = np.zeros((2))
    Resp_act = tf.convert_to_tensor(Resp_act)


    Return_dict = {
        "Trials": int(nbins),
        "Timesteps": binsize,
        "nStim": nStim,
        "S_T": Stimuli_act,
        "S_T_1": Stimuli_act_T1,
        "R_T_1": Resp_act,
        "Targets": Resp_targets,
        "Test_Targets": tf.one_hot(np.reshape(np.array(data.iloc[:,4])[0:trials],  (int(nbins), int(binsize))), 2)
        }

    return Return_dict

#Define items for the neural network fit
max_epochs = 1000
batchsize = 1

loss = k.losses.CategoricalCrossentropy()
opt = k.optimizers.Adam(learning_rate = .01)
callback = k.callbacks.EarlyStopping(monitor = 'loss', min_delta = .0001, patience = 10)

final_loss = []
Epochs = []
cumulated_reward = []
Accuracy = []

activation = []
feedback = []
rule = []

activation_stepwise = []
feedback_stepwise = []
rule_stepwise = []

#build and fit the network for every participant then evaluate it and extract data.
for pp in pplist:

    Dict = Prepare_data(pp, binsize = 10)

    Model = Model_construction(Dict["nStim"], 5, Dict["Timesteps"], pp, bs = batchsize)
    Model.compile(optimizer = opt, loss = loss, metrics = [k.metrics.CategoricalAccuracy(), k.metrics.CategoricalCrossentropy()])

    train_history = Model.fit([Dict["S_T_1"], Dict["R_T_1"], Dict["S_T"]], Dict["Targets"], batch_size = batchsize, callbacks = [callback], epochs = max_epochs, workers = 4, use_multiprocessing = True)

    Epochs.append(len(train_history.history["categorical_crossentropy"]))
    final_loss.append(train_history.history["categorical_crossentropy"][-1])
    cumulated_reward.append(train_history.history["categorical_accuracy"][-1]*Dict["Timesteps"]*Dict["Trials"])

    results = Model.evaluate([Dict["S_T_1"], Dict["R_T_1"], Dict["S_T"]], Dict["Test_Targets"], batch_size=batchsize)
    Accuracy.append(results[1])

    #For the Mukherjee and Hein dataset, we also extract hidden layer activation
    if dataset =="Mukherjee":
        new_model = Hidden_model_build(Dict["nStim"], 5, Dict["Timesteps"], pp, bs = batchsize, weights = Model.get_weights(), bins = 9)
        activation.append(new_model.predict([Dict["S_T_1"], Dict["R_T_1"], Dict["S_T"]]).reshape(90,5))
        feedback.append(Dict["Targets"])
        rule.append(Dict["Test_Targets"])
        pplist_mukherjee = pplist

    if dataset == "Hein":
        new_model = Hidden_model_build(Dict["nStim"], 5, Dict["Timesteps"], pp, bs = batchsize, weights = Model.get_weights(), bins =40)
        activation.append(new_model.predict([Dict["S_T_1"], Dict["R_T_1"], Dict["S_T"]], batch_size = 40).reshape(400,5))#np.concatenate((new_model.predict([Dict["S_T_1"][0:20], Dict["R_T_1"][0:20], Dict["S_T"][0:20]]).reshape(200,5), new_model.predict([Dict["S_T_1"][20::], Dict["R_T_1"][20::], Dict["S_T"][20::]]).reshape(200,5))))
        feedback.append(Dict["Targets"])
        filename = Design_folder + "Data_subject_{}.csv".format(pp)
        data = pd.read_csv(filename, sep=",",encoding='utf-8')
        rule.append(np.array(data.iloc[:,1]))
        pplist_Hein = pplist


Datafile = result_folder + "GRU_results.csv"
new_data = pd.DataFrame({ 'Subject':pplist, 'Loss':final_loss, 'Cumulated_Reward':cumulated_reward, 'Accuracy':Accuracy, "Trained_epochs": Epochs})
new_data.to_csv(Datafile)

# we make plots for the Mukherjee and Hein dataset.
if dataset =="Mukherjee":

    pca = PCA(n_components=2)

    Dist_R13 = np.zeros(len(pplist_mukherjee))
    Dist_R12 = np.zeros(len(pplist_mukherjee))

    Trials_2D = np.zeros((30, 3, 2, len(pplist_mukherjee)))
    Mean_2D = np.zeros((3, 2, len(pplist_mukherjee)))

    for pp in range(len(pplist_mukherjee)):

        R1 = np.mean(activation[pp][0:30,:], axis = 0)
        R2 = np.mean(activation[pp][30:60,:], axis = 0)
        R3 = np.mean(activation[pp][60::,:], axis = 0)

        Dist_R12[pp] = np.linalg.norm(R1 - R2)
        Dist_R13[pp] = np.linalg.norm(R1 - R3)

        pca_result = pca.fit_transform(activation[pp])
        Trials_2D[:,0,:,pp] = pca_result[0:30,:]
        Trials_2D[:,1,:,pp] = pca_result[30:60,:]
        Trials_2D[:,2,:,pp] = pca_result[60:90,:]

        Mean_2D[:,:,pp] = np.mean(Trials_2D[:,:,:,pp], axis = 0)


    density_R12 = kde.gaussian_kde(Dist_R12)
    density_R13 = kde.gaussian_kde(Dist_R13)
    x = np.linspace(0, 3, 300)

    chosen_pp = 28#np.random.choice(np.arange(len(pplist)))

    fig, ax = plt.subplots(2,2)
    plt.rcParams["font.size"]=8
    plt.rcParams["xtick.labelsize"]=8
    plt.rcParams["ytick.labelsize"]=8

    fig.set_size_inches(17/2.45, 9/2.45)
    ax[0,0].plot(x, density_R12(x), color = "red", label = "Opposite rule")
    ax[0,0].plot(x, density_R13(x), color = "blue", label = "Same rule")
    ax[0,0].set_ylabel("Density")
    ax[0,0].set_xlabel("Representational distance")
    ax[0,0].legend(bbox_to_anchor=(1.75, 1), prop = { "size": 8 })
    plt.subplots_adjust(right = .85, wspace=1, hspace=0.5)

    ax[0,1].plot(Mean_2D[0,0,chosen_pp], Mean_2D[0,1,chosen_pp], ls = 'None', marker = "$ B1 $", color = "m", ms = 10, label = "70%")
    ax[0,1].plot(Mean_2D[1,0,chosen_pp], Mean_2D[1,1,chosen_pp], ls = 'None', marker = "$ B2 $", color = "c", ms = 10, label = "30%")
    ax[0,1].plot(Mean_2D[2,0,chosen_pp], Mean_2D[2,1,chosen_pp], ls = 'None', marker = "$ B3 $", color = "gold", ms = 10,label = "70%")
    ax[0,1].set_ylim(-.2, .2)
    ax[0,1].set_ylabel("PC 1")
    ax[0,1].set_xlabel("PC 2")
    ax[0,1].legend(title = "P(Reward| Left)", bbox_to_anchor=(1, 1), prop = { "size": 8 })


if dataset =="Hein":

    pca = PCA(n_components=2)

    ids = []
    rules = np.zeros((400, len(pplist_Hein)))
    representations = np.zeros((10,5))
    Distances = np.zeros((45,len(pplist_Hein)))

    Trials_2D_h = np.zeros((400, 2, len(pplist_Hein)))
    Mean_2D_h = np.zeros((10, 2, len(pplist_Hein)))

    for pp in range(len(pplist_Hein)):

        R1_instances = np.where(rule[pp]==1)[0]
        R2_instances = np.where(rule[pp]==3)[0]
        R3_instances = np.where(rule[pp]==5)[0]
        R4_instances = np.where(rule[pp]==7)[0]
        R5_instances = np.where(rule[pp]==9)[0]

        ids.append(R1_instances[R1_instances < 200])
        ids.append(R2_instances[R2_instances < 200])
        ids.append(R3_instances[R3_instances < 200])
        ids.append(R4_instances[R4_instances < 200])
        ids.append(R5_instances[R5_instances < 200])

        ids.append(R1_instances[R1_instances > 199])
        ids.append(R2_instances[R2_instances > 199])
        ids.append(R3_instances[R3_instances > 199])
        ids.append(R4_instances[R4_instances > 199])
        ids.append(R5_instances[R5_instances > 199])

        Trials_2D_h[:,:,pp] = pca.fit_transform(activation[pp])

        trials = 0
        for r in range(10):

            representations[r,:] = np.mean(activation[pp][ids[pp*10+r],:], axis = 0)
            Mean_2D_h[r,:,pp] = np.mean(Trials_2D_h[ids[pp*10+r],:,pp], axis = 0)
            rules[trials:trials+len(ids[pp*10+r]),pp] = r
            trials += len(ids[pp*10+r])

        i = -1
        rel_type = np.zeros((45))
        for r1 in range(10):
            for r2 in range(r1+1,10):

                i+=1

                Distances[i, pp] = np.linalg.norm(representations[r1,:] - representations[r2, :])

                if r1 == 4 or r2 == 4 or r1 == 9 or r2 == 9:
                    rel_type[i]= 2
                elif r2-r1 == 5:
                    rel_type[i]= 0
                elif r2-r1 == 6 or r2-r1 == 1:
                    rel_type[i]= 1
                elif r2-r1 == 7 or r2-r1 == 2:
                    rel_type[i]= 3
                elif r2-r1 == 8 or r2-r1 == 3:
                    rel_type[i]= 4

    densities = []
    for i in range(5):
        densities.append(kde.gaussian_kde(np.reshape(Distances[rel_type==i,:], -1)))

    x = np.linspace(0, 3, 300)

    chosen_pp = 0#np.random.choice(np.arange(len(pplist)))

    colors = [(1,0,0), (.5,.5,0), (0,.5,0), (0,.5,.5), (0,0,1)]
    labels = ["Complete same", "Same response", "random condition", "Opposite response", "Complete opposite"]

    for i in range(5):
        ax[1,0].plot(x, densities[i](x), color = colors[i], label = labels[i])

    ax[1,0].set_ylabel("Density")
    ax[1,0].set_xlabel("Representational distance")
    ax[1,0].legend(bbox_to_anchor=(.85, 1), prop = { "size": 8 })

    colors2 = ["magenta", "cyan", "gold", "silver", "red", "blue", "green", "black", "orange" , "purple"]
    markers = ["o", "x", "*", "v", "^", "p", "<", ">", "s", "+"]
    labels = ["90%", "75%", "50%", "25%", "10%", "90%",  "75%", "50%", "25%", "10%"]
    for i in range(10):
        #ax[1,1].plot(Trials_2D_h[ids[chosen_pp*10+i],0,chosen_pp], Trials_2D_h[ids[chosen_pp*10+i],1,chosen_pp], marker = markers[i], color = colors2[i], alpha = .5, linestyle = "None", label = "Rule {}".format((i%5)+1))
        ax[1,1].plot(Mean_2D_h[i,0,chosen_pp], Mean_2D_h[i,1,chosen_pp], ls = "None", marker = "$ B{} $".format(i+1), color = colors2[i], ms = 10, alpha = .5, label = labels[(i%5)+1])

    ax[1,1].set_ylabel("PC1")
    ax[1,1].set_xlabel("PC2")
    ax[1,1].legend(title = "P(Reward| Left)", bbox_to_anchor=(1, 1.25), prop = { "size": 8 })
    #fig.tight_layout()

    plot_dir = "/Users/pieter/Desktop/Model_study/Analyses_results/"
    plt.savefig(plot_dir + "RNN_insights_bis.png", dpi=300)


    fig, ax = plt.subplots(1,2)
    plt.rcParams["font.size"]=8
    plt.rcParams["xtick.labelsize"]=8
    plt.rcParams["ytick.labelsize"]=8

    fig.set_size_inches(15/2.45, 12/2.45)
    ax[0].plot(x, density_R13(x), color = "blue", label = "Same rule")
    ax[0].plot(x, density_R12(x), color = "red", label = "Opposite rule")
    ax[0].set_ylabel("Density")
    ax[0].set_xlabel("Representational distance")
    ax[0].set_title("Reversal environment\n (Mukherjee dataset)", fontweight = "bold" )
    ax[0].spines['top'].set_visible(False)
    ax[0].spines['right'].set_visible(False)
    ax[0].legend(title = "Task relations", bbox_to_anchor=(.85, -.15), prop = { "size": 8 })
    plt.subplots_adjust(bottom = .25, wspace=.5, hspace=0.5)

    colors = [(0,0,1), (0,.5,1), (0,.5,0),(1,.5,0), (1,0,0)]
    labels = ["Complete same", "Same response", "random condition", "Opposite response", "Complete opposite"]

    for i in range(5):
        ax[1].plot(x, densities[i](x), color = colors[i], label = labels[i])

    ax[1].set_ylabel("Density")
    ax[1].set_xlabel("Representational distance")
    ax[1].legend(title = "Task relations", bbox_to_anchor=(1.25, -.125), ncol = 2, prop = { "size": 8 })
    ax[1].set_title("Stepwise environment\n (Hein dataset)", fontweight = "bold" )
    ax[1].spines['top'].set_visible(False)
    ax[1].spines['right'].set_visible(False)

    plot_dir = "/Users/pieter/Desktop/Model_study/Analyses_results/"
    plt.savefig(plot_dir + "RNN_insights.png", dpi=300)
