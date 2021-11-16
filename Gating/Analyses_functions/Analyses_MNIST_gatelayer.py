import numpy as np
from matplotlib import pyplot as plt
import os

Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/gatelayer/"
learning_rates= np.arange(0,0.11,0.02)
Rep= 25
Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"]
nContexts= 6
nRepeats= 3

loaded = True

def load_data(Directory = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/gatelayer/", learning_rates= np.arange(0,0.11,0.02), Rep= 25, Models= ["Adaptive_mult", "Non_adaptive_mult", "Adaptive_add", "Non_adaptive_add"], nContexts= 6, nRepeats= 3, gatelayer=1):
    Accuracy_labeled = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, 10))
    Activation_labeled =  np.zeros((len(Models), len(learning_rates), Rep, 402, nRepeats, nContexts, 10))
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
                data = np.load(Directory + m + "/Gat{:d}_lr_{:.2f}_Rep_{:d}.npy".format(gatelayer, lr, r), allow_pickle = True)
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
    for gatelayer in range(4):
        order, target_overlap, labels, accuracy, activation = load_data(Directory = Dir, gatelayer = gatelayer)
        new_dict = {
            "order": order,
            "target_overlap": target_overlap,
            "labels": labels,
            "accuracy": accuracy,
            "activation": activation
            }
        np.save(Dir+"Gat{:d}_all_data.npy".format(gatelayer), new_dict)

data_dict = {}
for gatelayer in range(4):

    data_dict[str(gatelayer)] = np.load(Dir+"Gat{:d}_all_data.npy".format(gatelayer), allow_pickle = True)

order_0 = data_dict["0"][()]["order"]
order_1 = data_dict["1"][()]["order"]
order_2 = data_dict["2"][()]["order"]
order_3 = data_dict["3"][()]["order"]

target_overlap_0 = data_dict["0"][()]["target_overlap"]
target_overlap_1 = data_dict["1"][()]["target_overlap"]
target_overlap_2 = data_dict["2"][()]["target_overlap"]
target_overlap_3 = data_dict["3"][()]["target_overlap"]

accuracy_0 = data_dict["0"][()]["accuracy"]
accuracy_1 = data_dict["1"][()]["accuracy"]
accuracy_2 = data_dict["2"][()]["accuracy"]
accuracy_3 = data_dict["3"][()]["accuracy"]

activation_0 = data_dict["0"][()]["activation"]
activation_1 = data_dict["1"][()]["activation"]
activation_2 = data_dict["2"][()]["activation"]
activation_3 = data_dict["3"][()]["activation"]

figdir = "/Volumes/backupdisc/Modular_learning/Plots_MNIST/Revision"
model_labels=["Ax", "Nx", "A+", "N+"]
color_values = ["b", "gold", "r", "k"]

mean_accuracy_0 = np.mean(np.mean(accuracy_0,5),2)*100
std_accuracy_0 = np.std(np.mean(accuracy_0,5), axis = 2)*100
ci_accuracy_0 = 1.96*std_accuracy_0/np.sqrt(Rep)

mean_accuracy_1 = np.mean(np.mean(accuracy_1,5),2)*100
std_accuracy_1 = np.std(np.mean(accuracy_1,5), axis = 2)*100
ci_accuracy_1 = 1.96*std_accuracy_1/np.sqrt(Rep)

mean_accuracy_2 = np.mean(np.mean(accuracy_2,5),2)*100
std_accuracy_2 = np.std(np.mean(accuracy_2,5), axis = 2)*100
ci_accuracy_2 = 1.96*std_accuracy_2/np.sqrt(Rep)

mean_accuracy_3 = np.mean(np.mean(accuracy_3,5),2)*100
std_accuracy_3 = np.std(np.mean(accuracy_3,5), axis = 2)*100
ci_accuracy_3 = 1.96*std_accuracy_3/np.sqrt(Rep)

