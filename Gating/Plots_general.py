import numpy as np
from matplotlib import pyplot as plt
import os

Stroop_folder = "/Volumes/backupdisc/Modular_learning/Data_Stroop/"
Trees_folder = "/Volumes/backupdisc/Modular_learning/Data_Leafs/"
MNIST_folder = "/Volumes/backupdisc/Modular_learning/Data_MNIST/"
Plots_folder = "/Volumes/backupdisc/Modular_learning/Plots_general/"

# Loading Accuracy data
Stroop_dir = np.load(Stroop_folder + "Accuracy_gen_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Accuracy_gen_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Accuracy_gen_MNIST.npy", allow_pickle = True)

model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k", "c", "m"]
contexts_Stroop = ["A", "B", "C", "D", "E"]
contexts_Trees = ["Leaf", "Branch", "AND", "XOR"]
contexts_MNIST = ["Odd", "Even", ">5", "<5",">3","<7"]

learning_rates_1= np.arange(0,1.1,0.1)
learning_rates_2= np.arange(0,0.11,0.01)

# Figure 1: Accuracy per learning rate in test phase
os.chdir(Plots_folder)

fig, axs = plt.subplots(3,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],1),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],1),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],1),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_1+m*0.01, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],1),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_2+m*0.001, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],1),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_2+m*0.001, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],1),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],1)/1.96, lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,0].set_xticks(np.arange(0,1.1,.3))
axs[0,1].set_xticks(np.arange(0,1.1,.3))
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_xticks(np.arange(0,1.1,.2))
axs[1,1].set_xticks(np.arange(0,1.1,.2))
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[2,0].set_xlabel("\u03B1", fontsize = 9)
axs[2,1].set_xlabel("\u03B1", fontsize = 9)
axs[2,0].set_xticks(np.arange(0,.11,.03))
axs[2,1].set_xticks(np.arange(0,.11,.03))

for i in range(3):
    axs[i,0].set_ylabel("Accuracy%", fontsize = 9)
    for j in range(2):
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.325, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.325, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,15/2.54)
plt.savefig("Accuracy_generalization_lr.png", dpi = 300)

