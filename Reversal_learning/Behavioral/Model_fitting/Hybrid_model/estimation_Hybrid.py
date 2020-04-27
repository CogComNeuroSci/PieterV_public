#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun 26 12:09:06 2019

@author: pieter
"""

import numpy as np
import likelihood_Hybrid as likelihood
from scipy import optimize

#gradient descent estimate
def estimate(nstim, file_name = "sim_data.csv"):
    estim_param = optimize.fmin(likelihood.logL, np.random.rand(2), args =(tuple([file_name])), maxiter= 100000, ftol = 0.001)
    return estim_param

#differential evolution estimate
def evol_estimate(nstim, file_name = "sim_data.csv"):
    estim_param = optimize.differential_evolution(likelihood.logL, ((0,1),(0.01,50),(0,1)), args =(tuple([file_name])), maxiter = 5000, tol = 0.001)
    return estim_param