reshaped_mean_acc_0 = np.reshape(mean_accuracy_0,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_0 = np.reshape(ci_accuracy_0,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_1 = np.reshape(mean_accuracy_1,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_1 = np.reshape(ci_accuracy_1,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_2 = np.reshape(mean_accuracy_2,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_2 = np.reshape(ci_accuracy_2,(len(Models), len(learning_rates), nRepeats * nContexts))

reshaped_mean_acc_3 = np.reshape(mean_accuracy_3,(len(Models), len(learning_rates), nRepeats * nContexts))
reshaped_ci_acc_3 = np.reshape(ci_accuracy_3,(len(Models), len(learning_rates), nRepeats * nContexts))

extra_averaged_accuracy_0 = np.mean(reshaped_mean_acc_0,2)
extra_ci_accuracy_0 = np.mean(reshaped_ci_acc_0,2)

extra_averaged_accuracy_1 = np.mean(reshaped_mean_acc_1,2)
extra_ci_accuracy_1 = np.mean(reshaped_ci_acc_1,2)

extra_averaged_accuracy_2 = np.mean(reshaped_mean_acc_2,2)
extra_ci_accuracy_2 = np.mean(reshaped_ci_acc_2,2)

extra_averaged_accuracy_3 = np.mean(reshaped_mean_acc_3,2)
extra_ci_accuracy_3 = np.mean(reshaped_ci_acc_3,2)

MNIST_accuracy_train_dir = {
    "0_Hidden_mean": np.mean(mean_accuracy_0,3),
    "0_Hidden_ci": np.mean(ci_accuracy_0,3),
    "1_Hidden_mean": np.mean(mean_accuracy_1,3),
    "1_Hidden_ci": np.mean(ci_accuracy_1,3),
    "2_Hidden_mean": np.mean(mean_accuracy_2,3),
    "2_Hidden_ci": np.mean(ci_accuracy_2,3),
    "3_Hidden_mean": np.mean(mean_accuracy_3,3),
    "3_Hidden_ci": np.mean(ci_accuracy_3,3)
}
np.save(Dir + "Accuracy_train_MNIST.npy", MNIST_accuracy_train_dir)

print("ok")
nLabels = 10

Overlap_all_0 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_all_1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_all_2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_all_3 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_0layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_0layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_1layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_1layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_2layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_2layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

Overlap_3layer1 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))
Overlap_3layer2 =  np.zeros((len(Models), len(learning_rates), Rep, nRepeats, nContexts, nContexts, nLabels))

for c1 in range(nContexts):
    for c2 in range(nContexts):
        Overlap_all_0[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_0[:,:,:,:,:,c1,:] - activation_0[:,:,:,:,:,c2,:])**2, axis = 3))/402
        Overlap_all_1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_1[:,:,:,:,:,c1,:] - activation_1[:,:,:,:,:,c2,:])**2, axis = 3))/402
        Overlap_all_2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,:,:,c1,:] - activation_2[:,:,:,:,:,c2,:])**2, axis = 3))/402
        Overlap_all_3[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,:,:,c1,:] - activation_3[:,:,:,:,:,c2,:])**2, axis = 3))/402

        Overlap_0layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_0[:,:,:,::301,:,c1,:] - activation_0[:,:,:,::301,:,c2,:])**2, axis = 3))/301
        Overlap_0layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_0[:,:,:,301::,:,c1,:] - activation_0[:,:,:,301::,:,c2,:])**2, axis = 3))/101

        Overlap_1layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_1[:,:,:,::301,:,c1,:] - activation_1[:,:,:,::301,:,c2,:])**2, axis = 3))/301
        Overlap_1layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_1[:,:,:,301::,:,c1,:] - activation_1[:,:,:,301::,:,c2,:])**2, axis = 3))/101

        Overlap_2layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,::301,:,c1,:] - activation_2[:,:,:,::301,:,c2,:])**2, axis = 3))/301
        Overlap_2layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_2[:,:,:,301::,:,c1,:] - activation_2[:,:,:,301::,:,c2,:])**2, axis = 3))/101

        Overlap_3layer1[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,::301,:,c1,:] - activation_3[:,:,:,::301,:,c2,:])**2, axis = 3))/301
        Overlap_3layer2[:,:,:,:,c1,c2,:] = np.sqrt(np.sum((activation_3[:,:,:,301::,:,c1,:] - activation_3[:,:,:,301::,:,c2,:])**2, axis = 3))/101

