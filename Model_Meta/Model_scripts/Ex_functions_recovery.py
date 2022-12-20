#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Load modules
import numpy as np
import pandas as pd
import time
from multiprocessing import Process, cpu_count, Pool

#Own functions
import Prep_functions as funct
import Likelihood_function as Lik
import Simulation_function as Sims

#Set folder names
Data_folder = "/data/gent/430/vsc43099/Model_study/Behavioral_data/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Behavioral_data/"#
Design_folder = "/data/gent/430/vsc43099/Model_study/Designs/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Designs/"#
result_folder = "/data/gent/430/vsc43099/Model_study/"#"/Users/pieter/Desktop/ModelRecoveryExplore/"#

#Define a participantlist
pplist=np.zeros((30))
pplist[0:8]=np.arange(3,11)
pplist[8]=12
pplist[9:31]=np.arange(14,35)
pplist = pplist.astype(int)

#Store the relevant parameters for each model in a list
RW_params = ["learning_rate", "temperature"]
Error_params = ["learning_rate", "temperature", "cumulation"]
ALR_params = ["learning_rate", "temperature", "hybrid"]
ALR_Error_params = ["learning_rate", "temperature", "hybrid", "cumulation"]
Learning_params = ["learning_rate", "temperature", "cumulation", "higher_learning"]
Full_params = ["learning_rate", "temperature", "hybrid", "cumulation", "higher_learning"]

#Set folders for data of each model
RW_folder = result_folder + "RW_sims/"
Error_folder = result_folder + "Error_sims/"
ALR_folder = result_folder + "ALR_sims/"
ALR_Error_folder = result_folder + "ALR_Error_sims/"
Learning_folder = result_folder + "Learning_sims/"
Full_folder = result_folder + "Full_sims/"

#How many cpu's are available
cp = cpu_count()
print(cp)

#We will do 15 simulations per cpu
allsims = cp*15

simlist = []
#We use 9 different task randomisations unless there are no more than 9 cores available
if cp < 9:
    ndes = cp
else:
    ndes = 9

#divide simulations over cpus
for i in range(cp):
    simlist.append(np.arange(i *np.floor(allsims/cp), (i+1)*np.floor(allsims/cp)).astype(int))

#Sample parameters, bounds and samples of designs for each model
RWpars, RWbounds, RWsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = RW_params, pplist = pplist)
Errorpars, Errorbounds, Errorsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = Error_params, pplist = pplist)
ALRpars, ALRbounds, ALRsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = ALR_params, pplist = pplist)
ALRErrorpars, ALRErrorbounds, ALRErrorsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = ALR_Error_params, pplist = pplist)
Learningpars, Learningbounds, Learningsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = Learning_params, pplist = pplist)
Fullpars, Fullbounds, Fullsamples = funct.parameter_samples(tot_sims = allsims, ndesigns = ndes, parameters = Full_params, pplist = pplist)

#Initialize lists to store data
Rewards = []
Params = []

#Parameter estimation lists
RW_estimations = []
Error_estimations = []
ALR_estimations = []
ALRError_estimations = []
Learning_estimations = []
Full_estimations = []

#Likelihood lists
RW_liks = []
Error_liks = []
ALR_liks = []
ALRError_liks = []
Learning_liks = []
Full_liks = []

