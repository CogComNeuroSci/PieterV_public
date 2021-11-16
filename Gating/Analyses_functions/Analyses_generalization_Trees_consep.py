import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

#Define data and simulation parameters
Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/conc/"
learning_rates= np.arange(0,1.1,0.2)
Rep= 25
resources = 12
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 4
nRepeats= 3
nPatterns = 4

#If you run script for the first time, set this on False
loaded = False

#Function to load data
def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/", learning_rates= np.arange(0,1.1,0.2), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 12, nContexts= 4, nRepeats= 3, nPatterns = 4, method = "conc"):

    #Extract mean accuracy and activation for each stimulus, also extract contextorder and objective overlap
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))

    i = -1
    for m in Models:
        i+=1
        data = np.load(Directory + method + "/Trees/"+ m + "/Generalization_data.npy", allow_pickle = True)
        Contextorder[i,:,:,:] = data[()]["Contextorder"]
        Overlap[i,:,:,:,:]= data[()]["Overlap"]
        Inputs = data[()]["Presented"]
        P = []
        P.append(((Inputs[:,:,:,0]>0.5)*1 + (Inputs[:,:,:,1]>0.5)*1)==2)
        P.append(((Inputs[:,:,:,0]>0.5)*1 + (Inputs[:,:,:,1]<0.5)*1)==2)
        P.append(((Inputs[:,:,:,0]<0.5)*1 + (Inputs[:,:,:,1]>0.5)*1)==2)
        P.append(((Inputs[:,:,:,0]<0.5)*1 + (Inputs[:,:,:,1]<0.5)*1)==2)

        for lr in range(len(learning_rates)):
            for r in range(Rep):
                for n in range(nPatterns):
                    id1 = P[n][lr][r]
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

#Load and extract data
data_dict = {}
for i in ["conc", "sep"]:
    data_dict[i] = load_data(method=i)

order_conc = data_dict["conc"]["order"]
order_sep = data_dict["sep"]["order"]

target_overlap_conc = data_dict["conc"]["target_overlap"]
target_overlap_sep = data_dict["sep"]["target_overlap"]

accuracy_conc = data_dict["conc"]["accuracy"]
accuracy_sep = data_dict["sep"]["accuracy"]

activation_conc = data_dict["conc"]["activation"]
activation_sep = data_dict["sep"]["activation"]

# Save activation
Trees_activation_gen_dir = {
    "conc": activation_conc,
    "sep": activation_sep
}
np.save(Directory + "Activation_Trees.npy", Trees_activation_gen_dir)

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Trees/Revision"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]
os.chdir(figdir)

#Accuracy analyses
mean_accuracy_conc = np.mean(np.mean(accuracy_conc,4),2)*100
std_accuracy_conc = np.std(np.mean(accuracy_conc,4), axis = 2)*100
ci_accuracy_conc = 1.96*std_accuracy_conc/np.sqrt(Rep)

mean_accuracy_sep = np.mean(np.mean(accuracy_sep,4),2)*100
std_accuracy_sep = np.std(np.mean(accuracy_sep,4), axis = 2)*100
ci_accuracy_sep = 1.96*std_accuracy_sep/np.sqrt(Rep)

#save results of analyses
Trees_accuracy_gen_dir = {
    "conc_mean": mean_accuracy_conc,
    "conc_ci": ci_accuracy_conc,
    "sep_mean": mean_accuracy_sep,
    "sep_ci": ci_accuracy_sep
}
np.save(Directory + "Accuracy_gen_Trees.npy", Trees_accuracy_gen_dir)

