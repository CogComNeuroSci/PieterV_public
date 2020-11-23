#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 19 10:01:43 2019

@author: pieter
"""

import estimation_Sync_bis as estimation
import likelihood_Sync_bis as likelihood
import sim_data_Sync_bis as sim_data

import numpy as np
import pandas as pd
#import os

from   multiprocessing import Process, cpu_count, Pool

cp = 6#cpu_count()

#pplist=[3,5,6,7,9,10,12,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]
pp=[[3,5,6,7,9],[10,12,14,15,16],[18,19,20,21],[22,23,24,25],[26,27,28,29],[30,31,32,33,34]]

method="g"

#os.chdir('/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/Sync_data/bis')
Datafolder ='/data/gent/430/vsc43099/Jneurotest/'

def fitting(core=0):
    pplist = pp[core]
    pars=[]
    Lik=[]
    loop=0
    for p in pplist:
        print("Estimating parameters of subject {}".format(p))

        file = Datafolder+'Behavioral_data_subject_{0}_Sync_bis.csv'.format(int(p))

        if method=="gradient":
            est=estimation.estimate(file)
            pars.append(est)
            Lik.append(-est.fun)
        else:
            est = estimation.evol_estimate(file)
            pars.append(est.x)
            Lik.append(-est.fun)
            print(est.message)

        print("Estimated parameters are {}, {}, {}, {} and {}".format(pars[loop][0], pars[loop][1], pars[loop][2], pars[loop][3], pars[loop][4]))

        sim_data.simulate_data(alpha = pars[loop][0], beta = pars[loop][1], lr =pars[loop][2], Threshold=pars[loop][3], explore= pars[loop][4], file_name = file)

        print("Estimated the prediction errors" )
        print("LogLikelihood was {}".format(Lik[loop]))
        loop+=1

    Cumulation_rates= [item[0] for item in pars]
    low_learning_rates=[item[1] for item in pars]
    RL_learning_rates=[item[2] for item in pars]
    Thresholds=[item[3] for item in pars]
    Temperatures= [item[4] for item in pars]

    print("Mean LogLikelihood")
    print(np.mean(Lik))
    print("std Loglikelihood")
    print(np.std(Lik))
    AIC=-2*np.asarray(Lik)+ 2*(len(pars[0])-1)
    print("Mean AIC")
    print(np.mean(AIC))
    print("std AIC")
    print(np.std(AIC))

    BIC=np.log(480)*len(pars[0]-1)-2*np.asarray(Lik)

    new_filename=Datafolder+'Sync_output_'+str(core)+'.csv'
    column_list = ["Subject", "Learning low", "Temperature", "Learning high", "Cumulation","LogLik", "AIC", "BIC"]

    output=pd.DataFrame({ 'Subject':pplist, 'Learning low':low_learning_rates, 'Temperature':Temperatures, "Learning high": RL_learning_rates, "Cumulation": Cumulation_rates, 'LogLik':Lik, 'AIC':AIC, 'BIC':BIC}, columns = column_list)

    output.to_csv(new_filename, columns = column_list, float_format ='%.5f')

    return AIC

with Pool(cp) as pool:
    result = pool.map(fitting, np.arange(cp))
    print(result)
