import numpy as np
from matplotlib import pyplot as plt
import os

Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/"
learning_rates= np.arange(0,0.11,0.02)
Rep= 25
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 6
nRepeats= 3

loaded = True

def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/", learning_rates= np.arange(0,0.11,0.02), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], nContexts= 6, nRepeats= 3, layers=2):
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, 10))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, 400+layers, nRepeats, nContexts, 10))
    Contextorder = np.zeros((len(Models), len(learning_rates), Rep, nContexts))
    Overlap = np.zeros((len(Models), len(learning_rates), Rep, nContexts, nContexts))
    Labels = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, int(np.round((0.2/3)*60000))))

    i = -1
    for m in Models:
        i+=1
        i2 =-1
        for lr in learning_rates:
            i2+=1
            for r in range(Rep):
                data = np.load(Directory + m + "/lr_{:.2f}_Rep_{:d}.npy".format(lr, r), allow_pickle = True)
                print([i, i2, r])
                Contextorder[i,i2,r,:] = data[()]["Contextorder"]
                Overlap[i,i2,r,:,:] = data[()]["Overlap"]
                if "Presented_numbers" in data[()]:
                    data[()]["Presented"] = data[()]["Presented_numbers"]
                Labels[i,i2,r,:,:] = data[()]["Presented"]
                for n in np.unique(data[()]["Presented"]):
                    for r2 in range(nRepeats):
                        id1 = data[()]["Presented"][r2,:]==n
                        for c in range(nContexts):
                            id2 = data[()]["Contextorder"]==c
                            Accuracy_labeled[i,i2,r,r2,:,n]=np.mean(data[()]["Accuracy"][r2,id2,id1])
                            Activation_labeled[i,i2,r,:,r2,c,n]=np.mean(data[()]["Activation"][:,r2,id2,id1],1)


    return Contextorder, Overlap, Labels, Accuracy_labeled, Activation_labeled


if not loaded:
    for layer in range(3):
        if layer ==0:
            Dir = Directory + 'onelayer/'
        elif layer == 1:
            Dir = Directory + 'twolayer/'
        else:
            Dir = Directory + 'threelayer/'

        order, target_overlap, labels, accuracy, activation = load_data(Directory = Dir, layers = layer+1)
        new_dict = {
            "order": order,
            "target_overlap": target_overlap,
            "labels": labels,
            "accuracy": accuracy,
            "activation": activation
            }
        np.save(Dir+"all_data.npy", new_dict)

data_dict = {}
for layer in range(3):
    if layer ==0:
        Dir = Directory + 'onelayer/'
    elif layer == 1:
        Dir = Directory + 'twolayer/'
    else:
        Dir = Directory + 'threelayer/'

    data_dict[str(layer)] = np.load(Dir+"all_data.npy", allow_pickle = True)

order_1 = data_dict["0"][()]["order"]
order_2 = data_dict["1"][()]["order"]
order_3 = data_dict["2"][()]["order"]

target_overlap_1 = data_dict["0"][()]["target_overlap"]
target_overlap_2 = data_dict["1"][()]["target_overlap"]
target_overlap_3 = data_dict["2"][()]["target_overlap"]

accuracy_1 = data_dict["0"][()]["accuracy"]
accuracy_2 = data_dict["1"][()]["accuracy"]
accuracy_3 = data_dict["2"][()]["accuracy"]

activation_1 = data_dict["0"][()]["activation"]
activation_2 = data_dict["1"][()]["activation"]
activation_3 = data_dict["2"][()]["activation"]

figdir = "/Volumes/backupdisc/Modular_learning/Plots_MNIST/Revision"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

mean_accuracy_1 = np.mean(np.mean(accuracy_1,5),2)*100
std_accuracy_1 = np.std(np.mean(accuracy_1,5), axis = 2)*100
ci_accuracy_1 = 1.96*std_accuracy_1/np.sqrt(Rep)

