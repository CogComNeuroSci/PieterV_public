#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import Likelihood_function as Lik
from multiprocessing import Process, cpu_count, Pool
from scipy import optimize
import pandas as pd

Data_folder = "/data/gent/430/vsc43099/Model_study/Behavioral_data/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Behavioral_data/"#
Design_folder = "/data/gent/430/vsc43099/Model_study/Designs/"#"/Users/pieter/Desktop/ModelRecoveryExplore/Designs/"#

pplist=np.zeros((30))
pplist[0:8]=np.arange(3,11)
pplist[8]=12
pplist[9:31]=np.arange(14,35)
pplist = pplist.astype(int)

def parameter_samples(tot_sims = 100, ndesigns = 10, parameters =["learning_rate", "temperature", "hybrid", "cumulation", "higher_learning"], pplist = pplist):
    np.random.seed(40)
    designs = np.random.choice(pplist, ndesigns, replace = False)

    if "learning_rate" in parameters:
        learning_rates = np.random.normal(loc = .75, scale = .07, size = tot_sims)
        lr_bounds = (0,1)
    else:
        learning_rates = np.zeros((tot_sims))
        lr_bounds = (0,0)

    if "temperature" in parameters:
        temperatures = np.random.normal(loc = .5, scale = .1, size = tot_sims)
        temp_bounds = (0, 100)
    else:
        temperatures = np.zeros((tot_sims))
        temp_bounds = (0,0)

    if "hybrid" in parameters:
        hybrids = np.random.normal(loc = .75, scale = .07, size = tot_sims)
        hybrid_bounds = (0,1)
    else:
        hybrids = np.zeros((tot_sims))
        hybrid_bounds = (0,0)

    if "cumulation" in parameters:
        cumulations = np.random.normal(loc = .75, scale = .07, size = tot_sims)
        cum_bounds = (0,1)
    else:
        cumulations = np.zeros((tot_sims))
        cum_bounds = (0,0)

    if "higher_learning" in parameters:
        higher_learnings = np.random.normal(loc = .25, scale = .07, size = tot_sims)
        hlr_bounds = (0,1)
    else:
        higher_learnings = np.zeros((tot_sims))
        hlr_bounds = (0,0)

    thresholds = .49 * np.ones((tot_sims))
    threshold_bounds = (.49,.49)

    par_dir = {
        "lrs": learning_rates,
        "temps": temperatures,
        "hybrids": hybrids,
        "cum": cumulations,
        "hlr": higher_learnings,
        "thr": thresholds
    }

    bounds = (lr_bounds, temp_bounds, hybrid_bounds, cum_bounds, hlr_bounds, threshold_bounds)

    return par_dir, bounds, designs

def estimation (file_name = "sim_data.csv", bounds = ((0,1),(0,100), (0,1), (0,1), (0,1), (0.49,0.49)), nstim =2):
    estim_param = optimize.differential_evolution(Lik.logL, bounds, args =(tuple([file_name, nstim])), maxiter = 5000, tol = 0.005)
    return estim_param
