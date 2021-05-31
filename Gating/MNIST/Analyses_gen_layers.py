import numpy as np
from matplotlib import pyplot as plt
from scipy import stats
import os

Directory = "/Volumes/backupdisc/Modular_learning/Data_MNIST/"
learning_rates= np.arange(0,0.11,0.01)
Rep= 50
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 6

def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_MNIST/", learning_rates= np.arange(0,0.11,0.01), Rep= 50, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 400, nContexts= 6, nPatterns = 10):

    Accuracy_numbered_unshuffled = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nPatterns))
    Activation_numbered_unshuffled =  np.zeros((len(Models), len(learning_rates), Rep, resources+1, nContexts, nPatterns))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))
    Labels = np.zeros((len(Models), len(learning_rates), Rep, 500))

    i = -1
    for m in Models:
        i+=1
        for lr in range(len(learning_rates)):
            data = np.load(Directory + m + "/Generalization_data_lr_{:.2f}.npy".format(learning_rates[lr]), allow_pickle = True)
            Overlap[i,lr,:,:,:]= data[()]["Overlap"]
            Labels[i,lr,:,:]= data[()]["Labels"]
            for r in range(Rep):
                for n in np.unique(data[()]["Labels"]):
                    id1 = data[()]["Labels"][r,:]==n
                    for c in range(nContexts):
                        id2 = data[()]["Contextorder"][r,:]==c
                        Accuracy_numbered_unshuffled[i,lr,r,:,int(n)]=np.mean(data[()]["Accuracy"][r,id2,id1])
                        Activation_numbered_unshuffled[i,lr,r,:,c,int(n)]=np.mean(data[()]["Activation"][r,:,id2,id1],0)
    new_dict = {
        "order": Contextorder,
        "target_overlap": Overlap,
        "accuracy": Accuracy_numbered_unshuffled,
        "activation": Activation_numbered_unshuffled
    }
    return new_dict

data_dict = {}
for i in range(2):
    if i == 0:
        Dir = Directory + 'Onelayer/'
    else:
        Dir = Directory

    data_dict[str(i)] = load_data(Directory = Dir, resources = 400 + i)

order_1 = data_dict["0"]["order"]
order_2 = data_dict["1"]["order"]

target_overlap_1 = data_dict["0"]["target_overlap"]
target_overlap_2 = data_dict["1"]["target_overlap"]

accuracy_1 = data_dict["0"]["accuracy"]
accuracy_2 = data_dict["1"]["accuracy"]

activation_1 = data_dict["0"]["activation"]
activation_2 = data_dict["1"]["activation"]

MNIST_activation_gen_dir = {
    "1_Hidden": activation_1,
    "2_Hidden": activation_2
}
#np.save(Directory + "Activation_MNIST.npy", MNIST_activation_gen_dir)

figdir = "/Volumes/backupdisc/Modular_learning/Plots_MNIST"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

mean_accuracy_1 = np.mean(np.mean(accuracy_1,4),2)*100
std_accuracy_1 = np.std(np.mean(accuracy_1,4), axis = 2)*100
ci_accuracy_1 = 1.96*std_accuracy_1#/np.sqrt(Rep)

mean_accuracy_2 = np.mean(np.mean(accuracy_2,4),2)*100
std_accuracy_2 = np.std(np.mean(accuracy_2,4), axis = 2)*100
ci_accuracy_2 = 1.96*std_accuracy_2#/np.sqrt(Rep)

MNIST_accuracy_gen_dir = {
    "1_Hidden_mean": mean_accuracy_1,
    "1_Hidden_ci": ci_accuracy_1,
    "2_Hidden_mean": mean_accuracy_2,
    "2_Hidden_ci": ci_accuracy_2
}
#np.save(Directory + "Accuracy_gen_MNIST.npy", MNIST_accuracy_gen_dir)