#Make figures
os.chdir(figdir)
fig, axs = plt.subplots(2,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(mean_accuracy_conc[m,:,:],1),np.mean(ci_accuracy_conc[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(mean_accuracy_sep[m,:,:],1),np.mean(ci_accuracy_sep[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_conc[m,:,:],0),np.mean(ci_accuracy_conc[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_sep[m,:,:],0),np.mean(ci_accuracy_sep[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("Concatenated activation", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("Separated activation", fontsize = 9, fontweight = "bold")

axs[0,0].set_xlabel("\u03B1", fontsize = 9)
axs[0,1].set_xlabel("\u03B1", fontsize = 9)
axs[0,0].set_xticks(np.arange(0,1.1,.2))
axs[0,1].set_xticks(np.arange(0,1.1,.2))

axs[1,0].set_xticks(np.arange(1, nContexts+1))
axs[1,1].set_xticks(np.arange(1, nContexts+1))
axs[1,0].set_xticklabels(["L","Br","and","xor"], fontsize = 9)
axs[1,1].set_xticklabels(["L","Br","and","xor"], fontsize = 9)
axs[1,0].set_xlabel("Contexts", fontsize = 9)
axs[1,1].set_xlabel("Contexts", fontsize = 9)

axs[0,0].set_ylabel("Accuracy %", fontsize = 9)
axs[1,0].set_ylabel("Accuracy %", fontsize = 9)

axs[0,0].spines['right'].set_visible(False)
axs[0,0].spines['top'].set_visible(False)
axs[1,0].spines['right'].set_visible(False)
axs[1,0].spines['top'].set_visible(False)
axs[0,1].spines['right'].set_visible(False)
axs[0,1].spines['top'].set_visible(False)
axs[1,1].spines['right'].set_visible(False)
axs[1,1].spines['top'].set_visible(False)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.text(0.01, 0.7, 'For each \u03B1', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.275, 'For each context', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

fig.subplots_adjust(left= .15, right=.85)
fig.set_size_inches(15/2.54,12/2.54)
plt.savefig("Accuracy_generalization.png", dpi = 300)
plt.show()

#Compute overlap in network activation
from scipy import stats

Overlap_conc = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_sep =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_conc[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_conc[:,:,:,:,c1,:] - activation_conc[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_sep[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sep[:,:,:,:,c1,:] - activation_sep[:,:,:,:,c2,:])**2, axis = 3))/25

Overlap_conc_average = np.mean(Overlap_conc,5)
Overlap_sep_average = np.mean(Overlap_sep,5)

#Correlate this with objective overlap between contexts
Correlation_conc = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_sep = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            actual_conc = np.reshape(Overlap_conc_average[m,l,r,:,:], (-1))
            actual_sep= np.reshape(Overlap_sep_average[m,l,r,:,:], (-1))
            target_conc = np.reshape(target_overlap_conc[m,l,r,:,:], (-1))
            target_sep = np.reshape(target_overlap_sep[m,l,r,:,:], (-1))
            Correlation_conc[m,l,r] = stats.spearmanr(actual_conc, target_conc)[0]
            Correlation_sep[m,l,r] = stats.spearmanr(actual_sep, target_sep)[0]

Correlation_conc_mean = np.mean(Correlation_conc,2)
Correlation_sep_mean = np.mean(Correlation_sep,2)

Correlation_conc_ci = 1.96*np.std(Correlation_conc,axis=2)/np.sqrt(Rep)
Correlation_sep_ci = 1.96*np.std(Correlation_sep,axis=2)/np.sqrt(Rep)

#save results of analyses
Trees_RDM_gen_dir = {
    "conc_mean": Correlation_conc_mean,
    "conc_ci": Correlation_conc_ci,
    "sep_mean": Correlation_sep_mean,
    "sep_ci": Correlation_sep_ci
}
np.save(Directory + "RDM_gen_Trees.npy", Trees_RDM_gen_dir)

#Make figures
fig, axs = plt.subplots(1, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, Correlation_conc_mean[m,:],  Correlation_conc_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1].errorbar(learning_rates, Correlation_sep_mean[m,:],  Correlation_sep_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])

for i in range(2):
    axs[i].set_xlabel("\u03B1", fontsize = 9)
    axs[i].spines['top'].set_visible(False)
    axs[i].spines['right'].set_visible(False)

axs[0].set_ylabel("Representation", fontsize = 9)
axs[0].set_title("Concatenated activation", fontsize = 9, fontweight = "bold")
axs[1].set_title("Separated activation", fontsize = 9, fontweight = "bold")
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xticks(np.arange(0,1.1,.2))

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")

fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,6/2.54)
plt.savefig("RDM_generalization.png", dpi = 300)
plt.show()

# Perform pca on network activation
from sklearn.decomposition import PCA
p = PCA(n_components = 2)

pca_conc = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_sep = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))

pca_conc_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_sep_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_conc = np.transpose(np.reshape(activation_conc[m,lr,r,:,:,:],(13,-1)))
            data_sep = np.transpose(np.reshape(activation_sep[m,lr,r,:,:,:],(13,-1)))

            pca_conc[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_conc)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_conc_explained[m,lr,r,:]=p.explained_variance_ratio_

            pca_sep[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sep)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_sep_explained[m,lr,r,:]=p.explained_variance_ratio_

print(np.mean(np.reshape(np.sum(pca_conc_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_conc_explained,3),-1)))
print(np.mean(np.reshape(np.sum(pca_sep_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_sep_explained,3),-1)))

#Save analyses results
Trees_pca_gen_dir = {
    "conc": pca_conc,
    "sep": pca_sep
}
np.save(Directory + "PCA_gen_Trees.npy", Trees_pca_gen_dir)