Overlap_all0_average = np.mean(Overlap_all_0,6)
Overlap_all1_average = np.mean(Overlap_all_1,6)
Overlap_all2_average = np.mean(Overlap_all_2,6)
Overlap_all3_average = np.mean(Overlap_all_3,6)

Overlap_0layer1_average = np.mean(Overlap_0layer1,6)
Overlap_0layer2_average = np.mean(Overlap_0layer2,6)

Overlap_1layer1_average = np.mean(Overlap_1layer1,6)
Overlap_1layer2_average = np.mean(Overlap_1layer2,6)

Overlap_2layer1_average = np.mean(Overlap_2layer1,6)
Overlap_2layer2_average = np.mean(Overlap_2layer2,6)

Overlap_3layer1_average = np.mean(Overlap_3layer1,6)
Overlap_3layer2_average = np.mean(Overlap_3layer2,6)

print("ok")

Correlation_all_0 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_all_1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_all_2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_all_3 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_0layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_0layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_1layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_1layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_2layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_2layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

Correlation_3layer1 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))
Correlation_3layer2 = np.zeros((len(Models), len(learning_rates), Rep, nRepeats))

for m in range(len(Models)):
    for l in range(len(learning_rates)):
        for r in range(Rep):
            for nr in range(nRepeats):
                actual_all_0 = np.reshape(Overlap_all0_average[m,l,r,nr,:], (-1))
                actual_all_1 = np.reshape(Overlap_all1_average[m,l,r,nr,:], (-1))
                actual_all_2 = np.reshape(Overlap_all2_average[m,l,r,nr,:], (-1))
                actual_all_3 = np.reshape(Overlap_all3_average[m,l,r,nr,:], (-1))

                actual_0layer1 = np.reshape(Overlap_0layer1_average[m,l,r,nr,:], (-1))
                actual_0layer2 = np.reshape(Overlap_0layer2_average[m,l,r,nr,:], (-1))

                actual_1layer1 = np.reshape(Overlap_1layer1_average[m,l,r,nr,:], (-1))
                actual_1layer2 = np.reshape(Overlap_1layer2_average[m,l,r,nr,:], (-1))

                actual_2layer1 = np.reshape(Overlap_2layer1_average[m,l,r,nr,:], (-1))
                actual_2layer2 = np.reshape(Overlap_2layer2_average[m,l,r,nr,:], (-1))

                actual_3layer1 = np.reshape(Overlap_3layer1_average[m,l,r,nr,:], (-1))
                actual_3layer2 = np.reshape(Overlap_3layer2_average[m,l,r,nr,:], (-1))

                target_0 = np.reshape(target_overlap_0[m,l,r,:,:], (-1))
                target_1 = np.reshape(target_overlap_1[m,l,r,:,:], (-1))
                target_2 = np.reshape(target_overlap_2[m,l,r,:,:], (-1))
                target_3 = np.reshape(target_overlap_3[m,l,r,:,:], (-1))

                Correlation_all_0[m,l,r,nr] = np.corrcoef(actual_all_0, target_0)[0,1]
                Correlation_all_1[m,l,r,nr] = np.corrcoef(actual_all_1, target_1)[0,1]
                Correlation_all_2[m,l,r,nr] = np.corrcoef(actual_all_2, target_2)[0,1]
                Correlation_all_3[m,l,r,nr] = np.corrcoef(actual_all_3, target_3)[0,1]

                Correlation_0layer1[m,l,r,nr] = np.corrcoef(actual_0layer1, target_0)[0,1]
                Correlation_0layer2[m,l,r,nr] = np.corrcoef(actual_0layer2, target_0)[0,1]

                Correlation_1layer1[m,l,r,nr] = np.corrcoef(actual_1layer1, target_1)[0,1]
                Correlation_1layer2[m,l,r,nr] = np.corrcoef(actual_1layer2, target_1)[0,1]

                Correlation_2layer1[m,l,r,nr] = np.corrcoef(actual_2layer1, target_2)[0,1]
                Correlation_2layer2[m,l,r,nr] = np.corrcoef(actual_2layer2, target_2)[0,1]

                Correlation_3layer1[m,l,r,nr] = np.corrcoef(actual_3layer1, target_3)[0,1]
                Correlation_3layer2[m,l,r,nr] = np.corrcoef(actual_3layer2, target_3)[0,1]