os.chdir(figdir)
fig, axs = plt.subplots(2, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(mean_accuracy_1[m,:,:],1),np.mean(ci_accuracy_1[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,0].errorbar(np.arange(1, nContexts+1), np.mean(mean_accuracy_1[m,:,:],0),np.mean(ci_accuracy_1[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(mean_accuracy_2[m,:,:],1),np.mean(ci_accuracy_2[m,:,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1,1].errorbar(np.arange(1, nContexts+1), np.mean(mean_accuracy_2[m,:,:],0),np.mean(ci_accuracy_2[m,:,:],0), lw = 2, color=color_values[m], label =model_labels[m])

axs[0,0].set_title("One hidden layer", fontsize=9, fontweight="bold")
axs[0,1].set_title("Two hidden layers", fontsize=9, fontweight="bold")

axs[0,0].set_xlabel("\u03B1", fontsize=9)
axs[0,0].set_xticks(np.arange(0,0.11,.02))
axs[0,1].set_xlabel("\u03B1", fontsize=9)
axs[0,1].set_xticks(np.arange(0,0.11,.02))
axs[1,0].set_xlabel("Context", fontsize=9)
axs[1,0].set_xticks(np.arange(1,7))
axs[1,0].set_xticklabels(["odd","even",">5","<5",">3", "<7"], fontsize=9)
axs[1,1].set_xlabel("Context", fontsize=9)
axs[1,1].set_xticks(np.arange(1,7))
axs[1,1].set_xticklabels(["odd","even",">5","<5",">3", "<7"], fontsize=9)
axs[0,0].set_ylabel("Accuracy %", fontsize=9)
axs[1,0].set_ylabel("Accuracy %", fontsize=9)

for i in range(2):
    for i2 in range(2):
        axs[i,i2].spines['right'].set_visible(False)
        axs[i,i2].spines['top'].set_visible(False)

fig.text(0.01, 0.7, 'For each \u03B1', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")
fig.text(0.01, 0.275, 'For each context', va='center', rotation='vertical', fontsize = 9, fontweight = "bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.subplots_adjust(left = .15, right=.85)
fig.legend(handles, labels, loc="center right", title = "Gating")

fig.set_size_inches(15/2.54,12/2.54)
#plt.savefig("Accuracy_Generalization.png", dpi = 300)
#plt.show()

nLabels = 10

Overlap_all_1 = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nLabels))
Overlap_all_2 = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nLabels))
Overlap_layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nLabels))
Overlap_layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts, nLabels))
for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_all_1[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_1[:,:,:,:,c1,:] - activation_1[:,:,:,:,c2,:])**2, axis = 3))/401
        Overlap_all_2[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,:,c1,:] - activation_2[:,:,:,:,c2,:])**2, axis = 3))/402
        Overlap_layer1[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,::301,c1,:] - activation_2[:,:,:,::301,c2,:])**2, axis = 3))/301
        Overlap_layer2[:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,301::,c1,:] - activation_2[:,:,:,301::,c2,:])**2, axis = 3))/101

Overlap_all1_average = np.mean(Overlap_all_1,5)
Overlap_all2_average = np.mean(Overlap_all_2,5)
Overlap_layer1_average = np.mean(Overlap_layer1,5)
Overlap_layer2_average = np.mean(Overlap_layer2,5)

Correlation_all_1 = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_all_2 = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_layer1 = np.zeros((len(Models), len(learning_rates), Rep))
Correlation_layer2 = np.zeros((len(Models), len(learning_rates), Rep))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            actual_all_1 = np.reshape(Overlap_all1_average[m,l,r,:,:], (-1))
            actual_all_2 = np.reshape(Overlap_all2_average[m,l,r,:,:], (-1))
            actual_layer1 = np.reshape(Overlap_layer1_average[m,l,r,:,:], (-1))
            actual_layer2 = np.reshape(Overlap_layer2_average[m,l,r,:,:], (-1))
            target_1 = np.reshape(target_overlap_1[m,l,r,:,:], (-1))
            target_2 = np.reshape(target_overlap_2[m,l,r,:,:], (-1))
            Correlation_all_1[m,l,r] = stats.spearmanr(actual_all_1, target_1)[0]
            Correlation_all_2[m,l,r] = stats.spearmanr(actual_all_2, target_2)[0]
            Correlation_layer1[m,l,r] = stats.spearmanr(actual_layer1, target_2)[0]
            Correlation_layer2[m,l,r] = stats.spearmanr(actual_layer2, target_2)[0]

Correlation_all1_mean = np.mean(Correlation_all_1,2)
Correlation_all2_mean = np.mean(Correlation_all_2,2)
Correlation_layer1_mean = np.mean(Correlation_layer1,2)
Correlation_layer2_mean = np.mean(Correlation_layer2,2)