mean_accuracy_2 = np.mean(np.mean(accuracy_2,5),2)*100
std_accuracy_2 = np.std(np.mean(accuracy_2,5), axis = 2)*100
ci_accuracy_2 = 1.96*std_accuracy_2/np.sqrt(Rep)

mean_accuracy_3 = np.mean(np.mean(accuracy_3,5),2)*100
std_accuracy_3 = np.std(np.mean(accuracy_3,5), axis = 2)*100
ci_accuracy_3 = 1.96*std_accuracy_3/np.sqrt(Rep)

reshaped_mean_acc_1 = np.reshape(mean_accuracy_1,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_1 = np.reshape(ci_accuracy_1,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_2 = np.reshape(mean_accuracy_2,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_2 = np.reshape(ci_accuracy_2,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_3 = np.reshape(mean_accuracy_3,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_3 = np.reshape(ci_accuracy_3,(len(Models), len(learning_rates), nRepeats * nContexts))

extra_averaged_accuracy_1 = np.mean(reshaped_mean_acc_1,2)
extra_ci_accuracy_1 = np.mean(reshaped_ci_acc_1,2)

extra_averaged_accuracy_2 = np.mean(reshaped_mean_acc_2,2)
extra_ci_accuracy_2 = np.mean(reshaped_ci_acc_2,2)

extra_averaged_accuracy_3 = np.mean(reshaped_mean_acc_3,2)
extra_ci_accuracy_3 = np.mean(reshaped_ci_acc_3,2)

MNIST_accuracy_train_dir = {
    "1_Hidden_mean": np.mean(mean_accuracy_1,3),
    "1_Hidden_ci": np.mean(ci_accuracy_1,3),
    "2_Hidden_mean": np.mean(mean_accuracy_2,3),
    "2_Hidden_ci": np.mean(ci_accuracy_2,3),
    "3_Hidden_mean": np.mean(mean_accuracy_3,3),
    "3_Hidden_ci": np.mean(ci_accuracy_3,3)
}
np.save(Directory + "Accuracy_train_MNIST.npy", MNIST_accuracy_train_dir)

os.chdir(figdir)
fig, axs = plt.subplots(1,3, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0].errorbar(learning_rates, extra_averaged_accuracy_1[m,:],extra_ci_accuracy_1[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[1].errorbar(learning_rates, extra_averaged_accuracy_2[m,:],extra_ci_accuracy_2[m,:], lw = 2, color=color_values[m], label =model_labels[m])
    axs[2].errorbar(learning_rates, extra_averaged_accuracy_3[m,:],extra_ci_accuracy_3[m,:], lw = 2, color=color_values[m], label =model_labels[m])

axs[0].spines['right'].set_visible(False)
axs[0].spines['top'].set_visible(False)
axs[1].spines['right'].set_visible(False)
axs[1].spines['top'].set_visible(False)
axs[2].spines['right'].set_visible(False)
axs[2].spines['top'].set_visible(False)

axs[0].set_xlabel("\u03B1", fontsize=9)
axs[0].set_xticks(np.arange(0,0.11,.02))
axs[0].set_ylabel("Accuracy %", fontsize=9)

axs[0].set_title("One hidden layer", fontsize=9, fontweight="bold")
axs[1].set_title("Two hidden layers", fontsize=9, fontweight="bold")
axs[2].set_title("Three hidden layers", fontsize=9, fontweight="bold")

axs[1].set_xlabel("\u03B1", fontsize=9)
axs[1].set_xticks(np.arange(0,0.11,.02))

axs[2].set_xlabel("\u03B1", fontsize=9)
axs[2].set_xticks(np.arange(0,0.11,.02))

handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(bottom = .15, right=.85)
fig.set_size_inches(20/2.54,6/2.54)
plt.savefig("Accuracy_averaged.png", dpi = 300, bbox_inches = "tight")
plt.show()

fig, axs = plt.subplots(3, 3, sharex=True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(3):
    for m in range(len(Models)):
        axs[i,0].errorbar(np.arange(1,19), reshaped_mean_acc_1[m,i+1,:], reshaped_ci_acc_1[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,1].errorbar(np.arange(1,19), reshaped_mean_acc_2[m,i+1,:], reshaped_ci_acc_2[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])
        axs[i,2].errorbar(np.arange(1,19), reshaped_mean_acc_3[m,i+1,:], reshaped_ci_acc_3[m,i+1,:], lw = 2, color=color_values[m], label=model_labels[m])

    axs[i,0].spines['top'].set_visible(False)
    axs[i,0].spines['right'].set_visible(False)
    axs[i,0].set_ylabel("Accuracy %", fontsize=9)
    axs[i,1].spines['top'].set_visible(False)
    axs[i,1].spines['right'].set_visible(False)
    axs[i,2].spines['top'].set_visible(False)
    axs[i,2].spines['right'].set_visible(False)

axs[0,0].set_title("One hidden layer", fontsize=9, fontweight = "bold")
axs[0,1].set_title("Two hidden layers", fontsize=9, fontweight = "bold")
axs[0,2].set_title("Three hidden layers", fontsize=9, fontweight = "bold")

axs[2,0].set_xticks(np.arange(1,19))
axs[2,0].set_xticklabels(np.tile(["odd","even",">5","<5",">3", "<7"],3), fontsize=9)
axs[2,0].set_xlabel("Context", fontsize=9)

axs[2,1].set_xticks(np.arange(1,19))
axs[2,1].set_xticklabels(np.tile(["odd","even",">5","<5",">3", "<7"],3), fontsize=9)
axs[2,1].set_xlabel("Context", fontsize=9)

axs[2,2].set_xticks(np.arange(1,19))
axs[2,2].set_xticklabels(np.tile(["odd","even",">5","<5",">3", "<7"],3), fontsize=9)
axs[2,2].set_xlabel("Context", fontsize=9)

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")

fig.text(0.01, 0.77, '\u03B1 = 0.02', va='center', rotation='vertical', fontsize=9, fontweight = "bold")
fig.text(0.01, 0.5, '\u03B1 = 0.04', va='center', rotation='vertical', fontsize=9, fontweight = "bold")
fig.text(0.01, 0.23, '\u03B1 = 0.06', va='center', rotation='vertical', fontsize=9, fontweight = "bold")

fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,18/2.54)

plt.savefig("Accuracy_contexts.png", dpi = 300)
#plt.show()

nLabels = 10

Overlap_all_1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_all_2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_all_3 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_2layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_2layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_3layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_3layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_3layer3 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_all_1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_1[:,:,:,:,:,c1,:] - activation_1[:,:,:,:,:,c2,:])**2, axis = 3))/401
        Overlap_all_2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,:,:,c1,:] - activation_2[:,:,:,:,:,c2,:])**2, axis = 3))/402
        Overlap_all_3[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,:,:,c1,:] - activation_3[:,:,:,:,:,c2,:])**2, axis = 3))/403

        Overlap_2layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,::301,:,c1,:] - activation_2[:,:,:,::301,:,c2,:])**2, axis = 3))/301
        Overlap_2layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,301::,:,c1,:] - activation_2[:,:,:,301::,:,c2,:])**2, axis = 3))/101

        Overlap_3layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,::201,:,c1,:] - activation_3[:,:,:,::201,:,c2,:])**2, axis = 3))/201
        Overlap_3layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,201:302,:,c1,:] - activation_3[:,:,:,201:302,:,c2,:])**2, axis = 3))/101
        Overlap_3layer3[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,302::,:,c1,:] - activation_3[:,:,:,302::,:,c2,:])**2, axis = 3))/101

