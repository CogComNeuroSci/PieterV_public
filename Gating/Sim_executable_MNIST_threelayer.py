from Simulation_functions import Simulations_threelayer as Sims
import numpy as np
from multiprocessing import Process, Pool

#Define parameters
nc = 6
nr = 3
ntr = 0.2
res = np.array([200,100,100])
lr = np.arange(0.01,0.11,0.01)
rep = [[0,15], [15,30]]

#Dir = "/Users/pieter/Desktop/DataFolder/"

Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/threelayer/" #"/data/gent/430/vsc43099/GatingModel_data/MNIST/threelayer/"#

#simulate each model in parallel on separate cores
cp = 8

worker_pool = []

def job(core=0):
    done = False
    mid = int(core%4)
    rid = int(np.floor(core/4))
    Sims.Simulation(nc, nr, ntr, res, lr, rep[rid], mid, Dir)
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
