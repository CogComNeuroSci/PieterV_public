import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

#Define data and simulation parameters
Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/initialize/"
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
def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/initialize/", learning_rates= np.arange(0,1.1,0.2), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 12, nContexts= 5, nRepeats= 3, nPatterns = 18, method = "normal"):

    #Extract mean accuracy and activation for each stimulus, also extract contextorder and objective overlap
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))

    i = -1
    for m in Models:
        i+=1
        data = np.load(Directory + "Stroop/"+ m + "/Generalization_data_" + method + ".npy", allow_pickle = True)
        Contextorder[i,:,:,:] = data[()]["Contextorder"]
        Overlap[i,:,:,:,:]= data[()]["Overlap"]
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

#Load and extract data
data_dict = {}
for i in ["normal", "uniform"]:
    data_dict[i] = load_data(method=i)

order_normal = data_dict["normal"]["order"]
order_uniform = data_dict["uniform"]["order"]

target_overlap_normal = data_dict["normal"]["target_overlap"]
target_overlap_uniform = data_dict["uniform"]["target_overlap"]

accuracy_normal = data_dict["normal"]["accuracy"]
accuracy_uniform = data_dict["uniform"]["accuracy"]

activation_normal = data_dict["normal"]["activation"]
activation_uniform = data_dict["uniform"]["activation"]

# Save activation
Stroop_activation_gen_dir = {
    "normal": activation_normal,
    "uniform": activation_uniform
}
np.save(Directory + "Activation_Stroop.npy", Stroop_activation_gen_dir)

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Stroop/Revision"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]
os.chdir(figdir)

#Accuracy analyses
mean_accuracy_normal = np.mean(np.mean(accuracy_normal,4),2)*100
std_accuracy_normal = np.std(np.mean(accuracy_normal,4), axis = 2)*100
ci_accuracy_normal = 1.96*std_accuracy_normal/np.sqrt(Rep)

mean_accuracy_uniform = np.mean(np.mean(accuracy_uniform,4),2)*100
std_accuracy_uniform = np.std(np.mean(accuracy_uniform,4), axis = 2)*100
ci_accuracy_uniform = 1.96*std_accuracy_uniform/np.sqrt(Rep)

#save results of analyses
Stroop_accuracy_gen_dir = {
    "normal_mean": mean_accuracy_normal,
    "normal_ci": ci_accuracy_normal,
    "uniform_mean": mean_accuracy_uniform,
    "uniform_ci": ci_accuracy_uniform
}
np.save(Directory + "Accuracy_gen_Stroop.npy", Stroop_accuracy_gen_dir)

#Make figures
os.chdir(figdir)
fig, axs = plt.subplots(2,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(mean_accuracy_normal[m,:,:],1),np.mean(ci_accuracy_normal[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(mean_accuracy_uniform[m,:,:],1),np.mean(ci_accuracy_uniform[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_normal[m,:,:],0),np.mean(ci_accuracy_normal[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_uniform[m,:,:],0),np.mean(ci_accuracy_uniform[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("normal initialization", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("uniform initialization", fontsize = 9, fontweight = "bold")

axs[0,0].set_xlabel("\u03B1", fontsize = 9)
axs[0,1].set_xlabel("\u03B1", fontsize = 9)
axs[0,0].set_xticks(np.arange(0,1.1,.2))
axs[0,1].set_xticks(np.arange(0,1.1,.2))

axs[1,0].set_xticks(np.arange(1, nContexts+1))
axs[1,1].set_xticks(np.arange(1, nContexts+1))
axs[1,0].set_xticklabels(["A","B","C","D","E"], fontsize = 9)
axs[1,1].set_xticklabels(["A","B","C","D","E"], fontsize = 9)
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

Overlap_normal = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_uniform =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_normal[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_normal[:,:,:,:,c1,:] - activation_normal[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_uniform[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_uniform[:,:,:,:,c1,:] - activation_uniform[:,:,:,:,c2,:])**2, axis = 3))/25

Overlap_normal_average = np.mean(Overlap_normal,5)
Overlap_uniform_average = np.mean(Overlap_uniform,5)

#Correlate this with objective overlap between contexts
Correlation_normal = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_uniform = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            actual_normal = np.reshape(Overlap_normal_average[m,l,r,:,:], (-1))
            actual_uniform= np.reshape(Overlap_uniform_average[m,l,r,:,:], (-1))
            target_normal = np.reshape(target_overlap_normal[m,l,r,:,:], (-1))
            target_uniform = np.reshape(target_overlap_uniform[m,l,r,:,:], (-1))
            Correlation_normal[m,l,r] = stats.spearmanr(actual_normal, target_normal)[0]
            Correlation_uniform[m,l,r] = stats.spearmanr(actual_uniform, target_uniform)[0]

Correlation_normal_mean = np.mean(Correlation_normal,2)
Correlation_uniform_mean = np.mean(Correlation_uniform,2)

Correlation_normal_ci = 1.96*np.std(Correlation_normal,axis=2)/np.sqrt(Rep)
Correlation_uniform_ci = 1.96*np.std(Correlation_uniform,axis=2)/np.sqrt(Rep)

#save results of analyses
Stroop_RDM_gen_dir = {
    "normal_mean": Correlation_normal_mean,
    "normal_ci": Correlation_normal_ci,
    "uniform_mean": Correlation_uniform_mean,
    "uniform_ci": Correlation_uniform_ci
}
np.save(Directory + "RDM_gen_Stroop.npy", Stroop_RDM_gen_dir)

#Make figures
fig, axs = plt.subplots(1, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, Correlation_normal_mean[m,:],  Correlation_normal_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1].errorbar(learning_rates, Correlation_uniform_mean[m,:],  Correlation_uniform_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])

for i in range(2):
    axs[i].set_xlabel("\u03B1", fontsize = 9)
    axs[i].spines['top'].set_visible(False)
    axs[i].spines['right'].set_visible(False)

axs[0].set_ylabel("Representation", fontsize = 9)
axs[0].set_title("normal initialization", fontsize = 9, fontweight = "bold")
axs[1].set_title("uniform initialization", fontsize = 9, fontweight = "bold")
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

pca_normal = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_uniform = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))

pca_normal_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_uniform_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_normal = np.transpose(np.reshape(activation_normal[m,lr,r,:,:,:],(13,-1)))
            data_uniform = np.transpose(np.reshape(activation_uniform[m,lr,r,:,:,:],(13,-1)))

            pca_normal[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_normal)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_normal_explained[m,lr,r,:]=p.explained_variance_ratio_

            pca_uniform[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_uniform)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_uniform_explained[m,lr,r,:]=p.explained_variance_ratio_

print(np.mean(np.reshape(np.sum(pca_normal_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_normal_explained,3),-1)))
print(np.mean(np.reshape(np.sum(pca_uniform_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_uniform_explained,3),-1)))

#Save analyses results
Stroop_pca_gen_dir = {
    "normal": pca_normal,
    "uniform": pca_uniform
}
np.save(Directory + "PCA_gen_Stroop.npy", Stroop_pca_gen_dir)
