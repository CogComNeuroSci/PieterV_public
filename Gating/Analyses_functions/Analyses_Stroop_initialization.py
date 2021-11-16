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
                data = np.load(Directory + "/Stroop/"+ m +"/"+ method+ "_lr_{:.1f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)
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
    for i in ["normal", "uniform"]:
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
for i in ["normal", "uniform"]:
    data_dict[i] = np.load(Directory+"all_data_Stroop_"+i+".npy", allow_pickle = True)

order_normal = data_dict["normal"][()]["order"]
order_uniform = data_dict["uniform"][()]["order"]

target_overlap_normal = data_dict["normal"][()]["target_overlap"]
target_overlap_uniform = data_dict["uniform"][()]["target_overlap"]

accuracy_normal = data_dict["normal"][()]["accuracy"]
accuracy_uniform = data_dict["uniform"][()]["accuracy"]

activation_normal = data_dict["normal"][()]["activation"]
activation_uniform = data_dict["uniform"][()]["activation"]

criterion_normal = data_dict["normal"][()]["criterion"]
criterion_uniform = data_dict["uniform"][()]["criterion"]

#Define parameters for figures
figdir = "/Volumes/backupdisc/Modular_learning/Plots_Stroop/Revision/initialize/"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

#Accuracy analyses
mean_accuracy_normal = np.mean(np.mean(accuracy_normal,5),2)*100
std_accuracy_normal = np.std(np.mean(accuracy_normal,5), axis = 2)*100
ci_accuracy_normal = 1.96*std_accuracy_normal/np.sqrt(Rep)

mean_accuracy_uniform = np.mean(np.mean(accuracy_uniform,5),2)*100
std_accuracy_uniform = np.std(np.mean(accuracy_uniform,5), axis = 2)*100
ci_accuracy_uniform = 1.96*std_accuracy_uniform/np.sqrt(Rep)

reshaped_mean_acc_normal = np.reshape(mean_accuracy_normal,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_normal = np.reshape(ci_accuracy_normal,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_uniform = np.reshape(mean_accuracy_uniform,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_uniform = np.reshape(ci_accuracy_uniform,(len(Models), len(learning_rates), nRepeats * nContexts))

extra_averaged_accuracy_normal = np.mean(reshaped_mean_acc_normal,2)
extra_ci_accuracy_normal = np.mean(reshaped_ci_acc_normal,2)

extra_averaged_accuracy_uniform = np.mean(reshaped_mean_acc_uniform,2)
extra_ci_accuracy_uniform = np.mean(reshaped_ci_acc_uniform,2)

#save results of analyses
Stroop_accuracy_train_dir = {
    "normal_mean": np.mean(mean_accuracy_normal,3),
    "normal_ci": np.mean(ci_accuracy_normal,3),
    "uniform_mean": np.mean(mean_accuracy_uniform,3),
    "uniform_ci": np.mean(ci_accuracy_uniform,3)
}
np.save(Directory + "Accuracy_train_Stroop.npy", Stroop_accuracy_train_dir)

#Make figure
os.chdir(figdir)
fig, axs = plt.subplots(1,2, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, extra_averaged_accuracy_normal[m,:],extra_ci_accuracy_normal[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, extra_averaged_accuracy_uniform[m,:],extra_ci_accuracy_uniform[m,:], lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("normal initialization", fontsize = 9, fontweight="bold")
axs[1].set_title("uniform initialization", fontsize = 9, fontweight="bold")

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
        axs[i,0].errorbar(np.arange(1,16), reshaped_mean_acc_normal[m,i+1,:], reshaped_ci_acc_normal[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,1].errorbar(np.arange(1,16), reshaped_mean_acc_uniform[m,i+1,:], reshaped_ci_acc_uniform[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
    for i2 in range(2):
        axs[i,i2].spines['top'].set_visible(False)
        axs[i,i2].spines['right'].set_visible(False)
        axs[2,i2].set_xticks(np.arange(1,16))
        axs[2,i2].set_xticklabels(np.tile(["A","B","C","D","E"],3), fontsize = 9)
        axs[2,i2].set_xlabel("Context", fontsize = 9)

    axs[i,0].set_ylabel("Accuracy %", fontsize = 9)

axs[0,0].set_title("normal initialization", fontsize = 9, fontweight="bold")
axs[0,1].set_title("uniform initialization", fontsize = 9, fontweight="bold")

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

mean_criterion_normal = np.mean(criterion_normal,2)
ci_criterion_normal = 1.96*np.std(criterion_normal, axis = 2)

mean_criterion_uniform = np.mean(criterion_uniform,2)
ci_criterion_uniform = 1.96*np.std(criterion_uniform, axis = 2)

#save results of analyses
Stroop_criterion_train_dir = {
    "normal_mean": mean_criterion_normal,
    "normal_ci": ci_criterion_normal,
    "uniform_mean": mean_criterion_uniform,
    "uniform_ci": ci_criterion_uniform
}
np.save(Directory + "Criterion_train_Stroop.npy", Stroop_criterion_train_dir)

print(np.shape(mean_criterion_normal))
fig, axs = plt.subplots(1,2, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, np.mean(mean_criterion_normal[m,:,0,:],1), np.mean(ci_criterion_normal[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, np.mean(mean_criterion_uniform[m,:,0,:],1), np.mean(ci_criterion_uniform[m,:,0,:],1), lw = 2, color=color_values[m], label =model_labels[m])

plt.title("Model performance on Stroop task")
axs[0].set_title("normal initialization", fontsize = 9, fontweight="bold")
axs[1].set_title("uniform initialization", fontsize = 9, fontweight="bold")

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
Overlap_normal = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))
Overlap_uniform =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nPatterns))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_normal[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_normal[:,:,:,:,:,c1,:] - activation_normal[:,:,:,:,:,c2,:])**2, axis = 3))/13
        Overlap_uniform[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_uniform[:,:,:,:,:,c1,:] - activation_uniform[:,:,:,:,:,c2,:])**2, axis = 3))/13

Overlap_normal_average = np.mean(Overlap_normal,6)
Overlap_uniform_average = np.mean(Overlap_uniform,6)

#Correlate this with objective overlap between contexts
Correlation_normal = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_uniform = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            for nr in range(nRepeats):
                actual_normal = np.reshape(Overlap_normal_average[m,l,r,nr,:,:], (-1))
                actual_uniform= np.reshape(Overlap_uniform_average[m,l,r,nr,:,:], (-1))
                target_normal = np.reshape(target_overlap_normal[m,l,r,:,:], (-1))
                target_uniform = np.reshape(target_overlap_uniform[m,l,r,:,:], (-1))
                Correlation_normal[m,l,r,nr] = stats.spearmanr(actual_normal, target_normal)[0]
                Correlation_uniform[m,l,r,nr] = stats.spearmanr(actual_uniform, target_uniform)[0]

Correlation_normal_mean = np.mean(Correlation_normal,2)
Correlation_uniform_mean = np.mean(Correlation_uniform,2)

Correlation_normal_ci = 1.96*np.std(Correlation_normal,2)/np.sqrt(Rep)
Correlation_uniform_ci = 1.96*np.std(Correlation_uniform,2)/np.sqrt(Rep)

#save results of analyses
Stroop_RDM_train_dir = {
    "normal_mean": np.mean(Correlation_normal_mean,1),
    "normal_ci": np.mean(Correlation_normal_ci,1),
    "24_Hidden_mean": np.mean(Correlation_uniform_mean,1),
    "24_Hidden_ci": np.mean(Correlation_uniform_ci,1)
}
np.save(Directory + "RDM_train_Stroop.npy", Stroop_RDM_train_dir)

#Make figures
fig, axs = plt.subplots(2, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(Correlation_normal_mean[m,:,:],1),  np.mean(Correlation_normal_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[0,1].errorbar(learning_rates, np.mean(Correlation_uniform_mean[m,:,:],1),  np.mean(Correlation_uniform_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])

    axs[1,0].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_normal_mean[m,:,:],0),  np.mean(Correlation_normal_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_uniform_mean[m,:,:],0),  np.mean(Correlation_uniform_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])

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

axs[0,0].set_title("normal initialization", fontsize = 9, fontweight="bold")
axs[0,1].set_title("uniform initialization", fontsize = 9, fontweight="bold")
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

pca_normal = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))
pca_uniform = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nPatterns))

contexts=["A","B","C","D","E"]
color_bis = ["c", "m", "y", "b","k"]

rate = 5
repid = np.random.randint(0,Rep)
print(repid)

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_normal = np.transpose(np.reshape(activation_normal[m,lr,r,:,:,:,:],(13,-1)))
            data_uniform = np.transpose(np.reshape(activation_uniform[m,lr,r,:,:,:,:],(13,-1)))

            pca_normal[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_normal)),(2,nRepeats,nContexts,nPatterns))
            pca_uniform[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_uniform)),(2,nRepeats,nContexts,nPatterns))

#Save analyses results
Stroop_pca_train_dir = {
    "normal": pca_normal,
    "uniform": pca_uniform
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
            axs[m,r].plot(pca_normal[m,rate,repid,0,r,i,:], pca_normal[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
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
plt.savefig("try_pcanormal.png", dpi=300)
plt.show()

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_uniform[m,rate,repid,0,r,i,:], pca_uniform[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
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
plt.savefig("try_pcauniform.png", dpi=300)
plt.show()