print("ok")
Correlation_all0_mean = np.mean(Correlation_all_0,2)
Correlation_all1_mean = np.mean(Correlation_all_1,2)
Correlation_all2_mean = np.mean(Correlation_all_2,2)
Correlation_all3_mean = np.mean(Correlation_all_3,2)

Correlation_0layer1_mean = np.mean(Correlation_0layer1,2)
Correlation_0layer2_mean = np.mean(Correlation_0layer2,2)

Correlation_1layer1_mean = np.mean(Correlation_1layer1,2)
Correlation_1layer2_mean = np.mean(Correlation_1layer2,2)

Correlation_2layer1_mean = np.mean(Correlation_2layer1,2)
Correlation_2layer2_mean = np.mean(Correlation_2layer2,2)

Correlation_3layer1_mean = np.mean(Correlation_3layer1,2)
Correlation_3layer2_mean = np.mean(Correlation_3layer2,2)

Correlation_all0_ci = 1.96*np.std(Correlation_all_0,2)/np.sqrt(Rep)
Correlation_all1_ci = 1.96*np.std(Correlation_all_1,2)/np.sqrt(Rep)
Correlation_all2_ci = 1.96*np.std(Correlation_all_2,2)/np.sqrt(Rep)
Correlation_all3_ci = 1.96*np.std(Correlation_all_3,2)/np.sqrt(Rep)

Correlation_0layer1_ci = 1.96*np.std(Correlation_0layer1,2)/np.sqrt(Rep)
Correlation_0layer2_ci = 1.96*np.std(Correlation_0layer2,2)/np.sqrt(Rep)

Correlation_1layer1_ci = 1.96*np.std(Correlation_1layer1,2)/np.sqrt(Rep)
Correlation_1layer2_ci = 1.96*np.std(Correlation_1layer2,2)/np.sqrt(Rep)

Correlation_2layer1_ci = 1.96*np.std(Correlation_2layer1,2)/np.sqrt(Rep)
Correlation_2layer2_ci = 1.96*np.std(Correlation_2layer2,2)/np.sqrt(Rep)

Correlation_3layer1_ci = 1.96*np.std(Correlation_3layer1,2)/np.sqrt(Rep)
Correlation_3layer2_ci = 1.96*np.std(Correlation_3layer2,2)/np.sqrt(Rep)

MNIST_RDM_train_dir = {
    "0_Hidden_mean": np.mean(Correlation_all1_mean,1),
    "0_Hidden_ci": np.mean(Correlation_all1_ci,1),
    "1_Hidden_mean": np.mean(Correlation_all1_mean,1),
    "1_Hidden_ci": np.mean(Correlation_all1_ci,1),
    "2_Hidden_mean": np.mean(Correlation_all2_mean,1),
    "2_Hidden_ci": np.mean(Correlation_all2_ci,1),
    "3_Hidden_mean": np.mean(Correlation_all3_mean,1),
    "3_Hidden_ci": np.mean(Correlation_all3_ci,1),
    "0_1_Hidden_mean": np.mean(Correlation_0layer1_mean,1),
    "0_1_Hidden_ci": np.mean(Correlation_0layer1_ci,1),
    "0_2_Hidden_mean": np.mean(Correlation_0layer2_mean,1),
    "0_2_Hidden_ci": np.mean(Correlation_0layer2_ci,1),
    "1_1_Hidden_mean": np.mean(Correlation_1layer1_mean,1),
    "1_1_Hidden_ci": np.mean(Correlation_1layer1_ci,1),
    "1_2_Hidden_mean": np.mean(Correlation_1layer2_mean,1),
    "1_2_Hidden_ci": np.mean(Correlation_1layer2_ci,1),
    "2_1_Hidden_mean": np.mean(Correlation_2layer1_mean,1),
    "2_1_Hidden_ci": np.mean(Correlation_2layer1_ci,1),
    "2_2_Hidden_mean": np.mean(Correlation_2layer2_mean,1),
    "2_2_Hidden_ci": np.mean(Correlation_2layer2_ci,1),
    "3_1_Hidden_mean": np.mean(Correlation_3layer1_mean,1),
    "3_1_Hidden_ci": np.mean(Correlation_3layer1_ci,1),
    "3_2_Hidden_mean": np.mean(Correlation_3layer2_mean,1),
    "3_2_Hidden_ci": np.mean(Correlation_3layer2_ci,1)
}
np.save(Dir + "RDM_train_MNIST.npy", MNIST_RDM_train_dir)

