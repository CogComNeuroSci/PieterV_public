#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#Loading modules
import pandas as pd
import numpy as np
from scipy import optimize
import os, sys
from   multiprocessing import Process, cpu_count, Pool

#Loading own functions
import Optimize_function as of
import Simulation_function as sim

#Directory
dir = "/data/gent/430/vsc43099/Model_study/Optimize_models/"

#Function for optimizing model parameters
def estimation (file_name = "sim_data.csv", bounds = ((0,1),(0,100), (0,1), (0,1), (0,1), (0.49,0.49)), nstim =2):
    estim_param = optimize.differential_evolution(of.Optim_rew, bounds, args =(tuple([file_name, nstim])), maxiter = 5000, tol = 0.01)
    return estim_param

#Function for optimisation
def optimizing(worker = 0):

    #Define parameter bounds for each model
    RWbounds = ((0,1),(0,100),(0,0),(0,0),(0,0),(0.49,0.49))
    Modbounds = ((0,1),(0,100),(0,0),(0,1),(0,0),(0.49,0.49))
    ALRbounds = ((0,1),(0,100),(0,1),(0,0),(0,0),(0.49,0.49))
    ALRModbounds = ((0,1),(0,100),(0,1),(0,1),(0,0),(0.49,0.49))
    HigherModbounds = ((0,1),(0,100),(0,0),(0,1),(0,1),(0.49,0.49))
    Fullbounds = ((0,1),(0,100),(0,1),(0,1),(0,1),(0.49,0.49))

    #Environment variables
    structures = ["Stable", "Reversal", "Stepwise"]
    rewards = [1, .7]
    ntrials = 300

    #Model variables
    all_bounds = [RWbounds, Modbounds, ALRbounds, ALRModbounds, HigherModbounds, Fullbounds]
    Models = ["RW", "Mod", "ALR", "ALRMod", "HigherMod", "Full"]
    column_list = ["Structure", "Prew", "Model", "Lr", "Temp", "Hybrid", "Cumulation", "Hlr", "Cumulated_reward"]

    #Initialize lists
    struct = []
    prew = []
    model = []
    lr = []
    temp = []
    Hybr = []
    Cum = []
    Hlr = []
    result = []
    s = []

    print("start")

    for i in structures:
        for r in rewards:

            file = dir + "Data_{0}_{1}.csv".format(i,r)
            struct.append(i)
            prew.append(r)
            model.append(Models[worker])

            #Optimize parameters
            pars = estimation(file, all_bounds[worker], 2)
            print("done fitting " + Models[worker] + " on " + file)
            print("Success was {}".format(pars.success))
            print("paramter values are:")
            print("Learning rate: {}".format(pars.x[0]))
            print("Temperature: {}".format(pars.x[1]))
            print("Hybrid: {}".format(pars.x[2]))
            print("Cumulation: {}".format(pars.x[3]))
            print("Higher Learning rate: {}".format(pars.x[4]))
            print("Reward was: {}".format(-pars.fun))

            #Perform simulations
            print("Performing simulations")
            for x in range(50):
                rew = sim.simulate_data(pars.x[0], pars.x[1], pars.x[2], pars.x[3], pars.x[4], pars.x[5], file_name = file, folder = dir, simnr = (worker*100)+x, sub = 1, fit = False, nstim = 2)
            print("Simulation done")

            #Store the accumulated rewards and parameters
            s.append(pars.success)

            lr.append(pars.x[0])
            temp.append(pars.x[1])
            Hybr.append(pars.x[2])
            Cum.append(pars.x[3])
            Hlr.append(pars.x[4])
            result.append(-pars.fun)

    #Save data
    filename='Optimization_output_{0}.csv'.format(Models[worker])
    data=pd.DataFrame({"Structure":struct, 'Prew':prew, 'Model':model, "Lr":lr, "Temp": temp, "Hybrid": Hybr,"Cumulation":Cum, "Hlr": Hlr,"Cumulated reward": result}, columns = column_list)
    data.to_csv(filename, columns = column_list, float_format ='%.3f')

    return s

#Perform in parallel
Models = ["RW", "Mod", "ALR", "ALRMod", "HigherMod", "Full"]
cp = len(Models)

with Pool(cp) as pool:
    result = pool.map(optimizing, np.arange(cp))
