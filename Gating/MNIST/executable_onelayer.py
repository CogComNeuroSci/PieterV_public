#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 19 10:01:43 2019

@author: pieter
"""

import Dat as Dat
import model_onelayer_fun as mf
import Simulations_onelayer as Sims
import tensorflow as tf
import numpy as np
from   multiprocessing import Process, Pool

cp = 2#4

worker_pool = []

def job(core=0):
    done = False
    Sims.Simulation(Model = core)
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
