from Simulation_functions import Simulations as Sims
import numpy as np
from multiprocessing import Process, Pool

#Define parameters
nc = 6
nr = 3
ntr = 0.2
res = 400
lr = np.arange(0.01,0.03,0.01)
rep = [[0,15], [15,30]]

Dir = "/Users/pieter/Desktop/DataFolder/"#"/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/onelayer/" #"/data/gent/430/vsc43099/GatingModel_data/MNIST/onelayer/" #

#simulate each model in parallel on separate cores
cp = 8

worker_pool = []

def job(core=0):
    done = False
    mid = int(core%4)
    rid = int(np.floor(core/4))
    Sims.Simulation(nc, nr, ntr, res, lr, rep[rid], mid, Dir, False,"MNIST")
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
