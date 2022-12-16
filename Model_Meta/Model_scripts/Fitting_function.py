#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#Import modules
import numpy as np
import pandas as pd
import time
from multiprocessing import Process, cpu_count, Pool

#Own functions
import Prep_functions as funct
import Likelihood_function as Lik
import Simulation_function as Sims

#specify dataset
dataset ="Online"

Design_folder = "/data/gent/430/vsc43099/Model_study/Behavioral_data/"+ dataset +"/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Data_to_fit/"+dataset+"/"
result_folder = "/data/gent/430/vsc43099/Model_study/fitted_data/"+ dataset +"/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Fitted_data/"+dataset+"/"#

if dataset =="Verbeke":
    pplist=np.zeros((30))
    pplist[0:8]=np.arange(3,11)
    pplist[8]=12
    pplist[9:31]=np.arange(14,35)
    pplist = pplist.astype(int)
    nstim = 2
elif dataset =="Liu":
    pplist=np.arange(1,24)
    nstim = 2
elif dataset =="Online":
    pplist=np.arange(49)
    nstim = 2
elif dataset =="Xia":
    pplist=np.arange(1,108)
    nstim = 4
elif dataset =="Hein":
    pplist=np.arange(1,21)
    nstim = 1
elif dataset =="Huycke":
    pplist = np.arange(1,25)
    nstim = 36
elif dataset =="Cohen":
    pplist = np.arange(1,16)
    nstim = 1
#elif dataset =="Wyart":
    #pplist = np.arange(1,28)
    #nstim = 1
elif dataset =="Goris/Stable":
    pplist=np.arange(1,144)
    nstim = 2
elif dataset =="Goris/Volatile":
    pplist=np.arange(1,144)
    nstim = 2
elif dataset =="Mukherjee":
    pplist = np.arange(1,65)
    nstim = 1

print(pplist)
print(nstim)
#List with modelnames, some of these names changed during writing
#Correct list as in the paper would be ["Flat", "Sets", "ALR", "Sets_ALR", "Sets_Learning", "Full"]
Models = ["RW", "Error", "ALR", "ALR_Error", "Learning", "Full"]

cp = 18#cpu_count()
simlist = []
npp = len(pplist)

#Divide participants over cpus
if cp > len(Models):
    pa = int(np.floor(cp/len(Models)))
    for i in range(pa):
        if ((i+1)*np.ceil(npp/pa))>npp:
            simlist.append(pplist[int(i *np.ceil(npp/pa))::].astype(int))
        else:
            simlist.append(pplist[int(i *np.ceil(npp/pa)): int((i+1)*np.ceil(npp/pa))].astype(int))
else:
    simlist = [pplist]

print(simlist)
#Define parameter bounds for each model
RWbounds = ((0,1),(0,100),(0,0),(0,0),(0,0),(0.49,0.49))
Errorbounds = ((0,1),(0,100),(0,0),(0,1),(0,0),(0.49,0.49))
ALRbounds = ((0,1),(0,100),(0,1),(0,0),(0,0),(0.49,0.49))
ALRErrorbounds = ((0,1),(0,100),(0,1),(0,1),(0,0),(0.49,0.49))
Learningbounds = ((0,1),(0,100),(0,0),(0,1),(0,1),(0.49,0.49))
Fullbounds = ((0,1),(0,100),(0,1),(0,1),(0,1),(0.49,0.49))

all_bounds = [RWbounds, Errorbounds, ALRbounds, ALRErrorbounds, Learningbounds, Fullbounds]

#Make a result dictionary
Result_dict = {
    "Model": [],
    "Subject": [],
    "Lr": [],
    "Temp":[],
    "Hybrid": [],
    "Cum": [],
    "Hlr":[],
    "LogLik":[]
}

#Fit models
def Fitting_execution(worker = 0):
    #from the used cpu, determine what model is fitted and which subject to use
    m = int(worker %len(Models))
    s = int(np.floor(worker/len(Models)))
    print("Model is : " + Models[m])
    print("Subjects are: ")
    print(simlist[s])

    for i in simlist[s]:

        #Load data file
        file = Design_folder + "Data_subject_{0}.csv".format(i)
        if i == pplist[0]:
            start_time = time.time()
            print("\nProcess is running")

        Result_dict["Model"].append(Models[m])
        Result_dict["Subject"].append(i)

        #Fit model
        est = funct.estimation(file, all_bounds[m], nstim)
        print("done fitting " + str(m) + " " + str(i))
        #Simulate data with fitted parameters
        Sims.simulate_data(est.x[0], est.x[1], est.x[2], est.x[3], est.x[4], threshold = .49, file_name = file, folder =result_folder, simnr=m, sub = i, fit = True, nstim= nstim)

        #Store parameter values
        Result_dict["Lr"].append(est.x[0])
        Result_dict["Temp"].append(est.x[1])
        Result_dict["Hybrid"].append(est.x[2])
        Result_dict["Cum"].append(est.x[3])
        Result_dict["Hlr"].append(est.x[4])

        #Store log likelihood
        Result_dict["LogLik"].append(-est.fun)

        if Models[m] == "Full"  and s == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    df = pd.DataFrame.from_dict(Result_dict)
    df.to_csv(result_folder + "/Fit_data_{0}_{1}.csv".format(Models[m], worker))

    return