Overlap_all1_average = np.mean(Overlap_all_1,6)
Overlap_all2_average = np.mean(Overlap_all_2,6)
Overlap_all3_average = np.mean(Overlap_all_3,6)

Overlap_2layer1_average = np.mean(Overlap_2layer1,6)
Overlap_2layer2_average = np.mean(Overlap_2layer2,6)

Overlap_3layer1_average = np.mean(Overlap_3layer1,6)
Overlap_3layer2_average = np.mean(Overlap_3layer2,6)
Overlap_3layer3_average = np.mean(Overlap_3layer3,6)

Correlation_all_1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_all_2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_all_3 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_2layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_2layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_3layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_3layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_3layer3 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            for nr in range(nRepeats):
                actual_all_1 = np.reshape(Overlap_all1_average[m,l,r,nr,:], (-1))
                actual_all_2 = np.reshape(Overlap_all2_average[m,l,r,nr,:], (-1))
                actual_all_3 = np.reshape(Overlap_all3_average[m,l,r,nr,:], (-1))

                actual_2layer1 = np.reshape(Overlap_2layer1_average[m,l,r,nr,:], (-1))
                actual_2layer2 = np.reshape(Overlap_2layer2_average[m,l,r,nr,:], (-1))

                actual_3layer1 = np.reshape(Overlap_3layer1_average[m,l,r,nr,:], (-1))
                actual_3layer2 = np.reshape(Overlap_3layer2_average[m,l,r,nr,:], (-1))
                actual_3layer3 = np.reshape(Overlap_3layer3_average[m,l,r,nr,:], (-1))

                target_1 = np.reshape(target_overlap_1[m,l,r,:,:], (-1))
                target_2 = np.reshape(target_overlap_2[m,l,r,:,:], (-1))
                target_3 = np.reshape(target_overlap_3[m,l,r,:,:], (-1))

                Correlation_all_1[m,l,r,nr] = np.corrcoef(actual_all_1, target_1)[0,1]
                Correlation_all_2[m,l,r,nr] = np.corrcoef(actual_all_2, target_2)[0,1]
                Correlation_all_3[m,l,r,nr] = np.corrcoef(actual_all_3, target_3)[0,1]

                Correlation_2layer1[m,l,r,nr] = np.corrcoef(actual_2layer1, target_2)[0,1]
                Correlation_2layer2[m,l,r,nr] = np.corrcoef(actual_2layer2, target_2)[0,1]

                Correlation_3layer1[m,l,r,nr] = np.corrcoef(actual_3layer1, target_3)[0,1]
                Correlation_3layer2[m,l,r,nr] = np.corrcoef(actual_3layer2, target_3)[0,1]
                Correlation_3layer3[m,l,r,nr] = np.corrcoef(actual_3layer3, target_3)[0,1]

