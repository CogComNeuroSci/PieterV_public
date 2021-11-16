import numpy as np
from matplotlib import pyplot as plt
import os

Init_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/initialize/"
Conc_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/Conc/"
Comb_folder = "/Volumes/backupdisc/Modular_learning/Data_Revision/Comb/"
Plots_folder = "/Volumes/backupdisc/Modular_learning/Plots_general/Revision/"

# Loading Accuracy data
Stroop_acc_dir = np.load(Init_folder + "Accuracy_gen_Stroop.npy", allow_pickle = True)
Trees_acc_dir = np.load(Init_folder + "Accuracy_gen_Trees.npy", allow_pickle = True)

Stroop_rdm_dir = np.load(Init_folder + "RDM_gen_Stroop.npy", allow_pickle = True)
Trees_rdm_dir = np.load(Init_folder + "RDM_gen_Trees.npy", allow_pickle = True)

model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k", "c", "m"]
contexts_Stroop = ["A", "B", "C", "D", "E"]
contexts_Trees = ["Leaf", "Branch", "AND", "XOR"]
contexts_MNIST = ["Odd", "Even", ">5", "<5",">3","<7"]

learning_rates_1= np.arange(0,1.1,0.2)
learning_rates_2= np.arange(0,0.11,0.02)

# Figure 5: Accuracy per learning rate in test phase
os.chdir(Plots_folder)