Correlation_all1_ci = 1.96*np.std(Correlation_all_1,2)#/np.sqrt(Rep)
Correlation_all2_ci = 1.96*np.std(Correlation_all_2,2)#/np.sqrt(Rep)
Correlation_layer1_ci = 1.96*np.std(Correlation_layer1,2)#/np.sqrt(Rep)
Correlation_layer2_ci = 1.96*np.std(Correlation_layer2,2)#/np.sqrt(Rep)

MNIST_RDM_gen_dir = {
    "1_Hidden_mean": Correlation_all1_mean,
    "1_Hidden_ci": Correlation_all1_ci,
    "2_Hidden_mean": Correlation_all2_mean,
    "2_Hidden_ci": Correlation_all2_ci,
    "2_1_Hidden_mean": Correlation_layer1_mean,
    "2_1_Hidden_ci": Correlation_layer1_ci,
    "2_2_Hidden_mean": Correlation_layer2_mean,
    "2_2_Hidden_ci": Correlation_layer2_ci
}
np.save(Directory + "RDM_gen_MNIST_2.npy", MNIST_RDM_gen_dir)

fig, axs = plt.subplots(2, 2, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, Correlation_all1_mean[m,:],  Correlation_all1_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates, Correlation_all2_mean[m,:],  Correlation_all2_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(learning_rates, Correlation_layer1_mean[m,:],  Correlation_layer1_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(learning_rates, Correlation_layer2_mean[m,:],  Correlation_layer2_ci[m,:], lw = 2, color=color_values[m], label=model_labels[m])


axs[1,0].set_xlabel("\u03B1", fontsize=9)
axs[1,0].set_xticks(np.arange(0,0.11,.02))
axs[1,1].set_xlabel("\u03B1", fontsize=9)
axs[1,1].set_xticks(np.arange(0,0.11,.02))

for i in range(2):
    for i2 in range(2):
        axs[i,i2].spines['top'].set_visible(False)
        axs[i,i2].spines['right'].set_visible(False)

axs[0,0].set_ylabel("Representation", fontsize=9)
axs[1,0].set_ylabel("Representation", fontsize=9)

axs[0,0].set_title("One hidden layer", fontsize=9, fontweight="bold")
axs[0,1].set_title("Two hidden layers", fontsize=9, fontweight="bold")
axs[1,0].set_title("Hidden layer 1 of 2", fontsize=9, fontweight="bold")
axs[1,1].set_title("Hidden layer 2 of 2", fontsize=9, fontweight="bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,12/2.54)
#plt.savefig("RDM_generalization.png", dpi = 300)
#plt.show()

from sklearn.decomposition import PCA
p = PCA(n_components = 2)

rate = 5
repid = np.random.randint(0,Rep)

pca_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nContexts,nLabels))
pca_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nContexts,nLabels))
pca_2_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nContexts,nLabels))
pca_2_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nContexts,nLabels))

pca_1_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))
pca_2_explained = np.zeros((len(Models),len(learning_rates),Rep, 2))

contexts=["odd","even",">5","<5",">3","<7"]
color_bis = ["c", "m", "y", "b","k",'r']

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_1 = np.transpose(np.reshape(activation_1[m,lr,r,:,:,:],(401,-1)))
            data_2 = np.transpose(np.reshape(activation_2[m,lr,r,:,:,:],(402,-1)))
            data_2_1 = data_2[:,::301]
            data_2_2 = data_2[:,301::]

            pca_1[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_1)),(2,nContexts,nLabels))
            PCA(n_components = 2)
            pca_1_explained[m,lr,r,:]=p.explained_variance_ratio_

            pca_2[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2)),(2,nContexts,nLabels))
            PCA(n_components = 2)
            pca_2_explained[m,lr,r,:]=p.explained_variance_ratio_

            pca_2_1[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_1)),(2,nContexts,nLabels))
            pca_2_2[m,lr,r,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_2)),(2,nContexts,nLabels))

print(np.mean(np.reshape(np.sum(pca_1_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_1_explained,3),-1)))
print(np.mean(np.reshape(np.sum(pca_2_explained,3),-1)))
print(np.std(np.reshape(np.sum(pca_2_explained,3),-1)))

MNIST_pca_gen_dir = {
    "1_Hidden": pca_1,
    "2_Hidden": pca_2,
    "2_1_Hidden": pca_2_1,
    "2_2_Hidden": pca_2_2,
}
#np.save(Directory + "PCA_gen_MNIST.npy", MNIST_pca_gen_dir)
