import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

Directory = "/Volumes/backupdisc/Modular_learning/Data_Leafs/"
learning_rates= np.arange(0,1.1,0.1)
Rep= 50
resources = [12,24]
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 4
nRepeats= 3
nPatterns = 4

loaded = True

def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Leafs/", learning_rates= np.arange(0,1.1,0.1), Rep= 50, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 24, nContexts= 4, nRepeats= 3, nPatterns = 4):

    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))

    i = -1
    for m in Models:
        i+=1
        data = np.load(Directory + str(resources) + "/"+ m + "/Generalization_data.npy", allow_pickle = True)
        Inputs = data[()]["Labels"]
        Contextorder[i,:,:,:] = data[()]["Contextorder"]
        Overlap[i,:,:,:,:]= data[()]["Overlap"]
        for lr in range(len(learning_rates)):
            for r in range(Rep):
                P = []
                P.append(((Inputs[lr,r,:,0]>0.5)*1 + (Inputs[lr,r,:,1]>0.5)*1)==2)
                P.append(((Inputs[lr,r,:,0]>0.5)*1 + (Inputs[lr,r,:,1]<0.5)*1)==2)
                P.append(((Inputs[lr,r,:,0]<0.5)*1 + (Inputs[lr,r,:,1]>0.5)*1)==2)
                P.append(((Inputs[lr,r,:,0]<0.5)*1 + (Inputs[lr,r,:,1]<0.5)*1)==2)
                for n in range(nPatterns):
                    id1 = P[n]
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
for i in [12, 24]:
    data_dict[str(i)] = load_data(resources=i)

order_12 = data_dict["12"]["order"]
order_24 = data_dict["24"]["order"]

target_overlap_12 = data_dict["12"]["target_overlap"]
target_overlap_24 = data_dict["24"]["target_overlap"]

accuracy_12 = data_dict["12"]["accuracy"]
accuracy_24 = data_dict["24"]["accuracy"]

activation_12 = data_dict["12"]["activation"]
activation_24 = data_dict["24"]["activation"]

Trees_activation_gen_dir = {
    "12_Hidden": activation_12,
    "24_Hidden": activation_24
}
#np.save(Directory + "Activation_Trees.npy", Trees_activation_gen_dir)

figdir = "/Volumes/backupdisc/Modular_learning/Plots_Leafs"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

mean_accuracy_12 = np.mean(np.mean(accuracy_12,4),2)*100
std_accuracy_12 = np.std(np.mean(accuracy_12,4), axis = 2)*100
ci_accuracy_12 = 1.96*std_accuracy_12#/np.sqrt(Rep)

mean_accuracy_24 = np.mean(np.mean(accuracy_24,4),2)*100
std_accuracy_24 = np.std(np.mean(accuracy_24,4), axis = 2)*100
ci_accuracy_24 = 1.96*std_accuracy_24#/np.sqrt(Rep)

Trees_accuracy_gen_dir = {
    "12_Hidden_mean": mean_accuracy_12,
    "12_Hidden_ci": ci_accuracy_12,
    "24_Hidden_mean": mean_accuracy_24,
    "24_Hidden_ci": ci_accuracy_24
}
#np.save(Directory + "Accuracy_gen_Trees.npy", Trees_accuracy_gen_dir)

os.chdir(figdir)
fig, axs = plt.subplots(2,2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(mean_accuracy_12[m,:,:],1),np.mean(ci_accuracy_12[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(mean_accuracy_24[m,:,:],1),np.mean(ci_accuracy_24[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_12[m,:,:],0),np.mean(ci_accuracy_12[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(1,nContexts+1), np.mean(mean_accuracy_24[m,:,:],0),np.mean(ci_accuracy_24[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("12 Hidden neurons", fontsize = 9, fontweight = "bold")
axs[0,1].set_title("24 Hidden neurons", fontsize = 9, fontweight = "bold")

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

#plt.savefig("Accuracy_generalization.png", dpi = 300)
#plt.show()

from scipy import stats

Overlap_12 = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))
Overlap_24 =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_12[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_12[:,:,:,:,c1,:] - activation_12[:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_24[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_24[:,:,:,:,c1,:] - activation_24[:,:,:,:,c2,:])**2, axis = 3))/25

Overlap_12_average = np.mean(Overlap_12,5)
Overlap_24_average = np.mean(Overlap_24,5)

Correlation_12 = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_24 = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            actual_12 = np.reshape(Overlap_12_average[m,l,r,:,:], (-1))
            actual_24= np.reshape(Overlap_24_average[m,l,r,:,:], (-1))
            target_12 = np.reshape(target_overlap_12[m,l,r,:,:], (-1))
            target_24 = np.reshape(target_overlap_24[m,l,r,:,:], (-1))
            Correlation_12[m,l,r] = stats.spearmanr(actual_12, target_12)[0]
            Correlation_24[m,l,r] = stats.spearmanr(actual_24, target_24)[0]

Correlation_12_mean = np.mean(Correlation_12,2)
Correlation_24_mean = np.mean(Correlation_24,2)

Correlation_12_ci = 1.96*np.std(Correlation_12,axis=2)#/np.sqrt(Rep)
Correlation_24_ci = 1.96*np.std(Correlation_24,axis=2)#/np.sqrt(Rep)

Trees_RDM_gen_dir = {
    "12_Hidden_mean": Correlation_12_mean,
    "12_Hidden_ci": Correlation_12_ci,
    "24_Hidden_mean": Correlation_24_mean,
    "24_Hidden_ci": Correlation_24_ci
}
np.save(Directory + "RDM_gen_Trees_2.npy", Trees_RDM_gen_dir)

fig, axs = plt.subplots(1, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, Correlation_12_mean[m,:],  Correlation_12_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1].errorbar(learning_rates, Correlation_24_mean[m,:],  Correlation_24_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])

for i in range(2):
    axs[i].set_xlabel("\u03B1", fontsize = 9)
    axs[i].spines['top'].set_visible(False)
    axs[i].spines['right'].set_visible(False)

axs[0].set_ylabel("Representation", fontsize = 9)
axs[0].set_title("12 hidden neurons", fontsize = 9, fontweight = "bold")
axs[1].set_title("24 hidden neurons", fontsize = 9, fontweight = "bold")
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xticks(np.arange(0,1.1,.2))

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")

fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,6/2.54)

#plt.savefig("RDM_generalization.png", dpi = 300)
#plt.show()

from sklearn.decomposition import PCA
p = PCA(n_components = 2)

pca_12 = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))
pca_24 = np.zeros((len(Models),len(learning_rates),Rep, 2,nContexts,nPatterns))

pca_12_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_24_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_12 = np.transpose(np.reshape(activation_12[m,lr,r,:,:,:],(13,-1)))
            data_24 = np.transpose(np.reshape(activation_24[m,lr,r,:,:,:],(25,-1)))

            pca_12[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_12)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_12_explained[m,lr,r,:]=p.explained_variance_ratio_

            pca_24[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_24)),(2,nContexts,nPatterns))
            PCA(n_components = 2)
            pca_24_explained[m,lr,r,:]=p.explained_variance_ratio_

print(np.mean(np.reshape(np.sum(pca_12_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_12_explained,3),-1)))
print(np.mean(np.reshape(np.sum(pca_24_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_24_explained,3),-1)))

Trees_pca_gen_dir = {
    "12_Hidden": pca_12,
    "24_Hidden": pca_24
}
#np.save(Directory + "PCA_gen_Trees.npy", Trees_pca_gen_dir)