#Parameter and model recovery for RW model
def RW_execution(worker = 0):

    #Choose a task design to simulate on
    subject = RWsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0 and i ==0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [RWpars["lrs"][i], RWpars["temps"][i], RWpars["hybrids"][i], RWpars["cum"][i], RWpars["hlr"][i], RWpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = RW_folder, simnr = worker, sub = subject, nstim = 2)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = RW_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = RW_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds, nstim = 2)
        est_Error = funct.estimation(new_filename, Errorbounds, nstim = 2)
        est_ALR = funct.estimation(new_filename, ALRbounds, nstim = 2)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds, nstim = 2)
        est_Learning = funct.estimation(new_filename, Learningbounds, nstim = 2)
        est_Full = funct.estimation(new_filename, Fullbounds, nstim = 2)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(RW_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return

#Parameter and model recovery for Hierarchical model (terminology has changed from Error to Hierarchical model during writing)
def Error_execution(worker = 0):
    #Choose a task design to simulate on
    subject = Errorsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0 and i ==0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [Errorpars["lrs"][i], Errorpars["temps"][i], Errorpars["hybrids"][i], Errorpars["cum"][i], Errorpars["hlr"][i], Errorpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = Error_folder, simnr = worker, sub = subject)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = Error_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = Error_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds)
        est_Error = funct.estimation(new_filename, Errorbounds)
        est_ALR = funct.estimation(new_filename, ALRbounds)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds)
        est_Learning = funct.estimation(new_filename, Learningbounds)
        est_Full = funct.estimation(new_filename, Fullbounds)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(Error_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return

#Parameter and model recovery for ALR model
def ALR_execution(worker = 0):

    #Choose a task design to simulate on
    subject = ALRsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [ALRpars["lrs"][i], ALRpars["temps"][i], ALRpars["hybrids"][i], ALRpars["cum"][i], ALRpars["hlr"][i], ALRpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = ALR_folder,  simnr = worker, sub = subject)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = ALR_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = ALR_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds)
        est_Error = funct.estimation(new_filename, Errorbounds)
        est_ALR = funct.estimation(new_filename, ALRbounds)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds)
        est_Learning = funct.estimation(new_filename, Learningbounds)
        est_Full = funct.estimation(new_filename, Fullbounds)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(ALR_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return
#Parameter and model recovery for Hierarchical_ALR model (terminology has changed from ALRError to Hierarchical_ALR model during writing)
def ALRError_execution(worker = 0):
    subject = ALRErrorsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [ALRErrorpars["lrs"][i], ALRErrorpars["temps"][i], ALRErrorpars["hybrids"][i], ALRErrorpars["cum"][i], ALRErrorpars["hlr"][i], ALRErrorpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = ALR_Error_folder,  simnr = worker, sub = subject)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = ALR_Error_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = ALR_Error_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds)
        est_Error = funct.estimation(new_filename, Errorbounds)
        est_ALR = funct.estimation(new_filename, ALRbounds)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds)
        est_Learning = funct.estimation(new_filename, Learningbounds)
        est_Full = funct.estimation(new_filename, Fullbounds)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(ALR_Error_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return

#Parameter and model recovery for Hierarchical_Learning model (terminology has changed from Learning to Hierarchical_Learning model during writing)
def Learning_execution(worker = 0):

    #Choose a task design to simulate on
    subject = Learningsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [Learningpars["lrs"][i], Learningpars["temps"][i], Learningpars["hybrids"][i], Learningpars["cum"][i], Learningpars["hlr"][i], Learningpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = Learning_folder ,  simnr = worker, sub = subject)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = Learning_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = Learning_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds)
        est_Error = funct.estimation(new_filename, Errorbounds)
        est_ALR = funct.estimation(new_filename, ALRbounds)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds)
        est_Learning = funct.estimation(new_filename, Learningbounds)
        est_Full = funct.estimation(new_filename, Fullbounds)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(Learning_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return

#Parameter and model recovery for Full model
def Full_execution(worker = 0):

    #Choose a task design to simulate on
    subject = Fullsamples[int(np.floor(worker%ndes))]
    file = Design_folder + "Data_subject_{0}.csv".format(subject)

    for i in simlist[int(worker)]:

        if worker == 0:
            start_time = time.time()
            print("\nProcess is running")

        #Get true parameters
        real_pars = [Fullpars["lrs"][i], Fullpars["temps"][i], Fullpars["hybrids"][i], Fullpars["cum"][i], Fullpars["hlr"][i], Fullpars["thr"][i]]
        #Simulate data with these parameters
        rew = Sims.simulate_data(real_pars[0], real_pars[1], real_pars[2], real_pars[3], real_pars[4], real_pars[5], file_name = file, folder = Full_folder,  simnr = worker, sub = subject)

        #Store model performance and true parameters
        Rewards.append(rew)
        Params.append(real_pars)

        if subject>9:
            new_filename = Full_folder + file[-19:-4]+ "_" + str(worker) + ".csv"
        else:
            new_filename = Full_folder + file[-18:-4]+ "_" + str(worker) + ".csv"

        #Fit data with each of the 6 models
        est_RW = funct.estimation(new_filename, RWbounds)
        est_Error = funct.estimation(new_filename, Errorbounds)
        est_ALR = funct.estimation(new_filename, ALRbounds)
        est_ALRError = funct.estimation(new_filename, ALRErrorbounds)
        est_Learning = funct.estimation(new_filename, Learningbounds)
        est_Full = funct.estimation(new_filename, Fullbounds)

        #Store parameter estimations
        RW_estimations.append(est_RW.x)
        Error_estimations.append(est_Error.x)
        ALR_estimations.append(est_ALR.x)
        ALRError_estimations.append(est_ALRError.x)
        Learning_estimations.append(est_Learning.x)
        Full_estimations.append(est_Full.x)

        #Store likelihoods
        RW_liks.append(-est_RW.fun)
        Error_liks.append(-est_Error.fun)
        ALR_liks.append(-est_ALR.fun)
        ALRError_liks.append(-est_ALRError.fun)
        Learning_liks.append(-est_Learning.fun)
        Full_liks.append(-est_Full.fun)

        if worker == 0:
            current_time = time.time()
            elapsed_time = np.floor((current_time - start_time)/60)
            print("\n *************************************\n")
            print("Elapsed time is: {} minutes".format(elapsed_time))
            estimated_time = np.floor((elapsed_time / (i+1)) * len(simlist[0]))
            print("Total estimated time is: {} minutes".format(estimated_time))
            print("Hence, now estimated to have reached {:.2f} %".format((elapsed_time/estimated_time)*100))
            print("\n *************************************\n")

    #Save everything via dictionary
    Data_dir = {
        "Performance": Rewards,
        "Real_pars": Params,
        "RW_Estpars": RW_estimations,
        "Error_Estpars": Error_estimations,
        "ALR_Estpars": ALR_estimations,
        "ALRError_Estpars": ALRError_estimations,
        "Learning_Estpars": Learning_estimations,
        "Full_Estpars": Full_estimations,
        "RW_LogL": RW_liks,
        "Error_LogL": Error_liks,
        "ALR_LogL": ALR_liks,
        "ALRError_LogL": ALRError_liks,
        "Learning_LogL": Learning_liks,
        "Full_LogL": Full_liks,
    }

    np.save(Full_folder + "Recovery_data_{0}.npy".format(worker), Data_dir, allow_pickle = True)

    return