Correlation_all1_mean = np.mean(Correlation_all_1,2)
Correlation_all2_mean = np.mean(Correlation_all_2,2)
Correlation_all3_mean = np.mean(Correlation_all_3,2)

Correlation_2layer1_mean = np.mean(Correlation_2layer1,2)
Correlation_2layer2_mean = np.mean(Correlation_2layer2,2)

Correlation_3layer1_mean = np.mean(Correlation_3layer1,2)
Correlation_3layer2_mean = np.mean(Correlation_3layer2,2)
Correlation_3layer3_mean = np.mean(Correlation_3layer3,2)

Correlation_all1_ci = 1.96*np.std(Correlation_all_1,2)/np.sqrt(Rep)
Correlation_all2_ci = 1.96*np.std(Correlation_all_2,2)/np.sqrt(Rep)
Correlation_all3_ci = 1.96*np.std(Correlation_all_3,2)/np.sqrt(Rep)

Correlation_2layer1_ci = 1.96*np.std(Correlation_2layer1,2)/np.sqrt(Rep)
Correlation_2layer2_ci = 1.96*np.std(Correlation_2layer2,2)/np.sqrt(Rep)

Correlation_3layer1_ci = 1.96*np.std(Correlation_3layer1,2)/np.sqrt(Rep)
Correlation_3layer2_ci = 1.96*np.std(Correlation_3layer2,2)/np.sqrt(Rep)
Correlation_3layer3_ci = 1.96*np.std(Correlation_3layer3,2)/np.sqrt(Rep)

