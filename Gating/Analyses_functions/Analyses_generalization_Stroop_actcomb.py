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
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))

    i = -1
    for m in Models:
        i+=1
        if "add" in m:
            data = np.load(Directory + "Stroop/"+ m +"/Generalization_data_" + act[0] +".npy", allow_pickle = True)
        else:
            data = np.load(Directory + "Stroop/"+ m +"/Generalization_data_" + act[0] + "_" + act[1] + ".npy", allow_pickle = True)

        Contextorder[i,:,:,:] = data[()]["Contextorder"]
        Overlap[i,:,:,:,:] = data[()]["Overlap"]

        for lr in range(len(learning_rates)):
            for r in range(Rep):
                for n in range(nPatterns):
                    id1 = data[()]["Presented"][lr,r,:]==n
                    for c in range(nContexts):
                        id2 = data[()]["Contextorder"][lr,r,:]==c
                        Accuracy_labeled[i,lr,r,c,n]= np.mean(data[()]["Accuracy"][lr,r,id2,id1])
                        Activation_labeled[i,lr,r,:,c,n]=np.mean(data[()]["Activation"][lr,r,:,id2,id1],0)

    new_dict = {
        "order": Contextorder,
        "target_overlap": Overlap,
        "accuracy": Accuracy_labeled,
        "activation": Activation_labeled
    }

    return new_dict

#If data was not loaded before, do it now and save
data_dict = {}
for i in ["sig", "relu"]:
    for j in ["sig", "relu"]:
        data_dict[i+j] = load_data(act = [i,j])

order_sigsig= data_dict["sigsig"]["order"]
order_relurelu = data_dict["relurelu"]["order"]
order_sigrelu = data_dict["sigrelu"]["order"]
order_relusig = data_dict["relusig"]["order"]

target_overlap_sigsig = data_dict["sigsig"]["target_overlap"]
target_overlap_relurelu = data_dict["relurelu"]["target_overlap"]
target_overlap_sigrelu = data_dict["sigrelu"]["target_overlap"]
target_overlap_relusig = data_dict["relusig"]["target_overlap"]

accuracy_sigsig = data_dict["sigsig"]["accuracy"]
accuracy_relurelu = data_dict["relurelu"]["accuracy"]
accuracy_sigrelu = data_dict["sigrelu"]["accuracy"]
accuracy_relusig = data_dict["relusig"]["accuracy"]

activation_sigsig = data_dict["sigsig"]["activation"]
activation_relurelu = data_dict["relurelu"]["activation"]
activation_sigrelu = data_dict["sigrelu"]["activation"]
activation_relusig = data_dict["relusig"]["activation"]

# Save activation
Stroop_activation_gen_dir = {
    "sigsig": activation_sigsig,
    "sigrelu": activation_sigrelu,
    "relurelu": activation_relurelu,
    "relusig": activation_relusig,
}
np.save(Directory + "Activation_Stroop.npy", Stroop_activation_gen_dir)

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Stroop/Revision/comb/"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

#Accuracy analyses
mean_accuracy_sigsig = np.mean(np.mean(accuracy_sigsig,4),2)*100
std_accuracy_sigsig = np.std(np.mean(accuracy_sigsig,4), axis = 2)*100
ci_accuracy_sigsig = 1.96*std_accuracy_sigsig/np.sqrt(Rep)

mean_accuracy_sigrelu = np.mean(np.mean(accuracy_sigrelu,4),2)*100
std_accuracy_sigrelu = np.std(np.mean(accuracy_sigrelu,4), axis = 2)*100
ci_accuracy_sigrelu = 1.96*std_accuracy_sigrelu/np.sqrt(Rep)

mean_accuracy_relurelu = np.mean(np.mean(accuracy_relurelu,4),2)*100
std_accuracy_relurelu = np.std(np.mean(accuracy_relurelu,4), axis = 2)*100
ci_accuracy_relurelu = 1.96*std_accuracy_relurelu/np.sqrt(Rep)

mean_accuracy_relusig = np.mean(np.mean(accuracy_relusig,4),2)*100
std_accuracy_relusig = np.std(np.mean(accuracy_relusig,4), axis = 2)*100
ci_accuracy_relusig = 1.96*std_accuracy_relusig/np.sqrt(Rep)