print("ok")
from sklearn.decomposition import PCA
p = PCA(n_components = 2)

rate = 5
repid = np.random.randint(0,Rep)

pca_0 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_0_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_0_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_1_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_1_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_2_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3_1 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))
pca_3_2 = np.zeros((len(Models),len(learning_rates),Rep, 2, nRepeats,nContexts,nLabels))

contexts=["odd","even",">5","<5",">3","<7"]
color_bis = ["c", "m", "y", "b","k",'r']

for m in range(len(Models)):
    for lr in range(len(learning_rates)):
        for r in range(Rep):
            data_0 = np.transpose(np.reshape(activation_0[m,lr,r,:,:,:,:],(402,-1)))
            data_1 = np.transpose(np.reshape(activation_1[m,lr,r,:,:,:,:],(402,-1)))
            data_2 = np.transpose(np.reshape(activation_2[m,lr,r,:,:,:,:],(402,-1)))
            data_3 = np.transpose(np.reshape(activation_3[m,lr,r,:,:,:,:],(402,-1)))

            data_0_1 = data_0[:,::301]
            data_0_2 = data_0[:,301::]

            data_1_1 = data_1[:,::301]
            data_1_2 = data_1[:,301::]

            data_2_1 = data_2[:,::301]
            data_2_2 = data_2[:,301::]

            data_3_1 = data_3[:,::301]
            data_3_2 = data_3[:,301::]

            pca_0[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_0)),(2,nRepeats,nContexts,nLabels))
            pca_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_1)),(2,nRepeats,nContexts,nLabels))
            pca_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2)),(2,nRepeats,nContexts,nLabels))
            pca_3[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3)),(2,nRepeats,nContexts,nLabels))

            pca_0_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_0_1)),(2,nRepeats,nContexts,nLabels))
            pca_0_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_0_2)),(2,nRepeats,nContexts,nLabels))
            pca_1_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_1_1)),(2,nRepeats,nContexts,nLabels))
            pca_1_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_1_2)),(2,nRepeats,nContexts,nLabels))
            pca_2_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_1)),(2,nRepeats,nContexts,nLabels))
            pca_2_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_2_2)),(2,nRepeats,nContexts,nLabels))
            pca_3_1[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3_1)),(2,nRepeats,nContexts,nLabels))
            pca_3_2[m,lr,r,:,:,:,:] = np.reshape(np.transpose(p.fit_transform(data_3_2)),(2,nRepeats,nContexts,nLabels))

MNIST_pca_train_dir = {
    "0_Hidden": pca_0,
    "1_Hidden": pca_1,
    "2_Hidden": pca_2,
    "3_Hidden": pca_3,
    "0_1_Hidden": pca_0_1,
    "0_2_Hidden": pca_0_2,
    "1_1_Hidden": pca_1_1,
    "1_2_Hidden": pca_1_2,
    "2_1_Hidden": pca_2_1,
    "2_2_Hidden": pca_2_2,
    "3_1_Hidden": pca_3_1,
    "3_2_Hidden": pca_3_2,
}
np.save(Dir + "PCA_train_MNIST.npy", MNIST_pca_train_dir)

print("ok")
