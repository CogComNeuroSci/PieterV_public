import numpy as np
from matplotlib import pyplot as plt
import os

Stroop_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/Stroop/"
Trees_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/Trees/"
MNIST_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/"
Gatelayer_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/gatelayer/"
Plots_folder = "/Volumes/backupdisc/Modular_learning/Plots_general/Revision/"

# Loading Accuracy data
Stroop_dir = np.load(Stroop_folder + "Accuracy_gen_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Accuracy_gen_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Accuracy_gen_MNIST.npy", allow_pickle = True)

model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k", "c", "m"]
contexts_Stroop = ["A", "B", "C", "D", "E"]
contexts_Trees = ["Leaf", "Branch", "AND", "XOR"]
contexts_MNIST = ["Odd", "Even", ">5", "<5",">3","<7"]

learning_rates_1= np.arange(0,1.1,0.2)
learning_rates_2= np.arange(0,0.11,0.02)

# Figure 5: Accuracy per learning rate in test phase
os.chdir(Plots_folder)

fig, axs = plt.subplots(3,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],1),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],1),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],1),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(learning_rates_1+m*0.01, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],1),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_2+m*0.001, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],1),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_2+m*0.001, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],1),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,2].errorbar(learning_rates_2+m*0.001, np.mean(MNIST_dir[()]['3_Hidden_mean'][m,:,:],1),np.mean(MNIST_dir[()]['3_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("24 hidden neurons", fontsize = 10, fontweight = "bold")
axs[2,0].set_title("1 hidden layer", fontsize = 10, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,2].set_title("3 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,0].set_xlabel("\u03B1", fontsize = 10)
axs[2,1].set_xlabel("\u03B1", fontsize = 10)
axs[2,2].set_xlabel("\u03B1", fontsize = 10)

for i in range(3):
    for j in range(3):
        axs[i,j].set_yticks([33.,50., 66., 83., 100.])
        axs[i,j].set_ylim(25,105)
        if j>0:
            axs[i,j].set_yticklabels(("","","","",""))
        else:
            axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
            axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

axs[0,1].spines['left'].set_visible(False)
axs[0,1].set_xticks([])
axs[0,1].set_yticks([])
axs[1,1].spines['left'].set_visible(False)
axs[0,1].spines['bottom'].set_visible(False)
axs[1,1].spines['bottom'].set_visible(False)
axs[1,1].set_xticks([])
axs[1,1].set_yticks([])

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc=(.425,.5), title = "Modulation")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.33, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.605, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.33, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.33, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.set_size_inches(15/2.54,13/2.54)
plt.savefig("Accuracy_generalization_lr.tiff", dpi = 300)
plt.show()

# Figure 2: Accuracy per context in test phase
fig, axs = plt.subplots(3,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(np.arange(len(contexts_Stroop))+m*0.02, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(np.arange(len(contexts_Stroop))+m*0.02, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(len(contexts_Trees))+m*0.02, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(np.arange(len(contexts_Trees))+m*0.02, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(np.arange(len(contexts_MNIST))+m*0.02, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(np.arange(len(contexts_MNIST))+m*0.02, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,2].errorbar(np.arange(len(contexts_MNIST))+m*0.02, np.mean(MNIST_dir[()]['3_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['3_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("24 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,0].set_xticks(np.arange(len(contexts_Stroop)))
axs[0,2].set_xticks(np.arange(len(contexts_Stroop)))
axs[0,0].set_xticklabels(contexts_Stroop)
axs[0,2].set_xticklabels(contexts_Stroop)
axs[1,0].set_xticks(np.arange(len(contexts_Trees)))
axs[1,2].set_xticks(np.arange(len(contexts_Trees)))
axs[1,0].set_xticklabels(contexts_Trees)
axs[1,2].set_xticklabels(contexts_Trees)
axs[2,0].set_title("1 hidden layer", fontsize = 10, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,2].set_title("3 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,0].set_xlabel("Task", fontsize = 10)
axs[2,1].set_xlabel("Task", fontsize = 10)
axs[2,2].set_xlabel("Task", fontsize = 10)
axs[2,0].set_xticks(np.arange(len(contexts_MNIST)))
axs[2,1].set_xticks(np.arange(len(contexts_MNIST)))
axs[2,2].set_xticks(np.arange(len(contexts_MNIST)))
axs[2,0].set_xticklabels(contexts_MNIST)
axs[2,1].set_xticklabels(contexts_MNIST)
axs[2,2].set_xticklabels(contexts_MNIST)

for i in range(3):
    for j in range(3):
        axs[i,j].set_yticks([33.,50., 66., 83., 100.])
        axs[i,j].set_ylim(20,105)
        if j>0:
            axs[i,j].set_yticklabels(("","","","",""))
        else:
            axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
            axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

axs[0,1].spines['left'].set_visible(False)
axs[0,1].set_xticks([])
axs[0,1].set_yticks([])
axs[1,1].spines['left'].set_visible(False)
axs[0,1].spines['bottom'].set_visible(False)
axs[1,1].spines['bottom'].set_visible(False)
axs[1,1].set_xticks([])
axs[1,1].set_yticks([])

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc=(.45,.5), title = "Modulation")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.33, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.605, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.33, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.33, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(20/2.54,13/2.54)
plt.savefig("Accuracy_generalization_context.tiff", dpi = 300)
plt.show()

Stroop_dir = np.load(Stroop_folder + "Accuracy_train_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Accuracy_train_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Accuracy_train_MNIST.npy", allow_pickle = True)

nRepetitions = 3

# Figure 3: Accuracy per context repetition in training phase
fig, axs = plt.subplots(3,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Stroop_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['12_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Stroop_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Stroop_dir[()]['24_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Trees_dir[()]['12_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['12_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(Trees_dir[()]['24_Hidden_mean'][m,:,:],0),np.mean(Trees_dir[()]['24_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(MNIST_dir[()]['1_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['1_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(MNIST_dir[()]['2_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['2_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,2].errorbar(np.arange(nRepetitions)+m*0.02, np.mean(MNIST_dir[()]['3_Hidden_mean'][m,:,:],0),np.mean(MNIST_dir[()]['3_Hidden_ci'][m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("24 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,0].set_xticks(np.arange(nRepetitions))
axs[0,2].set_xticks(np.arange(nRepetitions))
axs[0,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[0,2].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[1,0].set_xticks(np.arange(nRepetitions))
axs[1,2].set_xticks(np.arange(nRepetitions))
axs[1,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[1,2].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[2,0].set_title("1 hidden layer", fontsize = 10, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,2].set_title("3 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,0].set_xlabel("Task repetition", fontsize = 10)
axs[2,1].set_xlabel("Task repetition", fontsize = 10)
axs[2,2].set_xlabel("Task repetition", fontsize = 10)
axs[2,0].set_xticks(np.arange(nRepetitions))
axs[2,1].set_xticks(np.arange(nRepetitions))
axs[2,2].set_xticks(np.arange(nRepetitions))
axs[2,0].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[2,1].set_xticklabels(np.arange(nRepetitions).astype(int)+1)
axs[2,2].set_xticklabels(np.arange(nRepetitions).astype(int)+1)

for i in range(3):
    for j in range(3):
        axs[i,j].set_yticks([33.,50., 66., 83., 100.])
        axs[i,j].set_ylim(30,105)
        if j>0:
            axs[i,j].set_yticklabels(("","","","",""))
        else:
            axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
            axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

axs[0,1].spines['left'].set_visible(False)
axs[0,1].set_xticks([])
axs[0,1].set_yticks([])
axs[1,1].spines['left'].set_visible(False)
axs[0,1].spines['bottom'].set_visible(False)
axs[1,1].spines['bottom'].set_visible(False)
axs[1,1].set_xticks([])
axs[1,1].set_yticks([])

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc=(.425,.5), title = "Modulation")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.33, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.605, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.33, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.33, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,13/2.54)
plt.savefig("Accuracy_training_repetition.tiff", dpi = 300)
plt.show()

#Loading in RDM data
Stroop_dir = np.load(Stroop_folder + "RDM_gen_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "RDM_gen_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "RDM_gen_MNIST.npy", allow_pickle = True)

# Figure 4: RDM correlation per learning rate in test phase
fig, axs = plt.subplots(3, 3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, -Stroop_dir[()]['12_Hidden_mean'][m,:],  Stroop_dir[()]['12_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,2].errorbar(learning_rates_1+m*0.01, -Stroop_dir[()]['24_Hidden_mean'][m,:],  Stroop_dir[()]['24_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, -Trees_dir[()]['12_Hidden_mean'][m,:],  Trees_dir[()]['12_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,2].errorbar(learning_rates_1+m*0.01, -Trees_dir[()]['24_Hidden_mean'][m,:],  Trees_dir[()]['24_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,0].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['1_Hidden_mean'][m,:],  MNIST_dir[()]['1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,1].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['2_Hidden_mean'][m,:],  MNIST_dir[()]['2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,2].errorbar(learning_rates_2+m*0.001, -MNIST_dir[()]['3_Hidden_mean'][m,:],  MNIST_dir[()]['3_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])

for j in range(3):
    for i in range(3):
        axs[i,j].set_yticks([.33,.50, .66, .83])
        axs[i,j].set_ylim(.3,.95)
        if j>0:
            axs[i,j].set_yticklabels(("","","",""))
        else:
            axs[i,j].set_ylabel("Dissimilarity correlation", fontsize = 8)
            axs[i,j].set_yticklabels((".33",".50",".66", ".83"))

        axs[j,i].spines['top'].set_visible(False)
        axs[j,i].spines['right'].set_visible(False)

axs[0,1].spines['left'].set_visible(False)
axs[0,1].set_xticks([])
axs[0,1].set_yticks([])
axs[1,1].spines['left'].set_visible(False)
axs[0,1].spines['bottom'].set_visible(False)
axs[1,1].spines['bottom'].set_visible(False)
axs[1,1].set_xticks([])
axs[1,1].set_yticks([])

axs[0,0].set_title("12 hidden neurons", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("24 hidden neurons", fontsize = 10, fontweight = "bold")
axs[2,0].set_title("1 hidden layer", fontsize = 10, fontweight = "bold")
axs[2,1].set_title("2 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,2].set_title("3 hidden layers", fontsize = 10, fontweight = "bold")
axs[2,0].set_xlabel("\u03B1", fontsize = 10)
axs[2,1].set_xlabel("\u03B1", fontsize = 10)
axs[2,2].set_xlabel("\u03B1", fontsize = 10)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc=(.425,.5), title = "Modulation")
fig.text(0.01, 0.775, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.5, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.2, 'MNIST dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.33, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.605, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.33, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.33, 'f', va='center', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85, hspace = .4, wspace=.4)
fig.set_size_inches(15/2.54,13/2.54)

plt.savefig("RDM_generalization_lr.tiff", dpi = 300)
plt.show()

#Loading in PCA data
Stroop_dir = np.load(Stroop_folder + "PCA_gen_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "PCA_gen_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "PCA_gen_MNIST.npy", allow_pickle = True)

rate = 3
Rep = 25
repid = 12#np.random.randint(0,Rep)
print(repid)

# Figure 7: PCA results
fig, axs = plt.subplots(4,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    for i in range(len(contexts_Stroop)):
        axs[m,0].plot(Stroop_dir[()]['12_Hidden'][m,rate,repid,0,i,:], Stroop_dir[()]['12_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Stroop[i], markersize = 2)
    for i in range(len(contexts_Trees)):
        axs[m,1].plot(Trees_dir[()]['12_Hidden'][m,rate,repid,0,i,:], Trees_dir[()]['12_Hidden'][m,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts_Trees[i], markersize = 2)
    for i in range(len(contexts_MNIST)):
        axs[m,2].plot(MNIST_dir[()]['1_Hidden'][m,rate,6,0,i,:], MNIST_dir[()]['1_Hidden'][m,rate,6,1,i,:], 'o', color = color_values[i], label=contexts_MNIST[i], markersize = 2)

    axs[m,0].set_ylabel("Dimension 2", fontsize = 10)

axs[3,0].set_xlabel("Dimension 1", fontsize = 10)
axs[3,1].set_xlabel("Dimension 1", fontsize = 10)
axs[3,2].set_xlabel("Dimension 1", fontsize = 10)

axs[0,0].set_title("Stroop dataset", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Trees dataset", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("MNIST dataset", fontsize = 10, fontweight = "bold")

axs[0,0].legend(fontsize = 10, loc=(-.25,1.15), ncol = len(contexts_Stroop), columnspacing = .1, handletextpad =.01, frameon = False) #bbox_to_anchor=(1.775, -1)
axs[0,1].legend(fontsize = 10, loc=(-.5,1.35), ncol = len(contexts_Trees), title="Task", columnspacing = .1, handletextpad =.01, frameon = False) #bbox_to_anchor=(1.925, -1)
axs[0,2].legend(fontsize = 10, loc=(-.8, 1.15), ncol = len(contexts_MNIST), columnspacing = .1, handletextpad =.01, frameon = False)#bbox_to_anchor=(1.8, -1),

fig.subplots_adjust(left = .125, right=.85, hspace =.25, wspace=.4)
fig.set_size_inches(17.5/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 10, fontweight="bold")
fig.text(0.01, 0.6, 'Nx', va='center', rotation='vertical', fontsize = 10, fontweight="bold")
fig.text(0.01, 0.4, 'A+', va='center', rotation='vertical', fontsize = 10, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 10, fontweight="bold")

fig.text(0.1, 0.885, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.685, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.485, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.285, 'j', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.885, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.685, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.485, 'h', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.285, 'k', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.885, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.685, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.485, 'i', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.285, 'l', va='center', fontsize = 9, fontweight = "bold")

plt.savefig("PCA_generalization.tiff", dpi=300)
plt.show()

#Loading in Activation data
Stroop_dir = np.load(Stroop_folder + "Activation_Stroop.npy", allow_pickle = True)
Trees_dir = np.load(Trees_folder + "Activation_Trees.npy", allow_pickle = True)
MNIST_dir = np.load(MNIST_folder + "Activation_MNIST.npy", allow_pickle = True)

from scipy import stats
x = np.linspace(-.5,1.5,500)

act_12_stroop = Stroop_dir[()]['12_Hidden']
density_12_stroop_1 = stats.gaussian_kde(act_12_stroop[0,1::,:,:,:,:].reshape(-1))
density_12_stroop_2 = stats.gaussian_kde(act_12_stroop[1,1::,:,:,:,:].reshape(-1))
density_12_stroop_3 = stats.gaussian_kde(act_12_stroop[2,1::,:,:,:,:].reshape(-1))
density_12_stroop_4 = stats.gaussian_kde(act_12_stroop[3,1::,:,:,:,:].reshape(-1))

act_12_trees = Trees_dir[()]['12_Hidden']
density_12_trees_1 = stats.gaussian_kde(act_12_trees[0,1::,:,:,:,:].reshape(-1))
density_12_trees_2 = stats.gaussian_kde(act_12_trees[1,1::,:,:,:,:].reshape(-1))
density_12_trees_3 = stats.gaussian_kde(act_12_trees[2,1::,:,:,:,:].reshape(-1))
density_12_trees_4 = stats.gaussian_kde(act_12_trees[3,1::,:,:,:,:].reshape(-1))

act_1_mnist = MNIST_dir[()]['1_Hidden']
density_1_mnist_1 = stats.gaussian_kde(act_1_mnist[0,1::,:,:,:,:].reshape(-1))
density_1_mnist_2 = stats.gaussian_kde(act_1_mnist[1,1::,:,:,:,:].reshape(-1))
density_1_mnist_3 = stats.gaussian_kde(act_1_mnist[2,1::,:,:,:,:].reshape(-1))
density_1_mnist_4 = stats.gaussian_kde(act_1_mnist[3,1::,:,:,:,:].reshape(-1))

y_12_stroop=[density_12_stroop_1(x), density_12_stroop_2(x), density_12_stroop_3(x), density_12_stroop_4(x)]

y_12_trees=[density_12_trees_1(x), density_12_trees_2(x), density_12_trees_3(x), density_12_trees_4(x)]

y_1_mnist=[density_1_mnist_1(x), density_1_mnist_2(x), density_1_mnist_3(x), density_1_mnist_4(x)]

fig, axs = plt.subplots(1,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0].plot(x,y_12_stroop[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[0].fill_between(x,y_12_stroop[m],0,color=color_values[m], alpha=.1)

    axs[1].plot(x,y_12_trees[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[1].fill_between(x,y_12_trees[m],0,color=color_values[m], alpha=.1)

    axs[2].plot(x,y_1_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[2].fill_between(x,y_1_mnist[m],0,color=color_values[m], alpha=.1)

axs[0].set_title("Stroop dataset", fontsize = 10, fontweight = "bold")
axs[1].set_title("Trees dataset", fontsize = 10, fontweight = "bold")
axs[2].set_title("MNIST dataset", fontsize = 10, fontweight = "bold")
axs[0].set_ylabel("Density Hidden layer", fontsize = 8)

for j in range(3):
    axs[j].spines['top'].set_visible(False)
    axs[j].spines['right'].set_visible(False)
    axs[j].set_xlabel("Activity")

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.9, 'c', va='center', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85, bottom = .25, hspace = .4, wspace=.4)
fig.set_size_inches(15/2.54,6/2.54)

plt.savefig("Activation_density.tiff", dpi = 300)
plt.show()

act_2_mnist = MNIST_dir[()]['2_Hidden']

density_2_1_mnist_1 = stats.gaussian_kde(act_2_mnist[0,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_2 = stats.gaussian_kde(act_2_mnist[1,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_3 = stats.gaussian_kde(act_2_mnist[2,1::,:,::301,:,:].reshape(-1))
density_2_1_mnist_4 = stats.gaussian_kde(act_2_mnist[3,1::,:,::301,:,:].reshape(-1))

density_2_2_mnist_1 = stats.gaussian_kde(act_2_mnist[0,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_2 = stats.gaussian_kde(act_2_mnist[1,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_3 = stats.gaussian_kde(act_2_mnist[2,1::,:,301::,:,:].reshape(-1))
density_2_2_mnist_4 = stats.gaussian_kde(act_2_mnist[3,1::,:,301::,:,:].reshape(-1))

y_2_1_mnist=[density_2_1_mnist_1(x), density_2_1_mnist_2(x), density_2_1_mnist_3(x), density_2_1_mnist_4(x)]
y_2_2_mnist=[density_2_2_mnist_1(x), density_2_2_mnist_2(x), density_2_2_mnist_3(x), density_2_2_mnist_4(x)]

act_3_mnist = MNIST_dir[()]['3_Hidden']

density_3_1_mnist_1 = stats.gaussian_kde(act_3_mnist[0,1::,:,::201,:,:].reshape(-1))
density_3_1_mnist_2 = stats.gaussian_kde(act_3_mnist[1,1::,:,::201,:,:].reshape(-1))
density_3_1_mnist_3 = stats.gaussian_kde(act_3_mnist[2,1::,:,::201,:,:].reshape(-1))
density_3_1_mnist_4 = stats.gaussian_kde(act_3_mnist[3,1::,:,::201,:,:].reshape(-1))

density_3_2_mnist_1 = stats.gaussian_kde(act_3_mnist[0,1::,:,201:302,:,:].reshape(-1))
density_3_2_mnist_2 = stats.gaussian_kde(act_3_mnist[1,1::,:,201:302,:,:].reshape(-1))
density_3_2_mnist_3 = stats.gaussian_kde(act_3_mnist[2,1::,:,201:302,:,:].reshape(-1))
density_3_2_mnist_4 = stats.gaussian_kde(act_3_mnist[3,1::,:,201:302,:,:].reshape(-1))

density_3_3_mnist_1 = stats.gaussian_kde(act_3_mnist[0,1::,:,302::,:,:].reshape(-1))
density_3_3_mnist_2 = stats.gaussian_kde(act_3_mnist[1,1::,:,302::,:,:].reshape(-1))
density_3_3_mnist_3 = stats.gaussian_kde(act_3_mnist[2,1::,:,302::,:,:].reshape(-1))
density_3_3_mnist_4 = stats.gaussian_kde(act_3_mnist[3,1::,:,302::,:,:].reshape(-1))

y_3_1_mnist=[density_3_1_mnist_1(x), density_3_1_mnist_2(x), density_3_1_mnist_3(x), density_3_1_mnist_4(x)]
y_3_2_mnist=[density_3_2_mnist_1(x), density_3_2_mnist_2(x), density_3_2_mnist_3(x), density_3_2_mnist_4(x)]
y_3_3_mnist=[density_3_3_mnist_1(x), density_3_3_mnist_2(x), density_3_3_mnist_3(x), density_3_3_mnist_4(x)]

RDM_dir = np.load(MNIST_folder + "RDM_gen_MNIST.npy", allow_pickle = True)

fig, axs = plt.subplots(4,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_2+m*0.001, -RDM_dir[()]['2_1_Hidden_mean'][m,:],  RDM_dir[()]['2_1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates_2+m*0.001, -RDM_dir[()]['2_2_Hidden_mean'][m,:],  RDM_dir[()]['2_2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(learning_rates_2+m*0.001, -RDM_dir[()]['3_1_Hidden_mean'][m,:],  RDM_dir[()]['3_1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(learning_rates_2+m*0.001, -RDM_dir[()]['3_2_Hidden_mean'][m,:],  RDM_dir[()]['3_2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,2].errorbar(learning_rates_2+m*0.001, -RDM_dir[()]['3_3_Hidden_mean'][m,:],  RDM_dir[()]['3_3_Hidden_ci'][m,:], lw = 2, color=color_values[m], label=model_labels[m])

    axs[2,0].plot(x,y_2_1_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[2,0].fill_between(x,y_2_1_mnist[m],0,color=color_values[m], alpha=.1)
    axs[2,1].plot(x,y_2_2_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[2,1].fill_between(x,y_2_2_mnist[m],0,color=color_values[m], alpha=.1)

    axs[3,0].plot(x,y_3_1_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[3,0].fill_between(x,y_3_1_mnist[m],0,color=color_values[m], alpha=.1)
    axs[3,1].plot(x,y_3_2_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[3,1].fill_between(x,y_3_2_mnist[m],0,color=color_values[m], alpha=.1)
    axs[3,2].plot(x,y_3_3_mnist[m], lw = 1, color=color_values[m], label=model_labels[m])
    axs[3,2].fill_between(x,y_3_3_mnist[m],0,color=color_values[m], alpha=.1)

for i in range(4):
    for j in range(3):
        axs[i,j].spines['top'].set_visible(False)
        axs[i,j].spines['right'].set_visible(False)

axs[0,0].set_ylim(.3,.85)
axs[0,0].set_yticks([.33, .5,.66,.83])
axs[0,0].set_yticklabels([".33", ".50",".66",".83"])
axs[0,1].set_ylim(.3,.85)
axs[0,1].set_yticks([.33, .5,.66,.83])
axs[0,2].spines['left'].set_visible(False)
axs[0,2].spines['bottom'].set_visible(False)
axs[0,2].set_xticks([])
axs[0,2].set_yticks([])
axs[2,2].spines['left'].set_visible(False)
axs[2,2].spines['bottom'].set_visible(False)
axs[2,2].set_xticks([])
axs[2,2].set_yticks([])
axs[1,0].set_ylim(.3,.85)
axs[1,0].set_yticks([.33, .5,.66,.83])
axs[1,0].set_yticklabels([".33", ".50",".66",".83"])
axs[1,1].set_ylim(.3,.85)
axs[1,1].set_yticks([.33, .5,.66,.83])
axs[1,2].set_ylim(.3,.85)
axs[1,2].set_yticks([.33, .5,.66,.83])

axs[0,0].set_title("Layer 1 of 2", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Layer 2 of 2", fontsize = 10, fontweight = "bold")
axs[2,0].set_title("Layer 1 of 2", fontsize = 10, fontweight = "bold")
axs[2,1].set_title("Layer 2 of 2", fontsize = 10, fontweight = "bold")

axs[1,0].set_title("Layer 1 of 3", fontsize = 10, fontweight = "bold")
axs[1,1].set_title("Layer 2 of 3", fontsize = 10, fontweight = "bold")
axs[1,2].set_title("Layer 3 of 3", fontsize = 10, fontweight = "bold")
axs[3,0].set_title("Layer 1 of 2", fontsize = 10, fontweight = "bold")
axs[3,1].set_title("Layer 2 of 3", fontsize = 10, fontweight = "bold")
axs[3,2].set_title("Layer 3 of 3", fontsize = 10, fontweight = "bold")

axs[0,0].set_ylabel("Dissimilarity correlation", fontsize = 8)
axs[0,0].set_xlabel("\u03B1", fontsize = 10)
axs[0,1].set_xlabel("\u03B1", fontsize = 10)
axs[1,0].set_ylabel("Dissimilarity correlation", fontsize = 8)
axs[1,0].set_xlabel("\u03B1", fontsize = 10)
axs[1,1].set_xlabel("\u03B1", fontsize = 10)
axs[1,2].set_xlabel("\u03B1", fontsize = 10)
axs[0,1].set_xlabel("\u03B1", fontsize = 10)
axs[2,0].set_ylabel("Density Hidden layer", fontsize = 8)
axs[2,0].set_xlabel("Activation", fontsize = 10)
axs[2,1].set_xlabel("Activation", fontsize = 10)
axs[3,0].set_ylabel("Density Hidden layer", fontsize = 8)
axs[3,0].set_xlabel("Activation", fontsize = 10)
axs[3,1].set_xlabel("Activation", fontsize = 10)
axs[3,2].set_xlabel("Activation", fontsize = 10)

fig.text(0.125, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.685, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.45, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.225, 'h', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.685, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.45, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.225, 'i', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.685, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.625, 0.225, 'j', va='center', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85, hspace = 1, wspace = .4)
handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.set_size_inches(15/2.54,17/2.54)

plt.savefig("Rep_hidden_layers.tiff", dpi = 300)
plt.show()

gatelayer_dir = np.load(Gatelayer_folder + "Accuracy_gen_MNIST.npy", allow_pickle = True)

#Accuracy by Modulation at different layers (1,4)
fig, axs = plt.subplots(2,2)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_2+m*0.001, np.mean(gatelayer_dir[()]['0_Hidden_mean'][m,:,:],1),np.mean(gatelayer_dir[()]['0_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_2+m*0.001, np.mean(gatelayer_dir[()]['1_Hidden_mean'][m,:,:],1),np.mean(gatelayer_dir[()]['1_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_2+m*0.001, np.mean(gatelayer_dir[()]['2_Hidden_mean'][m,:,:],1),np.mean(gatelayer_dir[()]['2_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_2+m*0.001, np.mean(gatelayer_dir[()]['3_Hidden_mean'][m,:,:],1),np.mean(gatelayer_dir[()]['3_Hidden_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("No modulation", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Modulating layer 1", fontsize = 10, fontweight = "bold")
axs[1,0].set_title("Modulating layer 2", fontsize = 10, fontweight = "bold")
axs[1,1].set_title("Modulating both layers", fontsize = 10, fontweight = "bold")
axs[1,0].set_xlabel("\u03B1", fontsize = 10)
axs[1,1].set_xlabel("\u03B1", fontsize = 10)

for i in range(2):
    for j in range(2):
        axs[i,j].set_yticks([33.,50., 66., 83., 100.])
        axs[i,j].set_ylim(25,105)
        if j>0:
            axs[i,j].set_yticklabels(("","","","",""))
        else:
            axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
            axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.45, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.45, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.set_size_inches(15/2.54,12/2.54)
plt.savefig("Accuracy_gatelayer_lr.tiff", dpi = 300)
plt.show()

#RDM by Modulation at different layers (3,3)
gatelayer_dir = np.load(Gatelayer_folder + "RDM_gen_MNIST.npy", allow_pickle = True)

fig, axs = plt.subplots(3,3)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['1_Hidden_mean'][m,:],gatelayer_dir[()]['1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['1_1_Hidden_mean'][m,:],gatelayer_dir[()]['1_1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['1_2_Hidden_mean'][m,:],gatelayer_dir[()]['1_2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['2_Hidden_mean'][m,:],gatelayer_dir[()]['2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['2_1_Hidden_mean'][m,:],gatelayer_dir[()]['2_1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['2_2_Hidden_mean'][m,:],gatelayer_dir[()]['2_2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['3_Hidden_mean'][m,:],gatelayer_dir[()]['3_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['3_1_Hidden_mean'][m,:],gatelayer_dir[()]['3_1_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,2].errorbar(learning_rates_2+m*0.001, -gatelayer_dir[()]['3_2_Hidden_mean'][m,:],gatelayer_dir[()]['3_2_Hidden_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("Both layers", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Layer 1 of 2", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("Layer 2 of 2", fontsize = 10, fontweight = "bold")

axs[2,0].set_xlabel("\u03B1", fontsize = 10)
axs[2,1].set_xlabel("\u03B1", fontsize = 10)
axs[2,2].set_xlabel("\u03B1", fontsize = 10)

for i in range(3):
    for j in range(3):
        axs[i,j].set_yticks([.33,.50, .66, .83])
        axs[i,j].set_ylim(.30,.95)
        if j>0:
            axs[i,j].set_yticklabels(("","","",""))
        else:
            axs[i,j].set_ylabel("Dissimilarity correlation", fontsize = 8)
            axs[i,j].set_yticklabels((".33",".50",".66", ".83"))
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

fig.text(0.01, 0.775, 'Modulating layer 1', va='center', rotation='vertical', fontsize = 8, fontweight = "bold")
fig.text(0.01, 0.5, 'Modulating layer 2', va='center', rotation='vertical', fontsize = 8, fontweight = "bold")
fig.text(0.01, 0.2, 'Modulating both layers', va='center', rotation='vertical', fontsize = 8, fontweight = "bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.6125, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.33, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.6125, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.375, 0.33, 'h', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.9, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.6125, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.6125, 0.33, 'i', va='center', fontsize = 9, fontweight = "bold")
fig.set_size_inches(15/2.54,12/2.54)
plt.savefig("RDM_gatelayer_lr.tiff", dpi = 300)
plt.show()
