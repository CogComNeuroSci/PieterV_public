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
nContexts= 5
nRepeats= 3
nPatterns = 18

#If you run script for the first time, set this on False
loaded = False

#Function to load data
def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/", learning_rates= np.arange(0,1.1,0.2), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], resources = 12, nContexts= 5, nRepeats= 3, nPatterns = 18, method = "conc"):

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
                data = np.load(Directory + method + "/Stroop/"+ m +"/lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)
                print([i, i2, r])
                Contextorder[i,i2,r,:] = data[()]["Contextorder"]
                Overlap[i,i2,r,:,:] = data[()]["Overlap"]
                Criterion[i,i2,r,:,:]=data[()]["Criterion"]

                for n in range(nPatterns):
                    id1 = data[()]["Presented"][0,0:450]==n
                    for c in range(nContexts):
                        id2 = data[()]["Contextorder"]==c
                        Accuracy_labeled[i,i2,r,:,c,n]= np.mean(data[()]["Accuracy"][:,id2,id1],1)
                        Activation_labeled[i,i2,r,:,:,c,n]=np.mean(data[()]["Activation"][:,:,id2,id1],2)

    return Contextorder, Overlap, Accuracy_labeled, Activation_labeled, Criterion

#If data was not loaded before, do it now and save
if not loaded:
    for i in ["conc", "sep"]:
        order, target_overlap, accuracy, activation, criterion = load_data(method = i)
        new_dict = {
            "order": order,
            "target_overlap": target_overlap,
            "accuracy": accuracy,
            "activation": activation,
            "criterion": criterion
            }
        np.save(Directory+"all_data_Stroop_"+i+".npy", new_dict)

#Now extract the loaded data
data_dict = {}
for i in ["conc", "sep"]:
    data_dict[i] = np.load(Directory+"all_data_Stroop_"+i+".npy", allow_pickle = True)

order_conc = data_dict["conc"][()]["order"]
order_sep = data_dict["sep"][()]["order"]

target_overlap_conc = data_dict["conc"][()]["target_overlap"]
target_overlap_sep = data_dict["sep"][()]["target_overlap"]

accuracy_conc = data_dict["conc"][()]["accuracy"]
accuracy_sep = data_dict["sep"][()]["accuracy"]

activation_conc = data_dict["conc"][()]["activation"]
activation_sep = data_dict["sep"][()]["activation"]

criterion_conc = data_dict["conc"][()]["criterion"]
criterion_sep = data_dict["sep"][()]["criterion"]

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Stroop/Revision/consep/"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

#Accuracy analyses
mean_accuracy_conc = np.mean(np.mean(accuracy_conc,5),2)*100
std_accuracy_conc = np.std(np.mean(accuracy_conc,5), axis = 2)*100
ci_accuracy_conc = 1.96*std_accuracy_conc/np.sqrt(Rep)

mean_accuracy_sep = np.mean(np.mean(accuracy_sep,5),2)*100
std_accuracy_sep = np.std(np.mean(accuracy_sep,5), axis = 2)*100
ci_accuracy_sep = 1.96*std_accuracy_sep/np.sqrt(Rep)

reshaped_mean_acc_conc = np.reshape(mean_accuracy_conc,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_conc = np.reshape(ci_accuracy_conc,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_sep = np.reshape(mean_accuracy_sep,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_sep = np.reshape(ci_accuracy_sep,(len(Models), len(learning_rates), nRepeats * nContexts))

extra_averaged_accuracy_conc = np.mean(reshaped_mean_acc_conc,2)
extra_ci_accuracy_conc = np.mean(reshaped_ci_acc_conc,2)

extra_averaged_accuracy_sep = np.mean(reshaped_mean_acc_sep,2)
extra_ci_accuracy_sep = np.mean(reshaped_ci_acc_sep,2)

#save results of analyses
Stroop_accuracy_train_dir = {
    "conc_mean": np.mean(mean_accuracy_conc,3),
    "conc_ci": np.mean(ci_accuracy_conc,3),
    "sep_mean": np.mean(mean_accuracy_sep,3),
    "sep_ci": np.mean(ci_accuracy_sep,3)
}
np.save(Directory + "Accuracy_train_Stroop.npy", Stroop_accuracy_train_dir)

#Make figure
os.chdir(figdir)
fig, axs = plt.subplots(1,2, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, extra_averaged_accuracy_conc[m,:],extra_ci_accuracy_conc[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, extra_averaged_accuracy_sep[m,:],extra_ci_accuracy_sep[m,:], lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("Concatenated activation", fontsize = 9, fontweight="bold")
axs[1].set_title("Separated activation", fontsize = 9, fontweight="bold")

axs[0].set_xlabel("\u03B1", fontsize = 9)
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xlabel("\u03B1", fontsize = 9)
axs[1].set_xticks(np.arange(0,1.1,.2))

axs[0].set_ylabel("Accuracy %", fontsize = 9)

axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,6/2.54)
plt.savefig("Accuracy_averaged.png", dpi = 300)
plt.show()

fig, axs = plt.subplots(3,2, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(3):
    for m in range(len(Models)):
        axs[i,0].errorbar(np.arange(1,16), reshaped_mean_acc_conc[m,i+1,:], reshaped_ci_acc_conc[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,1].errorbar(np.arange(1,16), reshaped_mean_acc_sep[m,i+1,:], reshaped_ci_acc_sep[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
    for i2 in range(2):
        axs[i,i2].spines['top'].set_visible(False)
        axs[i,i2].spines['right'].set_visible(False)
        axs[2,i2].set_xticks(np.arange(1,16))
        axs[2,i2].set_xticklabels(np.tile(["A","B","C","D","E"],3), fontsize = 9)
        axs[2,i2].set_xlabel("Context", fontsize = 9)

    axs[i,0].set_ylabel("Accuracy %", fontsize = 9)

axs[0,0].set_title("Concatenated activation", fontsize = 9, fontweight="bold")
axs[0,1].set_title("Separated activation", fontsize = 9, fontweight="bold")

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

mean_criterion_conc = np.mean(criterion_conc,2)
ci_criterion_conc = 1.96*np.std(criterion_conc, axis = 2)

mean_criterion_sep = np.mean(criterion_sep,2)
ci_criterion_sep = 1.96*np.std(criterion_sep, axis = 2)

#save results of analyses
Stroop_criterion_train_dir = {
    "conc_mean": mean_criterion_conc,
    "conc_ci": ci_criterion_conc,
    "sep_mean": mean_criterion_sep,
    "sep_ci": ci_criterion_sep
}
np.save(Directory + "Criterion_train_Stroop.npy", Stroop_criterion_train_dir)

print(np.shape(mean_criterion_conc))
fig, axs = plt.subplots(1,2, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, np.mean(mean_criterion_conc[m,:,0,:],1), np.mean(ci_criterion_conc[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, np.mean(mean_criterion_sep[m,:,0,:],1), np.mean(ci_criterion_sep[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("Concatenated activation", fontsize = 9, fontweight="bold")
axs[1].set_title("Separated activation", fontsize = 9, fontweight="bold")

axs[0].set_xlabel("\u03B1", fontsize = 9)
axs[0].set_xticks(np.arange(0,1.1,.2))
axs[1].set_xlabel("\u03B1", fontsize = 9)
axs[1].set_xticks(np.arange(0,1.1,.2))

axs[0].set_ylabel("Trials-to-criterion", fontsize = 9)

axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(right=.85)
fig.set_size_inches(15/2.54,6/2.54)
plt.savefig("Criterion_averaged.png", dpi = 300)
plt.show()

#Compute overlap in network activation
from scipy import stats
Overlap_conc = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))
Overlap_sep =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_conc[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_conc[:,:,:,:,:,c1,:] - activation_conc[:,:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_sep[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_sep[:,:,:,:,:,c1,:] - activation_sep[:,:,:,:,:,c2,:])**2, axis = 3))/13

Overlap_conc_average = np.mean(Overlap_conc,6)
Overlap_sep_average = np.mean(Overlap_sep,6)

#Correlate this with objective overlap between contexts
Correlation_conc = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_sep = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            for nr in range(nRepeats):
                actual_conc = np.reshape(Overlap_conc_average[m,l,r,nr,:,:], (-1))
                actual_sep= np.reshape(Overlap_sep_average[m,l,r,nr,:,:], (-1))
                target_conc = np.reshape(target_overlap_conc[m,l,r,:,:], (-1))
                target_sep = np.reshape(target_overlap_sep[m,l,r,:,:], (-1))
                Correlation_conc[m,l,r,nr] = stats.spearmanr(actual_conc, target_conc)[0]
                Correlation_sep[m,l,r,nr] = stats.spearmanr(actual_sep, target_sep)[0]

Correlation_conc_mean = np.mean(Correlation_conc,2)
Correlation_sep_mean = np.mean(Correlation_sep,2)

Correlation_conc_ci = 1.96*np.std(Correlation_conc,2)/np.sqrt(Rep)
Correlation_sep_ci = 1.96*np.std(Correlation_sep,2)/np.sqrt(Rep)

#save results of analyses
Stroop_RDM_train_dir = {
    "conc_mean": np.mean(Correlation_conc_mean,1),
    "conc_ci": np.mean(Correlation_conc_ci,1),
    "sep_mean": np.mean(Correlation_sep_mean,1),
    "sep_ci": np.mean(Correlation_sep_ci,1)
}
np.save(Directory + "RDM_train_Stroop.npy", Stroop_RDM_train_dir)

#Make figures
fig, axs = plt.subplots(2, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(Correlation_conc_mean[m,:,:],1),  np.mean(Correlation_conc_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(Correlation_sep_mean[m,:,:],1),  np.mean(Correlation_sep_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])

    axs[1,0].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_conc_mean[m,:,:],0),  np.mean(Correlation_conc_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_sep_mean[m,:,:],0),  np.mean(Correlation_sep_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])

for i in range(2):
    axs[0,i].set_xlabel("\u03B1", fontsize = 9)
    axs[0,i].set_xticks(np.arange(0,1.1,.2))
    axs[1,i].set_xlabel("Context repeats", fontsize = 9)
    axs[1,i].set_xticks(np.arange(1,4,1))
    for i2 in range(2):
        axs[i2,i].spines['top'].set_visible(False)
        axs[i2,i].spines['right'].set_visible(False)

axs[0,0].set_ylabel("Representation", fontsize = 9)
axs[1,0].set_ylabel("Representation", fontsize = 9)

axs[0,0].set_title("Concatenated activation", fontsize = 9, fontweight="bold")
axs[0,1].set_title("Separated activation", fontsize = 9, fontweight="bold")
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

pca_conc = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))
pca_sep = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))

contexts=["A","B","C","D","E"]
color_bis = ["c", "m", "y", "b","k"]

rate = 5
repid = np.random.randint(0,Rep)
print(repid)

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_conc = np.transpose(np.reshape(activation_conc[m,lr,r,:,:,:,:],(13,-1)))
            data_sep = np.transpose(np.reshape(activation_sep[m,lr,r,:,:,:,:],(13,-1)))

            pca_conc[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_conc)),(2,nRepeats,nContexts,nPatterns))
            pca_sep[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_sep)),(2,nRepeats,nContexts,nPatterns))

#Save analyses results
Stroop_pca_train_dir = {
    "conc": pca_conc,
    "sep": pca_sep
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
            axs[m,r].plot(pca_conc[m,rate,repid,0,r,i,:], pca_conc[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
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
plt.savefig("try_pcaconc.png", dpi=300)
plt.show()

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_sep[m,rate,repid,0,r,i,:], pca_sep[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
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
plt.savefig("try_pcasep.png", dpi=300)
plt.show()
