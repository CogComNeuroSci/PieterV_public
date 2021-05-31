import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

Directory = "/Volumes/backupdisc/Modular_learning/Data_act/"
learning_rates= np.arange(0,1.1,0.1)
Rep= 50
resources = 24
Models = ["SIGSIG", "RELURELU", "SIGRELU", "RELUSIG"]
nContexts= 5
nRepeats= 3
nPatterns = 18

def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_act/", learning_rates= np.arange(0,1.1,0.1), Rep= 50, Models = ["SIGSIG", "RELURELU", "SIGRELU", "RELUSIG"], resources = 24, nContexts= 5, nRepeats= 3, nPatterns = 18):

    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))

    i = -1
    for m in Models:
        i+=1
        data = np.load(Directory + m + "/Generalization_data.npy", allow_pickle = True)
        Contextorder[i,:,:,:] = data[()]["Contextorder"]
        Overlap[i,:,:,:,:]= data[()]["Overlap"]
        for lr in range(len(learning_rates)):
            for r in range(Rep):
                for n in range(nPatterns):
                    id1 = np.arange(n,90,nPatterns)
                    for c in range(nContexts):
                        id2 = data[()]["Contextorder"][lr,r,:]==c
                        Accuracy_labeled[i,lr,r,c,n]= np.mean(data[()]["Accuracy"][lr,r,id2,id1])
                        Activation_labeled[i,lr,r,:,c,n]=np.mean(data[()]["Activation"][lr,r,:,id2,id1],axis=0)
    new_dict = {
        "order": Contextorder,
        "target_overlap": Overlap,
        "accuracy": Accuracy_labeled,
        "activation": Activation_labeled
    }

    return new_dict

data_dict = {}
data_dict = load_data()

order = data_dict["order"]

target_overlap = data_dict["target_overlap"]

accuracy = data_dict["accuracy"]

activation = data_dict["activation"]

figdir = "/Volumes/backupdisc/Modular_learning/Plots_act"
model_labels=["S-S", "R-R", "S-R", "R-S"]
color_values = ["b", "gold", "r", "k","c"]
color_values2 = ["r", "gold", "b", "k","c"]
contexts = ["A","B","C","D","E"]

mean_accuracy = np.mean(np.mean(accuracy,4),2)*100
std_accuracy = np.std(np.mean(accuracy,4), axis = 2)*100
ci_accuracy = 1.96*std_accuracy#/np.sqrt(Rep)

Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation[:,:,:,:,c1,:] - activation[:,:,:,:,c2,:])**2, axis = 3))/25

Overlap_average = np.mean(Overlap,5)

Correlation = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            actual = np.reshape(Overlap_average[m,l,r,:,:], (-1))
            target = np.reshape(target_overlap[m,l,r,:,:], (-1))
            Correlation[m,l,r] = np.corrcoef(actual, target)[0,1]

Correlation_mean = np.mean(Correlation,2)

Correlation_ci = 1.96*np.std(Correlation,axis=2)#/np.sqrt(Rep)

os.chdir(figdir)
fig, axs = plt.subplots(1, 2)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates+m*0.01, np.mean(mean_accuracy[m,:,:],1),np.mean(std_accuracy[m,:,:],1), lw = 2, color=color_values2[m], label =model_labels[m])
    axs[1].errorbar(learning_rates+m*0.01, -Correlation_mean[m,:],  Correlation_ci[m,:]/1.96, lw = 2, color=color_values2[m], label=model_labels[m])

for i in range(2):
    axs[i].set_xlabel("\u03B1", fontsize = 9)
    axs[i].spines['top'].set_visible(False)
    axs[i].spines['right'].set_visible(False)

axs[1].set_ylabel("Dissimilarity correlation", fontsize = 9)
axs[0].set_ylabel("Accuracy %", fontsize = 9)
axs[0].set_xticks(np.arange(0,1.1,.3))
axs[1].set_xticks(np.arange(0,1.1,.3))

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")

fig.subplots_adjust(right=.85, bottom = .2, wspace =.4)
fig.set_size_inches(13/2.54,6/2.54)

fig.text(0.1, 0.925, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.925, 'b', va='center', fontsize = 9, fontweight = "bold")


plt.savefig("activation_results.png", dpi = 300)
#plt.show()

from sklearn.decomposition import PCA
p = PCA(n_components = 2)

pca = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data = np.transpose(np.reshape(activation[m,lr,r,:,:,:],(25,-1)))

            pca[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data)),(2,nContexts,nPatterns))

rate = 5
repid = 4#np.random.randint(0,Rep)
print(repid)

fig, axs = plt.subplots(2,2)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(len(contexts)):
    axs[0,0].plot(pca[0,rate,repid,0,i,:], pca[0,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts[i], markersize = 1)
    axs[0,1].plot(pca[1,rate,repid,0,i,:], pca[1,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts[i], markersize = 1)
    axs[1,0].plot(pca[2,rate,repid,0,i,:], pca[2,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts[i], markersize = 1)
    axs[1,1].plot(pca[3,rate,repid,0,i,:], pca[3,rate,repid,1,i,:], 'o', color = color_values[i], label=contexts[i], markersize = 1)

axs[0,0].set_ylabel("Dimension 2", fontsize = 9)
axs[1,0].set_ylabel("Dimension 2", fontsize = 9)

axs[0,0].set_title(model_labels[0], fontsize = 9, fontweight="bold")
axs[0,1].set_title(model_labels[1], fontsize = 9, fontweight="bold")
axs[1,0].set_title(model_labels[2], fontsize = 9, fontweight="bold")
axs[1,1].set_title(model_labels[3], fontsize = 9, fontweight="bold")

axs[1,0].set_xlabel("Dimension 1", fontsize = 9)
axs[1,1].set_xlabel("Dimension 1", fontsize = 9)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Tasks")

fig.subplots_adjust(right=.85, hspace =.4, wspace=.4)
fig.set_size_inches(15/2.54,12/2.54)
fig.text(0.1, 0.925, 'a', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.1, 0.45, 'c', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.925, 'b', va='center', fontsize = 9, fontweight = "bold")
fig.text(0.5, 0.45, 'd', va='center', fontsize = 9, fontweight = "bold")

plt.savefig("PCA_activation.png", dpi=300)
