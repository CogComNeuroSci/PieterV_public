#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 19 10:01:43 2019

@author: pieter
"""

import estimation_RW as estimation
import likelihood_RW as likelihood
import sim_data_RW as sim_data

import numpy as np
import pandas as pd
import os

pplist=[3,5,6,7,9,10,12,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34]

method="g"

pars=[]
Lik=[]
loop=0

os.chdir('/Volumes/Harde ploate/EEG_reversal_learning/model_fitting/RW_data')

for p in pplist:
    print("Estimating parameters of subject {}".format(p))
    
    file = 'Behavioral_data_subject_{0}_RW.csv'.format(int(p))
    
    if method=="gradient":
        est=estimation.estimate(file)
        pars.append(est)
        Lik.append(-est.fun)
    else:
        est = estimation.evol_estimate(file)
        pars.append(est.x)
        Lik.append(-est.fun)
        print(est.message)
        
    print("Estimated parameters are {} and {}".format(pars[loop][0], pars[loop][1]))
    
    sim_data.simulate_data(alpha = pars[loop][0], beta = pars[loop][1], file_name = file)

    
    print("Estimated the prediction errors" )
    print("LogLikelihood was {}".format(Lik[loop]))
    loop+=1

print(pars)
Learning_rates= [item[0] for item in pars]
Temperatures= [item[1] for item in pars]

print(Learning_rates)
print(Temperatures)
print("Mean learning rate")
print(np.mean(Learning_rates))
print("std learning rate")
print(np.std(Learning_rates))
print("Mean temperature")
print(np.mean(Temperatures))
print("std temperature")
print(np.std(Temperatures))
print("Mean LogLikelihood")
print(np.mean(Lik))
print("std Loglikelihood")
print(np.std(Lik))
AIC=-2*np.asarray(Lik)+ 2*(len(pars[0]))
print("Mean AIC")
print(np.mean(AIC))
print("std AIC")
print(np.std(AIC))

BIC=np.log(480)*len(pars[0])-2*np.asarray(Lik)

new_filename='RW_output.csv'.format(int(p))
column_list = ["Subject", "Learning rate", "Temperature", "LogLik", "AIC", "BIC"]
    
output=pd.DataFrame({ 'Subject':pplist, 'Learning rate':Learning_rates, 'Temperature':Temperatures, 'LogLik':Lik, 'AIC':AIC, 'BIC':BIC}, columns = column_list)
    
output.to_csv(new_filename, columns = column_list, float_format ='%.5f')