# Figure 2: Accuracy per context in test phase
fig, axs = plt.subplots(3,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].errorbar(np.arange(len(contexts_Stroop))+m*0.02, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(np.arange(len(contexts_Stroop))+m*0.02, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(len(contexts_Trees))+m*0.02, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(len(contexts_Trees))+m*0.02, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(np.arange(len(contexts_MNIST))+m*0.02, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(np.arange(len(contexts_MNIST))+m*0.02, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,0].set_xticks(np.arange(len(contexts_Stroop)))
axs[0,1].set_xticks(np.arange(len(contexts_Stroop)))
axs[0,0].set_xticklabels(contexts_Stroop)
axs[0,1].set_xticklabels(contexts_Stroop)
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_xticks(np.arange(len(contexts_Trees)))
axs[1,1].set_xticks(np.arange(len(contexts_Trees)))
axs[1,0].set_xticklabels(contexts_Trees)
axs[1,1].set_xticklabels(contexts_Trees)
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[2,0].set_xlabel("Task", fontsize = 9)
axs[2,1].set_xlabel("Task", fontsize = 9)
axs[2,0].set_xticks(np.arange(len(contexts_MNIST)))
axs[2,1].set_xticks(np.arange(len(contexts_MNIST)))
axs[2,0].set_xticklabels(contexts_MNIST)
axs[2,1].set_xticklabels(contexts_MNIST)

for i in range(3):
    axs[i,0].set_ylabel("Accuracy%", fontsize = 9)
    for j in range(2):
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.325, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.325, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,15/2.54)
plt.savefig("Accuracy_generalization_context.png", dpi = 300)

Stroop_dir = np.load(Stroop_folder + "Accuracy_train_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Accuracy_train_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Accuracy_train_MNIST.npy", allow_pickle = True)

nRepetitions = 3

# Figure 3: Accuracy per context repetition in training phase
fig, axs = plt.subplots(3,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],0)/1.96, lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,0].set_xticks(np.arange(nRepetitions))
axs[0,1].set_xticks(np.arange(nRepetitions))
axs[0,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[0,1].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_xticks(np.arange(nRepetitions))
axs[1,1].set_xticks(np.arange(nRepetitions))
axs[1,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[1,1].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[2,0].set_xlabel("Task repetition", fontsize = 9)
axs[2,1].set_xlabel("Task repetition", fontsize = 9)
axs[2,0].set_xticks(np.arange(nRepetitions))
axs[2,1].set_xticks(np.arange(nRepetitions))
axs[2,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[2,1].set_xticklabels(np.arange(nRepetitions).astype(int)+1)

for i in range(3):
    axs[i,0].set_ylabel("Accuracy%", fontsize = 9)
    for j in range(2):
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.325, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.325, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,15/2.54)
plt.savefig("Accuracy_training_repetition.png", dpi = 300)

#Loading in RDM data
Stroop_dir = np.load(Stroop_folder + "RDM_gen_Stroop_2.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "RDM_gen_Trees_2.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "RDM_gen_MNIST_2.npy", allow_pickle = True)

# Figure 4: RDM correlation per learning rate in test phase
fig, axs = plt.subplots(4, 2)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, -Stroop_dir[()]['12_Hidden_mean'][m,:],  Stroop_dir[()]['12_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates_1+m*0.01, -Stroop_dir[()]['24_Hidden_mean'][m,:],  Stroop_dir[()]['24_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, -Trees_dir[()]['12_Hidden_mean'][m,:],  Trees_dir[()]['12_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(learning_rates_1+m*0.01, -Trees_dir[()]['24_Hidden_mean'][m,:],  Trees_dir[()]['24_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,0].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['1_Hidden_mean'][m,:],  MNIST_dir[()]['1_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,1].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['2_Hidden_mean'][m,:],  MNIST_dir[()]['2_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,0].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['2_1_Hidden_mean'][m,:],  MNIST_dir[()]['2_1_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,1].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['2_2_Hidden_mean'][m,:],  MNIST_dir[()]['2_2_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])

for j in range(4):
    axs[j,0].set_ylabel("Dissimilarity correlation", fontsize = 9)
    for i in range(2):
        axs[j,i].spines['top'].set_visible(False)
        axs[j,i].spines['right'].set_visible(False)

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,0].set_xticks(np.arange(0,1.1,.3))
axs[0,1].set_xticks(np.arange(0,1.1,.3))
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_xticks(np.arange(0,1.1,.3))
axs[1,1].set_xticks(np.arange(0,1.1,.3))
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[2,0].set_xticks(np.arange(0,.11,.03))
axs[2,1].set_xticks(np.arange(0,.11,.03))
axs[3,0].set_title("hidden layer 1 of 2", fontsize = 9, fontweight = "bold")
axs[3,1].set_title("hidden layer 2 of 2", fontsize = 9, fontweight = "bold")
axs[3,0].set_xlabel("\u03B1", fontsize = 9)
axs[3,1].set_xlabel("\u03B1", fontsize = 9)
axs[3,0].set_xticks(np.arange(0,.11,.03))
axs[3,1].set_xticks(np.arange(0,.11,.03))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.8, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.6, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.4, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST 2 layers', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.68, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.475, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.27, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.68, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.475, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.27, 'h', va='center', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85, hspace = .4, wspace=.4)
fig.set_size_inches(15/2.54,20/2.54)

plt.savefig("RDM_generalization_lr_2.png", dpi = 300)

Stroop_dir = np.load(Stroop_folder + "RDM_train_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "RDM_train_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "RDM_train_MNIST.npy", allow_pickle = True)

# Figure 5: RDM correlation per context repetition in training phase
fig, axs = plt.subplots(4, 2)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].errorbar(np.arange(nRepetitions)+m*0.02, -Stroop_dir[()]['12_Hidden_mean'][m,:],  Stroop_dir[()]['12_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(np.arange(nRepetitions)+m*0.02, -Stroop_dir[()]['24_Hidden_mean'][m,:],  Stroop_dir[()]['24_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(np.arange(nRepetitions)+m*0.02, -Trees_dir[()]['12_Hidden_mean'][m,:],  Trees_dir[()]['12_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(np.arange(nRepetitions)+m*0.02, -Trees_dir[()]['24_Hidden_mean'][m,:],  Trees_dir[()]['24_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,0].errorbar(np.arange(nRepetitions)+m*0.02, -MNIST_dir[()]['1_Hidden_mean'][m,:],  MNIST_dir[()]['1_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,1].errorbar(np.arange(nRepetitions)+m*0.02, -MNIST_dir[()]['2_Hidden_mean'][m,:],  MNIST_dir[()]['2_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,0].errorbar(np.arange(nRepetitions)+m*0.02, -MNIST_dir[()]['2_1_Hidden_mean'][m,:],  MNIST_dir[()]['2_1_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,1].errorbar(np.arange(nRepetitions)+m*0.02, -MNIST_dir[()]['2_2_Hidden_mean'][m,:],  MNIST_dir[()]['2_2_Hidden_ci'][m,:]/1.96, lw = 2, color=color_values[m], label=model_labels[m])

for j in range(4):
    axs[j,0].set_ylabel("Dissimilarity correlation", fontsize = 9)
    for i in range(2):
        axs[j,i].spines['top'].set_visible(False)
        axs[j,i].spines['right'].set_visible(False)

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,0].set_xticks(np.arange(nRepetitions))
axs[0,1].set_xticks(np.arange(nRepetitions))
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_xticks(np.arange(nRepetitions))
axs[1,1].set_xticks(np.arange(nRepetitions))
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[2,0].set_xticks(np.arange(nRepetitions))
axs[2,1].set_xticks(np.arange(nRepetitions))
axs[3,0].set_title("hidden layer 1 of 2", fontsize = 9, fontweight = "bold")
axs[3,1].set_title("hidden layer 2 of 2", fontsize = 9, fontweight = "bold")
axs[3,0].set_xlabel("Task repetition", fontsize = 9)
axs[3,1].set_xlabel("Task repetition", fontsize = 9)
axs[3,0].set_xticks(np.arange(nRepetitions))
axs[3,1].set_xticks(np.arange(nRepetitions))
axs[3,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[3,1].set_xticklabels(np.arange(nRepetitions).astype(int)+1)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.8, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.6, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.4, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST 2 layers', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.subplots_adjust(left= .15, right=.85, hspace = .4, wspace=.4)
fig.set_size_inches(15/2.54,20/2.54)

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.68, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.475, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.27, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.68, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.475, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.27, 'h', va='center', fontsize = 9, fontweight = "bold")

plt.savefig("RDM_training_repetitions.png", dpi = 300)

#Loading in PCA data
Stroop_dir = np.load(Stroop_folder + "PCA_gen_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "PCA_gen_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "PCA_gen_MNIST.npy", allow_pickle = True)

rate = 5
Rep = 50
repid = 38#np.random.randint(0,Rep)
print(repid)

# Figure 7: PCA results
fig, axs = plt.subplots(6,4)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    for i in range(len(contexts_Stroop)):
        axs[0,m].plot(Stroop_dir[()]['12_Hidden'][m,rate,repid,0,i,:], Stroop_dir[()]['12_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Stroop[i], markersize = 1)
        axs[0,0].set_ylabel("Dimension 2", fontsize = 8)
        axs[1,m].plot(Stroop_dir[()]['24_Hidden'][m,rate,repid,0,i,:], Stroop_dir[()]['24_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Stroop[i], markersize = 1)
        axs[1,0].set_ylabel("Dimension 2", fontsize = 8)
    for i in range(len(contexts_Trees)):
        axs[2,m].plot(Trees_dir[()]['12_Hidden'][m,rate,repid,0,i,:], Trees_dir[()]['12_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Trees[i], markersize = 1)
        axs[2,0].set_ylabel("Dimension 2", fontsize = 8)
        axs[3,m].plot(Trees_dir[()]['24_Hidden'][m,rate,repid,0,i,:], Trees_dir[()]['24_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Trees[i], markersize = 1)
        axs[3,0].set_ylabel("Dimension 2", fontsize = 8)
    for i in range(len(contexts_MNIST)):
        axs[4,m].plot(MNIST_dir[()]['1_Hidden'][m,rate,repid,0,i,:], MNIST_dir[()]['1_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_MNIST[i], markersize = 1)
        axs[4,0].set_ylabel("Dimension 2", fontsize = 8)
        axs[5,m].plot(MNIST_dir[()]['2_Hidden'][m,rate,repid,0,i,:], MNIST_dir[()]['2_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_MNIST[i], markersize = 1)
        axs[5,0].set_ylabel("Dimension 2", fontsize = 8)
        #axs[6,m].plot(MNIST_dir[()]['2_1_Hidden'][m,rate,repid,0,i,:], MNIST_dir[()]['2_1_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_MNIST[i], markersize = 1)
        #axs[6,0].set_ylabel("Dimension 2", fontsize = 8)
        #axs[7,m].plot(MNIST_dir[()]['2_2_Hidden'][m,rate,repid,0,i,:], MNIST_dir[()]['2_2_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_MNIST[i], markersize = 1)
        #axs[7,0].set_ylabel("Dimension 2", fontsize = 8)

    axs[0,m].set_title(model_labels[m], fontsize = 8, fontweight="bold")
    axs[5,m].set_xlabel("Dimension 1", fontsize = 8)

axs[0,3].legend(fontsize = 8, loc="lower right", bbox_to_anchor=(1.775, -1), title="Task")
axs[2,3].legend(fontsize = 8, loc="lower right", bbox_to_anchor=(1.925, -1), title="Task")
axs[4,3].legend(fontsize = 8, loc="lower right", bbox_to_anchor=(1.8, -1), title="Task")
#axs[6,3].legend(fontsize = 8, loc="lower right", bbox_to_anchor=(1.75, -1), title="Context")

fig.subplots_adjust(left = .125, right=.85, hspace =.25, wspace=.4)
fig.set_size_inches(17.5/2.54,24/2.54)
fig.text(0.01, 0.8375, 'Stroop 12 neurons', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
fig.text(0.01, 0.7, 'Stroop 24 neurons', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
fig.text(0.01, 0.5625, 'Trees 12 neurons', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
fig.text(0.01, 0.425, 'Trees 24 neurons', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
fig.text(0.01, 0.2875, 'MNIST 1 layer', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
fig.text(0.01, 0.15, 'MNIST 2 layers', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
#fig.text(0.01, 0.2, 'MNIST layer 1 of 2', va='center', rotation='vertical', fontsize = 8, fontweight="bold")
#fig.text(0.01, 0.1, 'MNIST layer 2 of 2', va='center', rotation='vertical', fontsize = 8, fontweight="bold")

fig.text(0.085, 0.88, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.085, 0.745, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.085, 0.61, 'i', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.085, 0.475, 'm', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.085, 0.34, 'q', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.085, 0.205, 'u', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.88, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.745, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.61, 'j', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.475, 'n', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.34, 'r', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.28, 0.205, 'v', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.88, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.745, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.61, 'k', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.475, 'o', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.34, 's', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.475, 0.205, 'w', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.88, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.745, 'h', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.61, 'l', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.475, 'p', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.34, 't', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.67, 0.205, 'x', va='center', fontsize = 9, fontweight = "bold")

plt.savefig("PCA_generalization.png", dpi=300)
"""
#Loading in Activation data
Stroop_dir = np.load(Stroop_folder + "Activation_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Activation_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Activation_MNIST.npy", allow_pickle = True)

from scipy import stats

act_12_stroop = Stroop_dir[()]['12_Hidden']
density_12_stroop_1 = stats.gaussian_kde(act_12_stroop[0,1::,:,:,:,:].reshape(-1))
density_12_stroop_2 = stats.gaussian_kde(act_12_stroop[1,1::,:,:,:,:].reshape(-1))
density_12_stroop_3 = stats.gaussian_kde(act_12_stroop[2,1::,:,:,:,:].reshape(-1))
density_12_stroop_4 = stats.gaussian_kde(act_12_stroop[3,1::,:,:,:,:].reshape(-1))

act_24_stroop = Stroop_dir[()]['12_Hidden']
density_24_stroop_1 = stats.gaussian_kde(act_24_stroop[0,1::,:,:,:,:].reshape(-1))
density_24_stroop_2 = stats.gaussian_kde(act_24_stroop[1,1::,:,:,:,:].reshape(-1))
density_24_stroop_3 = stats.gaussian_kde(act_24_stroop[2,1::,:,:,:,:].reshape(-1))
density_24_stroop_4 = stats.gaussian_kde(act_24_stroop[3,1::,:,:,:,:].reshape(-1))

act_12_trees = Trees_dir[()]['12_Hidden']
density_12_trees_1 = stats.gaussian_kde(act_12_trees[0,1::,:,:,:,:].reshape(-1))
density_12_trees_2 = stats.gaussian_kde(act_12_trees[1,1::,:,:,:,:].reshape(-1))
density_12_trees_3 = stats.gaussian_kde(act_12_trees[2,1::,:,:,:,:].reshape(-1))
density_12_trees_4 = stats.gaussian_kde(act_12_trees[3,1::,:,:,:,:].reshape(-1))

act_24_trees = Trees_dir[()]['12_Hidden']
density_24_trees_1 = stats.gaussian_kde(act_24_trees[0,1::,:,:,:,:].reshape(-1))
density_24_trees_2 = stats.gaussian_kde(act_24_trees[1,1::,:,:,:,:].reshape(-1))
density_24_trees_3 = stats.gaussian_kde(act_24_trees[2,1::,:,:,:,:].reshape(-1))
density_24_trees_4 = stats.gaussian_kde(act_24_trees[3,1::,:,:,:,:].reshape(-1))

act_1_mnist = MNIST_dir[()]['1_Hidden']
density_1_mnist_1 = stats.gaussian_kde(act_1_mnist[0,1::,:,:,:,:].reshape(-1))
density_1_mnist_2 = stats.gaussian_kde(act_1_mnist[1,1::,:,:,:,:].reshape(-1))
density_1_mnist_3 = stats.gaussian_kde(act_1_mnist[2,1::,:,:,:,:].reshape(-1))
density_1_mnist_4 = stats.gaussian_kde(act_1_mnist[3,1::,:,:,:,:].reshape(-1))

act_2_mnist = MNIST_dir[()]['2_Hidden']
density_2_mnist_1 = stats.gaussian_kde(act_2_mnist[0,1::,:,:,:,:].reshape(-1))
density_2_mnist_2 = stats.gaussian_kde(act_2_mnist[1,1::,:,:,:,:].reshape(-1))
density_2_mnist_3 = stats.gaussian_kde(act_2_mnist[2,1::,:,:,:,:].reshape(-1))
density_2_mnist_4 = stats.gaussian_kde(act_2_mnist[3,1::,:,:,:,:].reshape(-1))

print(np.shape(act_2_mnist))
density_2_1_mnist_1 = stats.gaussian_kde(act_2_mnist[0,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_2 = stats.gaussian_kde(act_2_mnist[1,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_3 = stats.gaussian_kde(act_2_mnist[2,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_4 = stats.gaussian_kde(act_2_mnist[3,1::,:,::301,:,:].reshape(-1))

density_2_2_mnist_1 = stats.gaussian_kde(act_2_mnist[0,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_2 = stats.gaussian_kde(act_2_mnist[1,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_3 = stats.gaussian_kde(act_2_mnist[2,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_4 = stats.gaussian_kde(act_2_mnist[3,1::,:,301::,:,:].reshape(-1))

x = np.linspace(-.5,1.5,500)
y_12_stroop=[density_12_stroop_1(x), density_12_stroop_2(x), density_12_stroop_3(x), density_12_stroop_4(x)]
y_24_stroop=[density_24_stroop_1(x), density_24_stroop_2(x), density_24_stroop_3(x), density_24_stroop_4(x)]

y_12_trees=[density_12_trees_1(x), density_12_trees_2(x), density_12_trees_3(x), density_12_trees_4(x)]
y_24_trees=[density_24_trees_1(x), density_24_trees_2(x), density_24_trees_3(x), density_24_trees_4(x)]

y_1_mnist=[density_1_mnist_1(x), density_1_mnist_2(x), density_1_mnist_3(x), density_1_mnist_4(x)]
y_2_mnist=[density_2_mnist_1(x), density_2_mnist_2(x), density_2_mnist_3(x), density_2_mnist_4(x)]

y_2_1_mnist=[density_2_1_mnist_1(x), density_2_1_mnist_2(x), density_2_1_mnist_3(x), density_2_1_mnist_4(x)]
y_2_2_mnist=[density_2_2_mnist_1(x), density_2_2_mnist_2(x), density_2_2_mnist_3(x), density_2_2_mnist_4(x)]

fig, axs = plt.subplots(4,2)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(model_labels)):
    axs[0,0].plot(x,y_12_stroop[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[0,0].fill_between(x,y_12_stroop[m],0,color=color_values[m], alpha=.1)
    axs[0,1].plot(x,y_24_stroop[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[0,1].fill_between(x,y_24_stroop[m],0,color=color_values[m], alpha=.1)

    axs[1,0].plot(x,y_12_trees[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[1,0].fill_between(x,y_12_trees[m],0,color=color_values[m], alpha=.1)
    axs[1,1].plot(x,y_24_trees[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[1,1].fill_between(x,y_24_trees[m],0,color=color_values[m], alpha=.1)

    axs[2,0].plot(x,y_1_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[2,0].fill_between(x,y_1_mnist[m],0,color=color_values[m], alpha=.1)
    axs[2,1].plot(x,y_2_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[2,1].fill_between(x,y_2_mnist[m],0,color=color_values[m], alpha=.1)

    axs[3,0].plot(x,y_2_1_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[3,0].fill_between(x,y_2_1_mnist[m],0,color=color_values[m], alpha=.1)
    axs[3,1].plot(x,y_2_2_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[3,1].fill_between(x,y_2_2_mnist[m],0,color=color_values[m], alpha=.1)

for j in range(4):
    axs[j,0].set_ylabel("Density Hidden layer", fontsize = 9)
    for i in range(2):
        axs[j,i].spines['top'].set_visible(False)
        axs[j,i].spines['right'].set_visible(False)
        axs[3,i].set_xlabel("Activity")

axs[0,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1,1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[2,0].set_title("1 hidden layer", fontsize = 9, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 9, fontweight = "bold")
axs[3,0].set_title("hidden layer 1 of 2", fontsize = 9, fontweight = "bold")
axs[3,1].set_title("hidden layer 2 of 2", fontsize = 9, fontweight = "bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.8, 'Stroop dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.6, 'Trees dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.4, 'MNIST dataset', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST 2 layers', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.68, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.475, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.27, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.68, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.475, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.27, 'h', va='center', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85, hspace = .4, wspace=.4)
fig.set_size_inches(15/2.54,20/2.54)

plt.savefig("Activation_density.png", dpi = 300)