MNIST_RDM_train_dir = {
    "1_Hidden_mean": np.mean(Correlation_all1_mean,1),
    "1_Hidden_ci": np.mean(Correlation_all1_ci,1),
    "2_Hidden_mean": np.mean(Correlation_all2_mean,1),
    "2_Hidden_ci": np.mean(Correlation_all2_ci,1),
    "3_Hidden_mean": np.mean(Correlation_all3_mean,1),
    "3_Hidden_ci": np.mean(Correlation_all3_ci,1),
    "2_1_Hidden_mean": np.mean(Correlation_2layer1_mean,1),
    "2_1_Hidden_ci": np.mean(Correlation_2layer1_ci,1),
    "2_2_Hidden_mean": np.mean(Correlation_2layer2_mean,1),
    "2_2_Hidden_ci": np.mean(Correlation_2layer2_ci,1),
    "3_1_Hidden_mean": np.mean(Correlation_3layer1_mean,1),
    "3_1_Hidden_ci": np.mean(Correlation_3layer1_ci,1),
    "3_2_Hidden_mean": np.mean(Correlation_3layer2_mean,1),
    "3_2_Hidden_ci": np.mean(Correlation_3layer2_ci,1),
    "3_3_Hidden_mean": np.mean(Correlation_3layer3_mean,1),
    "3_3_Hidden_ci": np.mean(Correlation_3layer3_ci,1)
}
np.save(Directory + "RDM_train_MNIST.npy", MNIST_RDM_train_dir)

fig, axs = plt.subplots(6, 2, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for m in range(len(Models)):
    axs[0,0].errorbar(learning_rates, np.mean(Correlation_all1_mean[m,:,:],1),  np.mean(Correlation_all1_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,0].errorbar(learning_rates, np.mean(Correlation_all2_mean[m,:,:],1),  np.mean(Correlation_all2_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,0].errorbar(learning_rates, np.mean(Correlation_all3_mean[m,:,:],1),  np.mean(Correlation_all3_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,0].errorbar(learning_rates, np.mean(Correlation_3layer1_mean[m,:,:],1),  np.mean(Correlation_3layer1_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[4,0].errorbar(learning_rates, np.mean(Correlation_3layer2_mean[m,:,:],1),  np.mean(Correlation_3layer2_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])
    axs[5,0].errorbar(learning_rates, np.mean(Correlation_3layer3_mean[m,:,:],1),  np.mean(Correlation_3layer3_ci[m,:,:],1), lw = 2, color=color_values[m], label=model_labels[m])

    axs[0,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_all1_mean[m,:,:],0),  np.mean(Correlation_all1_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[1,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_all2_mean[m,:,:],0),  np.mean(Correlation_all2_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[2,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_all3_mean[m,:,:],0),  np.mean(Correlation_all3_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[3,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_3layer1_mean[m,:,:],0),  np.mean(Correlation_3layer1_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[4,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_3layer2_mean[m,:,:],0),  np.mean(Correlation_3layer2_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])
    axs[5,1].errorbar(np.arange(1,nRepeats+1), np.mean(Correlation_3layer3_mean[m,:,:],0),  np.mean(Correlation_3layer3_ci[m,:,:],0), lw = 2, color=color_values[m], label=model_labels[m])

axs[3,0].set_xlabel("\u03B1", fontsize = 9)


axs[3,1].set_xlabel("Context repeats", fontsize = 9)
for i in range(4):
    axs[i,0].set_xticks(np.arange(0,0.11,.02))
    axs[i,1].set_xticks(np.arange(1,4,1))

for i in range(4):
    axs[i,0].set_ylabel("Representation", fontsize=9)
    for i2 in range(2):
        axs[i,i2].spines['top'].set_visible(False)
        axs[i,i2].spines['right'].set_visible(False)

axs[0,0].set_title('For each \u03B1', fontsize=9, fontweight = "bold")
axs[0,1].set_title('For each repetition', fontsize=9, fontweight = "bold")

fig.text(0.01, 0.8, 'One hidden layer', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'Two hidden layers', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'Hidden layer 1 of 2', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'Hidden layer 2 of 2', va='center', rotation='vertical', fontsize = 9, fontweight="bold")

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Gating")
fig.subplots_adjust(left = .15, right=.85)
fig.set_size_inches(15/2.54,18/2.54)
plt.savefig("RDM.png", dpi = 300)
#plt.show()

from sklearn.decomposition import PCA
p = PCA(n_components = 2)

rate = 5
repid = np.random.randint(0,Rep)

pca_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3_3 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))

contexts=["odd","even",">5","<5",">3","<7"]
color_bis = ["c", "m", "y", "b","k",'r']

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_1 = np.transpose(np.reshape(activation_1[m,lr,r,:,:,:,:],(401,-1)))
            data_2 = np.transpose(np.reshape(activation_2[m,lr,r,:,:,:,:],(402,-1)))
            data_3 = np.transpose(np.reshape(activation_3[m,lr,r,:,:,:,:],(403,-1)))

            data_2_1 = data_2[:,::301]
            data_2_2 = data_2[:,301::]

            data_3_1 = data_3[:,::201]
            data_3_2 = data_3[:,201:302]
            data_3_3 = data_3[:,302::]

            pca_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_1)),(2,nRepeats,nContexts,nLabels))
            pca_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2)),(2,nRepeats,nContexts,nLabels))
            pca_3[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3)),(2,nRepeats,nContexts,nLabels))
            pca_2_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_1)),(2,nRepeats,nContexts,nLabels))
            pca_2_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_2)),(2,nRepeats,nContexts,nLabels))
            pca_3_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3_1)),(2,nRepeats,nContexts,nLabels))
            pca_3_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3_2)),(2,nRepeats,nContexts,nLabels))
            pca_3_3[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3_3)),(2,nRepeats,nContexts,nLabels))