#save results of analyses
Stroop_accuracy_gen_dir = {
    "sigsig_mean": mean_accuracy_sigsig,
    "sigsig_ci": ci_accuracy_sigsig,
    "sigrelu_mean": mean_accuracy_sigrelu,
    "sigrelu_ci": ci_accuracy_sigrelu,
    "relurelu_mean": mean_accuracy_relurelu,
    "relurelu_ci": ci_accuracy_relurelu,
    "relusig_mean": mean_accuracy_relusig,
    "relusig_ci": ci_accuracy_relusig
}
np.save(Directory + "Accuracy_gen_Stroop.npy", Stroop_accuracy_gen_dir)

#Make figures
os.chdir(figdir)
fig, axs = plt.subplots(2,4, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(mean_accuracy_sigsig[m,:,:],1),np.mean(ci_accuracy_sigsig[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(mean_accuracy_sigrelu[m,:,:],1),np.mean(ci_accuracy_sigrelu[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,2].errorbar(learning_rates, np.mean(mean_accuracy_relurelu[m,:,:],1),np.mean(ci_accuracy_relurelu[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,3].errorbar(learning_rates, np.mean(mean_accuracy_relusig[m,:,:],1),np.mean(ci_accuracy_relusig[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_sigsig[m,:,:],0),np.mean(ci_accuracy_sigsig[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_sigrelu[m,:,:],0),np.mean(ci_accuracy_sigrelu[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,2].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_relurelu[m,:,:],0),np.mean(ci_accuracy_relurelu[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,3].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_relusig[m,:,:],0),np.mean(ci_accuracy_relusig[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("sigsig", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("sigrelu", fontsize = 9, fontweight = "bold")
axs[0,2].set_title("relurelu", fontsize = 9, fontweight = "bold")
axs[0,3].set_title("relusig", fontsize = 9, fontweight = "bold")

for i in range(2):
    axs[i,0].set_ylabel("Accuracy %", fontsize = 9)
    for j in range(4):
        axs[0,j].set_xticks(np.arange(0,1.1,.2))
        axs[0,j].set_xlabel("\u03B1", fontsize = 9)
        axs[1,j].set_xticks(np.arange(1, nContexts+1))
        axs[1,j].set_xticklabels(["A","B","C","D","E"], fontsize = 9)
        axs[1,j].set_xlabel("Contexts", fontsize = 9)
        axs[i,j].spines['right'].set_visible(False)
        axs[i,j].spines['top'].set_visible(False)


handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.7, 'For each \u03B1', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.275, 'For each context', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85)
fig.set_size_inches(15/2.54,12/2.54)
plt.savefig("Accuracy_generalization.png", dpi = 300)
plt.show()

from scipy import stats

#Compute overlap in network activation
Overlap_sigsig = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_sigrelu = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_relurelu =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_relusig =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_sigsig[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sigsig[:,:,:,:,c1,:] - activation_sigsig[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_sigrelu[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sigrelu[:,:,:,:,c1,:] - activation_sigrelu[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_relusig[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_relusig[:,:,:,:,c1,:] - activation_relusig[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_relurelu[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_relurelu[:,:,:,:,c1,:] - activation_relurelu[:,:,:,:,c2,:])**2, axis = 3))/13

Overlap_sigsig_average = np.mean(Overlap_sigsig,5)
Overlap_sigrelu_average = np.mean(Overlap_sigrelu,5)
Overlap_relurelu_average = np.mean(Overlap_relurelu,5)
Overlap_relusig_average = np.mean(Overlap_relusig,5)

#Correlate this with objective overlap between contexts
Correlation_sigsig = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_sigrelu = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_relurelu = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_relusig = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
                actual_sigsig = np.reshape(Overlap_sigsig_average[m,l,r,:,:], (-1))
                actual_sigrelu = np.reshape(Overlap_sigrelu_average[m,l,r,:,:], (-1))
                actual_relurelu = np.reshape(Overlap_relurelu_average[m,l,r,:,:], (-1))
                actual_relusig = np.reshape(Overlap_relusig_average[m,l,r,:,:], (-1))
                target_sigsig = np.reshape(target_overlap_sigsig[m,l,r,:,:], (-1))
                target_sigrelu = np.reshape(target_overlap_sigrelu[m,l,r,:,:], (-1))
                target_relurelu = np.reshape(target_overlap_relurelu[m,l,r,:,:], (-1))
                target_relusig = np.reshape(target_overlap_relusig[m,l,r,:,:], (-1))
                Correlation_sigsig[m,l,r] = stats.spearmanr(actual_sigsig, target_sigsig)[0]
                Correlation_sigrelu[m,l,r] = stats.spearmanr(actual_sigrelu, target_sigrelu)[0]
                Correlation_relurelu[m,l,r] = stats.spearmanr(actual_relurelu, target_relurelu)[0]
                Correlation_relusig[m,l,r] = stats.spearmanr(actual_relusig, target_relusig)[0]

Correlation_sigsig_mean = np.mean(Correlation_sigsig,2)
Correlation_sigrelu_mean = np.mean(Correlation_sigrelu,2)
Correlation_relurelu_mean = np.mean(Correlation_relurelu,2)
Correlation_relusig_mean = np.mean(Correlation_relusig,2)

Correlation_sigsig_ci = 1.96*np.std(Correlation_sigsig,2)/np.sqrt(Rep)
Correlation_sigrelu_ci = 1.96*np.std(Correlation_sigrelu,2)/np.sqrt(Rep)
Correlation_relurelu_ci = 1.96*np.std(Correlation_relurelu,2)/np.sqrt(Rep)
Correlation_relusig_ci = 1.96*np.std(Correlation_relusig,2)/np.sqrt(Rep)

#save results of analyses
Stroop_RDM_gen_dir = {
    "sigsig_mean": Correlation_sigsig_mean,
    "sigsig_ci": Correlation_sigsig_ci,
    "sigrelu_mean": Correlation_sigrelu_mean,
    "sigrelu_ci": Correlation_sigrelu_ci,
    "relurelu_mean": Correlation_relurelu_mean,
    "relurelu_ci": Correlation_relurelu_ci,
    "relusig_mean": Correlation_relusig_mean,
    "relusig_ci": Correlation_relusig_ci
}
np.save(Directory + "RDM_gen_Stroop.npy", Stroop_RDM_gen_dir)

#Make figures
fig, axs = plt.subplots(1, 4, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, Correlation_sigsig_mean[m,:],  Correlation_sigsig_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1].errorbar(learning_rates, Correlation_sigrelu_mean[m,:],  Correlation_sigrelu_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[2].errorbar(learning_rates, Correlation_relurelu_mean[m,:],  Correlation_relurelu_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[3].errorbar(learning_rates, Correlation_relusig_mean[m,:],  Correlation_relusig_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])

for i in range(4):
    axs[i].set_xlabel("\u03B1", fontsize = 9)
    axs[i].spines['top'].set_visible(False)
    axs[i].spines['right'].set_visible(False)

axs[0].set_ylabel("Representation", fontsize = 9)

axs[0].set_title("sigsig combination", fontsize = 9, fontweight="bold")
axs[1].set_title("sigrelu combination", fontsize = 9, fontweight="bold")
axs[2].set_title("relurelu combination", fontsize = 9, fontweight="bold")
axs[3].set_title("relusig combination", fontsize = 9, fontweight="bold")

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,6/2.54)
plt.savefig("RDM_generalization.png", dpi = 300)
plt.show()

# Perform pca on network activation
from sklearn.decomposition import PCA
p = PCA(n_components = 2)

pca_sigsig = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_sigrelu = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_relurelu = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_relusig = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))

pca_sigsig_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_sigrelu_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_relurelu_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_relusig_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_sigsig = np.transpose(np.reshape(activation_sigsig[m,lr,r,:,:,:],(13,-1)))
            data_sigrelu = np.transpose(np.reshape(activation_sigrelu[m,lr,r,:,:,:],(13,-1)))
            data_relurelu = np.transpose(np.reshape(activation_relurelu[m,lr,r,:,:,:],(13,-1)))
            data_relusig = np.transpose(np.reshape(activation_relusig[m,lr,r,:,:,:],(13,-1)))

            pca_sigsig[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sigsig)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_sigsig_explained[m,lr,r,:]=p.explained_variance_ratio_
            pca_sigrelu[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sigrelu)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_sigsig_explained[m,lr,r,:]=p.explained_variance_ratio_
            pca_relurelu[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_relurelu)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_sigsig_explained[m,lr,r,:]=p.explained_variance_ratio_
            pca_relusig[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_relusig)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_sigsig_explained[m,lr,r,:]=p.explained_variance_ratio_

#Save analyses results
Stroop_pca_gen_dir = {
    "sigsig": pca_sigsig,
    "sigrelu": pca_sigrelu,
    "relurelu": pca_relurelu,
    "relurelu": pca_relusig
}
np.save(Directory + "PCA_gen_Stroop.npy", Stroop_pca_gen_dir)