fig, axs = plt.subplots(4,2)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['normal_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['normal_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['uniform_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['uniform_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['normal_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['normal_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['uniform_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['uniform_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['normal_mean'][m,:],Stroop_rdm_dir[()]['normal_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['uniform_mean'][m,:],Stroop_rdm_dir[()]['uniform_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,0].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['normal_mean'][m,:],Trees_rdm_dir[()]['normal_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,1].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['uniform_mean'][m,:],Trees_rdm_dir[()]['uniform_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("Normal initialization", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Uniform initialization", fontsize = 10, fontweight = "bold")
axs[3,0].set_xlabel("\u03B1", fontsize = 10)
axs[3,1].set_xlabel("\u03B1", fontsize = 10)

for i in range(4):
    for j in range(2):
        if i ==0 or i == 2:
            axs[i,j].set_yticks([33.,50., 66., 83., 100.])
            axs[i,j].set_ylim(25,105)
            if j>0:
                axs[i,j].set_yticklabels(("","","","",""))
            else:
                axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
                axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        else:
            axs[i,j].set_yticks([.33,.50, .66, .83])
            axs[i,j].set_ylim(.30,.95)
            if j>0:
                axs[i,j].set_yticklabels(("","","",""))
            else:
                axs[i,j].set_ylabel("Dissimilarity correlation", fontsize = 8)
                axs[i,j].set_yticklabels((".33",".50",".66", ".83"))

        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .8)
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.01, 0.7, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.3, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.675, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.4625, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.25, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.675, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.4625, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.25, 'h', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,17/2.54)
plt.savefig("Initialization_lr.tiff", dpi = 300)
plt.show()

Stroop_acc_dir = np.load(Conc_folder + "Accuracy_gen_Stroop.npy", allow_pickle = True)
Trees_acc_dir = np.load(Conc_folder + "Accuracy_gen_Trees.npy", allow_pickle = True)

Stroop_rdm_dir = np.load(Conc_folder + "RDM_gen_Stroop.npy", allow_pickle = True)
Trees_rdm_dir = np.load(Conc_folder + "RDM_gen_Trees.npy", allow_pickle = True)

fig, axs = plt.subplots(4,2)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['conc_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['conc_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['sep_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['sep_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['conc_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['conc_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['sep_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['sep_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['conc_mean'][m,:],Stroop_rdm_dir[()]['conc_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['sep_mean'][m,:],Stroop_rdm_dir[()]['sep_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,0].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['conc_mean'][m,:],Trees_rdm_dir[()]['conc_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,1].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['sep_mean'][m,:],Trees_rdm_dir[()]['sep_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("Concatenated", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Separated", fontsize = 10, fontweight = "bold")
axs[3,0].set_xlabel("\u03B1", fontsize = 10)
axs[3,1].set_xlabel("\u03B1", fontsize = 10)

for i in range(4):
    for j in range(2):
        if i ==0 or i == 2:
            axs[i,j].set_yticks([33.,50., 66., 83., 100.])
            axs[i,j].set_ylim(25,105)
            if j>0:
                axs[i,j].set_yticklabels(("","","","",""))
            else:
                axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
                axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        else:
            axs[i,j].set_yticks([.33,.50, .66, .83])
            axs[i,j].set_ylim(.30,.95)
            if j>0:
                axs[i,j].set_yticklabels(("","","",""))
            else:
                axs[i,j].set_ylabel("Dissimilarity correlation", fontsize = 8)
                axs[i,j].set_yticklabels((".33",".50",".66", ".83"))

        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .8)
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.01, 0.7, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.3, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.1, 0.9, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.675, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.4625, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.25, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.9, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.675, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.4625, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.25, 'h', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(15/2.54,17/2.54)
plt.savefig("Consep_lr.tiff", dpi = 300)
plt.show()

Stroop_acc_dir = np.load(Comb_folder + "Accuracy_gen_Stroop.npy", allow_pickle = True)
Trees_acc_dir = np.load(Comb_folder + "Accuracy_gen_Trees.npy", allow_pickle = True)

Stroop_rdm_dir = np.load(Comb_folder + "RDM_gen_Stroop.npy", allow_pickle = True)
Trees_rdm_dir = np.load(Comb_folder + "RDM_gen_Trees.npy", allow_pickle = True)

fig, axs = plt.subplots(4,4)
plt.rcParams["font.size"]=10
plt.rcParams["xtick.labelsize"]=10
plt.rcParams["ytick.labelsize"]=10

for m in range(len(model_labels)):
    axs[0,0].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['sigsig_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['sigsig_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['sigrelu_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['sigrelu_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['relusig_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['relusig_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,3].errorbar(learning_rates_1+m*0.01, np.mean(Stroop_acc_dir[()]['relurelu_mean'][m,:,:],1),np.mean(Stroop_acc_dir[()]['relurelu_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,0].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['sigsig_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['sigsig_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,1].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['sigrelu_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['sigrelu_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,2].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['relusig_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['relusig_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2,3].errorbar(learning_rates_1+m*0.01, np.mean(Trees_acc_dir[()]['relurelu_mean'][m,:,:],1),np.mean(Trees_acc_dir[()]['relurelu_ci'][m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])

    axs[1,0].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['sigsig_mean'][m,:],Stroop_rdm_dir[()]['sigsig_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['sigrelu_mean'][m,:],Stroop_rdm_dir[()]['sigrelu_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['relusig_mean'][m,:],Stroop_rdm_dir[()]['relusig_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,3].errorbar(learning_rates_1+m*0.01, -Stroop_rdm_dir[()]['relurelu_mean'][m,:],Stroop_rdm_dir[()]['relurelu_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,0].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['sigsig_mean'][m,:],Trees_rdm_dir[()]['sigsig_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,1].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['sigrelu_mean'][m,:],Trees_rdm_dir[()]['sigrelu_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,2].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['relusig_mean'][m,:],Trees_rdm_dir[()]['relusig_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3,3].errorbar(learning_rates_1+m*0.01, -Trees_rdm_dir[()]['relurelu_mean'][m,:],Trees_rdm_dir[()]['relurelu_ci'][m,:], lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("Sig (x Sig) ", fontsize = 10, fontweight = "bold")
axs[0,1].set_title("Sig (x RELU) ", fontsize = 10, fontweight = "bold")
axs[0,2].set_title("RELU (x Sig) ", fontsize = 10, fontweight = "bold")
axs[0,3].set_title("RELU (x RELU) ", fontsize = 10, fontweight = "bold")
axs[3,0].set_xlabel("\u03B1", fontsize = 10)
axs[3,1].set_xlabel("\u03B1", fontsize = 10)
axs[3,2].set_xlabel("\u03B1", fontsize = 10)
axs[3,3].set_xlabel("\u03B1", fontsize = 10)

for i in range(4):
    for j in range(4):
        if i ==0 or i == 2:
            axs[i,j].set_yticks([33.,50., 66., 83., 100.])
            axs[i,j].set_ylim(25,105)
            if j>0:
                axs[i,j].set_yticklabels(("","","","",""))
            else:
                axs[i,j].set_ylabel("Accuracy%", fontsize = 10)
                axs[i,j].set_yticklabels(("33","50","66", "83","100"))
        else:
            axs[i,j].set_yticks([.33,.50, .66, .83])
            axs[i,j].set_ylim(.30,.95)
            if j>0:
                axs[i,j].set_yticklabels(("","","",""))
            else:
                axs[i,j].set_ylabel("Dissimilarity correlation", fontsize = 8)
                axs[i,j].set_yticklabels((".33",".50",".66", ".83"))

        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85, hspace = .4)
fig.legend(handles, labels, loc="center right", title = "Modulation")
fig.text(0.01, 0.7, 'Stroop dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")
fig.text(0.01, 0.3, 'Trees dataset', va='center', rotation='vertical', fontsize = 10, fontweight = "bold")

fig.text(0.125, 0.885, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.685, 'e', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.475, 'i', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.125, 0.275, 'm', va='center', fontsize = 9, fontweight = "bold")

fig.text(0.3, 0.885, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.3, 0.685, 'f', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.3, 0.475, 'j', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.3, 0.275, 'n', va='center', fontsize = 9, fontweight = "bold")

fig.text(0.5, 0.885, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.685, 'g', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.475, 'k', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.275, 'o', va='center', fontsize = 9, fontweight = "bold")

fig.text(0.675, 0.885, 'd', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.675, 0.685, 'h', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.675, 0.475, 'l', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.675, 0.275, 'p', va='center', fontsize = 9, fontweight = "bold")

fig.set_size_inches(17/2.54,17/2.54)
plt.savefig("Comb_lr.tiff", dpi = 300)
plt.show()
