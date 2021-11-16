import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

#Define data and simulation parameters
Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/comb/"
learning_rates= np.arange(0,1.1,0.2)
Rep= 25
resources = 12
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 5
nRepeats= 3
nPatterns = 18

#If you run script for the first time, set this on False
loaded = False

#Function to load data
def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/comb/", learning_rates= np.arange(0,1.1,0.2), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 12, nContexts= 5, nRepeats= 3, nPatterns = 18, act = ["sig", "relu"]):

    #Extract mean accuracy and activation for each stimulus, also extract contextorder and objective overlap
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nRepeats, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))
    Criterion = np.ones((len(Models), len(learning_rates), Rep, nRepeats, nContexts))

    i = -1
    for m in Models:
        i+=1
        i2 =-1
        for lr in learning_rates:
            i2+=1
            for r in range(Rep):
                if "add" in m:
                    data = np.load(Directory + "Stroop/"+ m +"/" + act[0] +"_lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)
                else:
                    data = np.load(Directory + "Stroop/"+ m +"/" + act[0] + "_" + act[1] + "_lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)
                print([i, i2, r])
                Contextorder[i,i2,r,:] = data[()]["Contextorder"]
                Overlap[i,i2,r,:,:] = data[()]["Overlap"]
                Criterion[i,i2,r,:,:]=data[()]["Criterion"]

                for n in range(nPatterns):
                    id1 = data[()]["Presented"][0,0:450]==n
                    for c in range(nContexts):
                        id2 = data[()]["Contextorder"]==c
                        Accuracy_labeled[i,i2,r,:,c,n]= np.mean(data[()]["Accuracy"][:,id2,id1])
                        Activation_labeled[i,i2,r,:,:,c,n]=np.mean(data[()]["Activation"][:,:,id2,id1],2)

    return Contextorder, Overlap, Accuracy_labeled, Activation_labeled, Criterion

#If data was not loaded before, do it now and save
if not loaded:
    for i in ["sig", "relu"]:
        for j in ["sig", "relu"]:
            order, target_overlap, accuracy, activation, criterion = load_data(act = [i,j])
            new_dict = {
                "order": order,
                "target_overlap": target_overlap,
                "accuracy": accuracy,
                "activation": activation,
                "criterion": criterion
                }
            np.save(Directory+"all_data_Stroop_"+i+j+".npy", new_dict)

#Now extract the loaded data
data_dict = {}
for i in ["sig", "relu"]:
    for j in ["sig", "relu"]:
        data_dict[i+j] = np.load(Directory+"all_data_Stroop_"+i+j+".npy", allow_pickle = True)

order_sigsig= data_dict["sigsig"][()]["order"]
order_relurelu = data_dict["relurelu"][()]["order"]
order_sigrelu = data_dict["sigrelu"][()]["order"]
order_relusig = data_dict["relusig"][()]["order"]

target_overlap_sigsig = data_dict["sigsig"][()]["target_overlap"]
target_overlap_relurelu = data_dict["relurelu"][()]["target_overlap"]
target_overlap_sigrelu = data_dict["sigrelu"][()]["target_overlap"]
target_overlap_relusig = data_dict["relusig"][()]["target_overlap"]

accuracy_sigsig = data_dict["sigsig"][()]["accuracy"]
accuracy_relurelu = data_dict["relurelu"][()]["accuracy"]
accuracy_sigrelu = data_dict["sigrelu"][()]["accuracy"]
accuracy_relusig = data_dict["relusig"][()]["accuracy"]

activation_sigsig = data_dict["sigsig"][()]["activation"]
activation_relurelu = data_dict["relurelu"][()]["activation"]
activation_sigrelu = data_dict["sigrelu"][()]["activation"]
activation_relusig = data_dict["relusig"][()]["activation"]

criterion_sigsig = data_dict["sigsig"][()]["criterion"]
criterion_relurelu = data_dict["relurelu"][()]["criterion"]
criterion_sigrelu = data_dict["sigrelu"][()]["criterion"]
criterion_relusig = data_dict["relusig"][()]["criterion"]

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Stroop/Revision/comb/"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

#Accuracy analyses
mean_accuracy_sigsig = np.mean(np.mean(accuracy_sigsig,5),2)*100
std_accuracy_sigsig = np.std(np.mean(accuracy_sigsig,5), axis = 2)*100
ci_accuracy_sigsig = 1.96*std_accuracy_sigsig/np.sqrt(Rep)

mean_accuracy_sigrelu = np.mean(np.mean(accuracy_sigrelu,5),2)*100
std_accuracy_sigrelu = np.std(np.mean(accuracy_sigrelu,5), axis = 2)*100
ci_accuracy_sigrelu = 1.96*std_accuracy_sigrelu/np.sqrt(Rep)

mean_accuracy_relurelu = np.mean(np.mean(accuracy_relurelu,5),2)*100
std_accuracy_relurelu = np.std(np.mean(accuracy_relurelu,5), axis = 2)*100
ci_accuracy_relurelu = 1.96*std_accuracy_relurelu/np.sqrt(Rep)

mean_accuracy_relusig = np.mean(np.mean(accuracy_relusig,5),2)*100
std_accuracy_relusig = np.std(np.mean(accuracy_relusig,5), axis = 2)*100
ci_accuracy_relusig = 1.96*std_accuracy_relusig/np.sqrt(Rep)

reshaped_mean_acc_sigsig = np.reshape(mean_accuracy_sigsig,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_sigsig = np.reshape(ci_accuracy_sigsig,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_sigrelu = np.reshape(mean_accuracy_sigrelu,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_sigrelu = np.reshape(ci_accuracy_sigrelu,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_relurelu = np.reshape(mean_accuracy_relurelu,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_relurelu = np.reshape(ci_accuracy_relurelu,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_relusig = np.reshape(mean_accuracy_relusig,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_relusig = np.reshape(ci_accuracy_relusig,(len(Models), len(learning_rates), nRepeats * nContexts))

extra_averaged_accuracy_sigsig = np.mean(reshaped_mean_acc_sigsig,2)
extra_ci_accuracy_sigsig = np.mean(reshaped_ci_acc_sigsig,2)

extra_averaged_accuracy_sigrelu = np.mean(reshaped_mean_acc_sigrelu,2)
extra_ci_accuracy_sigrelu = np.mean(reshaped_ci_acc_sigrelu,2)

extra_averaged_accuracy_relurelu = np.mean(reshaped_mean_acc_relurelu,2)
extra_ci_accuracy_relurelu = np.mean(reshaped_ci_acc_relurelu,2)

extra_averaged_accuracy_relusig = np.mean(reshaped_mean_acc_relusig,2)
extra_ci_accuracy_relusig = np.mean(reshaped_ci_acc_relusig,2)

#save results of analyses
Stroop_accuracy_train_dir = {
    "sigsig_mean": np.mean(mean_accuracy_sigsig,3),
    "sigsig_ci": np.mean(ci_accuracy_sigsig,3),
    "sigrelu_mean": np.mean(mean_accuracy_sigrelu,3),
    "sigrelu_ci": np.mean(ci_accuracy_sigrelu,3),
    "relurelu_mean": np.mean(mean_accuracy_relurelu,3),
    "relurelu_ci": np.mean(ci_accuracy_relurelu,3),
    "relusig_mean": np.mean(mean_accuracy_relusig,3),
    "relusig_ci": np.mean(ci_accuracy_relusig,3)
}
np.save(Directory + "Accuracy_train_Stroop.npy", Stroop_accuracy_train_dir)

#Make figure
os.chdir(figdir)
fig, axs = plt.subplots(1,4, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, extra_averaged_accuracy_sigsig[m,:],extra_ci_accuracy_sigsig[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, extra_averaged_accuracy_sigrelu[m,:],extra_ci_accuracy_sigrelu[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[2].errorbar(learning_rates, extra_averaged_accuracy_relurelu[m,:],extra_ci_accuracy_relurelu[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[3].errorbar(learning_rates, extra_averaged_accuracy_relusig[m,:],extra_ci_accuracy_relusig[m,:], lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("sigsig combination", fontsize = 9, fontweight="bold")
axs[1].set_title("sigrelu combination", fontsize = 9, fontweight="bold")
axs[2].set_title("relurelu combination", fontsize = 9, fontweight="bold")
axs[3].set_title("relusig combination", fontsize = 9, fontweight="bold")

axs[0].set_xlabel("\u03B1", fontsize = 9)
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xlabel("\u03B1", fontsize = 9)
axs[1].set_xticks(np.arange(0,1.1,.2))
axs[2].set_xlabel("\u03B1", fontsize = 9)
axs[2].set_xticks(np.arange(0,1.1,.2))
axs[3].set_xlabel("\u03B1", fontsize = 9)
axs[3].set_xticks(np.arange(0,1.1,.2))

axs[0].set_ylabel("Accuracy %", fontsize = 9)

axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
axs[2].spines['right'].set_visible(False)
axs[2].spines['top'].set_visible(False)
axs[3].spines['right'].set_visible(False)
axs[3].spines['top'].set_visible(False)

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,8/2.54)
plt.savefig("Accuracy_averaged.png", dpi = 300)
plt.show()

fig, axs = plt.subplots(3,4, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(3):
    for m in range(len(Models)):
        axs[i,0].errorbar(np.arange(1,16), reshaped_mean_acc_sigsig[m,i+1,:], reshaped_ci_acc_sigsig[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,1].errorbar(np.arange(1,16), reshaped_mean_acc_sigrelu[m,i+1,:], reshaped_ci_acc_sigrelu[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,2].errorbar(np.arange(1,16), reshaped_mean_acc_relurelu[m,i+1,:], reshaped_ci_acc_relurelu[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,3].errorbar(np.arange(1,16), reshaped_mean_acc_relusig[m,i+1,:], reshaped_ci_acc_relusig[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
    for i2 in range(4):
        axs[i,i2].spines['top'].set_visible(False)
        axs[i,i2].spines['right'].set_visible(False)
        axs[2,i2].set_xticks(np.arange(1,16))
        axs[2,i2].set_xticklabels(np.tile(["A","B","C","D","E"],3), fontsize = 9)
        axs[2,i2].set_xlabel("Context", fontsize = 9)

    axs[i,0].set_ylabel("Accuracy %", fontsize = 9)

axs[0,0].set_title("sigsig combination", fontsize = 9, fontweight="bold")
axs[0,1].set_title("sigrelu combination", fontsize = 9, fontweight="bold")
axs[0,2].set_title("relurelu combination", fontsize = 9, fontweight="bold")
axs[0,3].set_title("relusig combination", fontsize = 9, fontweight="bold")

a = axs.flatten()
handles, labels = a[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.77, '\u03B1 = 0.3', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.5, '\u03B1 = 0.6', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.23, '\u03B1 = 0.9', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,18/2.54)
plt.savefig("Accuracy_contexts.png", dpi = 300)
plt.show()

mean_criterion_sigsig = np.mean(criterion_sigsig,2)
ci_criterion_sigsig = 1.96*np.std(criterion_sigsig, axis = 2)

mean_criterion_sigrelu = np.mean(criterion_sigrelu,2)
ci_criterion_sigrelu = 1.96*np.std(criterion_sigrelu, axis = 2)

mean_criterion_relurelu = np.mean(criterion_relurelu,2)
ci_criterion_relurelu = 1.96*np.std(criterion_relurelu, axis = 2)

mean_criterion_relusig = np.mean(criterion_relusig,2)
ci_criterion_relusig = 1.96*np.std(criterion_relusig, axis = 2)

#save results of analyses
Stroop_criterion_train_dir = {
    "sigsig_mean": mean_criterion_sigsig,
    "sigsig_ci": ci_criterion_sigsig,
    "sigrelu_mean": mean_criterion_sigrelu,
    "sigrelu_ci": ci_criterion_sigrelu,
    "relurelu_mean": mean_criterion_relurelu,
    "relurelu_ci": ci_criterion_relurelu,
    "relusig_mean": mean_criterion_relusig,
    "relusig_ci": ci_criterion_relusig
}
np.save(Directory + "Criterion_train_Stroop.npy", Stroop_criterion_train_dir)

print(np.shape(mean_criterion_sigsig))

fig, axs = plt.subplots(1,4, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, np.mean(mean_criterion_sigsig[m,:,0,:],1), np.mean(ci_criterion_sigsig[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, np.mean(mean_criterion_sigrelu[m,:,0,:],1), np.mean(ci_criterion_sigrelu[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[2].errorbar(learning_rates, np.mean(mean_criterion_relurelu[m,:,0,:],1), np.mean(ci_criterion_relurelu[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[3].errorbar(learning_rates, np.mean(mean_criterion_relusig[m,:,0,:],1), np.mean(ci_criterion_relusig[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("sigsig combination", fontsize = 9, fontweight="bold")
axs[1].set_title("sigrelu combination", fontsize = 9, fontweight="bold")
axs[2].set_title("relurelu combination", fontsize = 9, fontweight="bold")
axs[3].set_title("relusig combination", fontsize = 9, fontweight="bold")

axs[0].set_xlabel("\u03B1", fontsize = 9)
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xlabel("\u03B1", fontsize = 9)
axs[1].set_xticks(np.arange(0,1.1,.2))

axs[0].set_ylabel("Trials-to-criterion", fontsize = 9)

axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
axs[2].spines['right'].set_visible(False)
axs[2].spines['top'].set_visible(False)
axs[3].spines['right'].set_visible(False)
axs[3].spines['top'].set_visible(False)

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,6/2.54)
plt.savefig("Criterion_averaged.png", dpi = 300)
plt.show()

#Compute overlap in network activation
from scipy import stats
Overlap_sigsig = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))
Overlap_sigrelu = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))
Overlap_relurelu =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))
Overlap_relusig =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_sigsig[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sigsig[:,:,:,:,:,c1,:] - activation_sigsig[:,:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_sigrelu[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sigrelu[:,:,:,:,:,c1,:] - activation_sigrelu[:,:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_relusig[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_relusig[:,:,:,:,:,c1,:] - activation_relusig[:,:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_relurelu[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_relurelu[:,:,:,:,:,c1,:] - activation_relurelu[:,:,:,:,:,c2,:])**2, axis = 3))/13

Overlap_sigsig_average = np.mean(Overlap_sigsig,6)
Overlap_sigrelu_average = np.mean(Overlap_sigrelu,6)
Overlap_relurelu_average = np.mean(Overlap_relurelu,6)
Overlap_relusig_average = np.mean(Overlap_relusig,6)

#Correlate this with objective overlap between contexts
Correlation_sigsig = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_sigrelu = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_relurelu = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_relusig = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            for nr in range(nRepeats):
                actual_sigsig = np.reshape(Overlap_sigsig_average[m,l,r,nr,:,:], (-1))
                actual_sigrelu = np.reshape(Overlap_sigrelu_average[m,l,r,nr,:,:], (-1))
                actual_relurelu = np.reshape(Overlap_relurelu_average[m,l,r,nr,:,:], (-1))
                actual_relusig = np.reshape(Overlap_relusig_average[m,l,r,nr,:,:], (-1))
                target_sigsig = np.reshape(target_overlap_sigsig[m,l,r,:,:], (-1))
                target_sigrelu = np.reshape(target_overlap_sigrelu[m,l,r,:,:], (-1))
                target_relurelu = np.reshape(target_overlap_relurelu[m,l,r,:,:], (-1))
                target_relusig = np.reshape(target_overlap_relusig[m,l,r,:,:], (-1))
                Correlation_sigsig[m,l,r,nr] = stats.spearmanr(actual_sigsig, target_sigsig)[0]
                Correlation_sigrelu[m,l,r,nr] = stats.spearmanr(actual_sigrelu, target_sigrelu)[0]
                Correlation_relurelu[m,l,r,nr] = stats.spearmanr(actual_relurelu, target_relurelu)[0]
                Correlation_relusig[m,l,r,nr] = stats.spearmanr(actual_relusig, target_relusig)[0]

Correlation_sigsig_mean = np.mean(Correlation_sigsig,2)
Correlation_sigrelu_mean = np.mean(Correlation_sigrelu,2)
Correlation_relurelu_mean = np.mean(Correlation_relurelu,2)
Correlation_relusig_mean = np.mean(Correlation_relusig,2)

Correlation_sigsig_ci = 1.96*np.std(Correlation_sigsig,2)/np.sqrt(Rep)
Correlation_sigrelu_ci = 1.96*np.std(Correlation_sigrelu,2)/np.sqrt(Rep)
Correlation_relurelu_ci = 1.96*np.std(Correlation_relurelu,2)/np.sqrt(Rep)
Correlation_relusig_ci = 1.96*np.std(Correlation_relusig,2)/np.sqrt(Rep)

#save results of analyses
Stroop_RDM_train_dir = {
    "sigsig_mean": np.mean(Correlation_sigsig_mean,1),
    "sigsig_ci": np.mean(Correlation_sigsig_ci,1),
    "sigrelu_mean": np.mean(Correlation_sigrelu_mean,1),
    "sigrelu_ci": np.mean(Correlation_sigrelu_ci,1),
    "relurelu_mean": np.mean(Correlation_relurelu_mean,1),
    "relurelu_ci": np.mean(Correlation_relurelu_ci,1),
    "relusig_mean": np.mean(Correlation_relusig_mean,1),
    "relusig_ci": np.mean(Correlation_relusig_ci,1)
}
np.save(Directory + "RDM_train_Stroop.npy", Stroop_RDM_train_dir)

#Make figures
fig, axs = plt.subplots(2, 4, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(Correlation_sigsig_mean[m,:,:],1),  np.mean(Correlation_sigsig_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(Correlation_sigrelu_mean[m,:,:],1),  np.mean(Correlation_sigrelu_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,2].errorbar(learning_rates, np.mean(Correlation_relurelu_mean[m,:,:],1),  np.mean(Correlation_relurelu_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,3].errorbar(learning_rates, np.mean(Correlation_relusig_mean[m,:,:],1),  np.mean(Correlation_relusig_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])

    axs[1,0].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_sigsig_mean[m,:,:],0),  np.mean(Correlation_sigsig_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_sigrelu_mean[m,:,:],0),  np.mean(Correlation_sigrelu_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,2].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_relurelu_mean[m,:,:],0),  np.mean(Correlation_relurelu_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,3].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_relusig_mean[m,:,:],0),  np.mean(Correlation_relusig_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])

for i in range(4):
    axs[0,i].set_xlabel("\u03B1", fontsize = 9)
    axs[0,i].set_xticks(np.arange(0,1.1,.2))
    axs[1,i].set_xlabel("Context repeats", fontsize = 9)
    axs[1,i].set_xticks(np.arange(1,4,1))
    for i2 in range(2):
        axs[i2,i].spines['top'].set_visible(False)
        axs[i2,i].spines['right'].set_visible(False)

axs[0,0].set_ylabel("Representation", fontsize = 9)
axs[1,0].set_ylabel("Representation", fontsize = 9)

axs[0,0].set_title("sigsig combination", fontsize = 9, fontweight="bold")
axs[0,1].set_title("sigrelu combination", fontsize = 9, fontweight="bold")
axs[0,2].set_title("relurelu combination", fontsize = 9, fontweight="bold")
axs[0,3].set_title("relusig combination", fontsize = 9, fontweight="bold")
fig.text(0.01, 0.7, 'For each \u03B1', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.275, 'For each repetition', va='center', rotation='vertical', fontsize = 9, fontweight="bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,12/2.54)
plt.savefig("RDM.png", dpi = 300)
plt.show()

# Perform pca on network activation
from sklearn.decomposition import PCA
p = PCA(n_components = 2)

pca_sigsig = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))
pca_sigrelu = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))
pca_relurelu = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))
pca_relusig = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))

contexts=["A","B","C","D","E"]
color_bis = ["c", "m", "y", "b","k"]

rate = 5
repid = np.random.randint(0,Rep)
print(repid)

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_sigsig = np.transpose(np.reshape(activation_sigsig[m,lr,r,:,:,:,:],(13,-1)))
            data_sigrelu = np.transpose(np.reshape(activation_sigrelu[m,lr,r,:,:,:,:],(13,-1)))
            data_relurelu = np.transpose(np.reshape(activation_relurelu[m,lr,r,:,:,:,:],(13,-1)))
            data_relusig = np.transpose(np.reshape(activation_relusig[m,lr,r,:,:,:,:],(13,-1)))

            pca_sigsig[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sigsig)),(2,nRepeats,nContexts,nPatterns))
            pca_sigrelu[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sigrelu)),(2,nRepeats,nContexts,nPatterns))
            pca_relurelu[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_relurelu)),(2,nRepeats,nContexts,nPatterns))
            pca_relusig[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_relusig)),(2,nRepeats,nContexts,nPatterns))

#Save analyses results
Stroop_pca_train_dir = {
    "sigsig": pca_sigsig,
    "sigrelu": pca_sigrelu,
    "relurelu": pca_relurelu,
    "relurelu": pca_relusig
}
np.save(Directory + "PCA_train_Stroop.npy", Stroop_pca_train_dir)

#Make figures
os.chdir(figdir)
fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_sigsig[m,rate,repid,0,r,i,:], pca_sigsig[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pcasig.png", dpi=300)
plt.show()

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_relurelu[m,rate,repid,0,r,i,:], pca_relurelu[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pcarelu.png", dpi=300)
plt.show()