MNIST_pca_train_dir = {
    "1_Hidden": pca_1,
    "2_Hidden": pca_2,
    "3_Hidden": pca_3,
    "2_1_Hidden": pca_2_1,
    "2_2_Hidden": pca_2_2,
    "3_1_Hidden": pca_3_1,
    "3_2_Hidden": pca_3_2,
    "3_3_Hidden": pca_3_3,
}
np.save(Directory + "PCA_train_MNIST.npy", MNIST_pca_train_dir)

os.chdir(figdir)
fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

print(np.shape(pca_1))
for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_1[m,rate,repid,0,r,i,:], pca_1[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pca1.png", dpi=300)

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_2[m,rate,repid,0,r,i,:], pca_2[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pca2.png", dpi=300)

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_2_1[m,rate,repid,0,r,i,:], pca_2_1[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pca2l1.png", dpi=300)

fig, axs = plt.subplots(len(Models),nRepeats, sharex = True, sharey=True)
plt.rcParams["font.size"]=9
plt.rcParams["xtick.labelsize"]=9
plt.rcParams["ytick.labelsize"]=9

for i in range(nContexts):
    for m in range(len(Models)):
        for r in range(nRepeats):
            axs[m,r].plot(pca_2_2[m,rate,repid,0,r,i,:], pca_2_2[m,rate,repid,1,r,i,:], 'o', color = color_bis[i], label=contexts[i])
            axs[m,r].set_xlabel("Dimension 1")
            axs[m,r].set_ylabel("Dimension 2")
            axs[0,r].set_title("After {} context repetitions".format(r+1))

handles, labels = axs[0,0].get_legend_handles_labels()
fig.legend(handles, labels, loc="center right", title = "Context")
fig.subplots_adjust(left = .1, right=.85)
fig.set_size_inches(20/2.54,20/2.54)
fig.text(0.01, 0.8, 'Ax', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.6, 'A+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.4, 'Nx', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
fig.text(0.01, 0.2, 'N+', va='center', rotation='vertical', fontsize = 9, fontweight="bold")
plt.savefig("try_pca2l2.png", dpi=300)
