from Simulation_functions import Simulations_gatlayer as Sims
from itertools import product
import numpy as np
from multiprocessing import Process, Pool

#Define parameters
nc = 6
nr = 3
ntr = 0.2
res = np.array([300,100])
lr = np.arange(0,0.11,0.02)
rep = np.arange(25)
models = np.arange(2)

combinations = list(product(*[lr ,rep, models]))

Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/MNIST/gatelayer/"#"/scratch/gent/430/vsc43099/"

#Dir = "/data/gent/430/vsc43099/GatingModel_data/MNIST/gatelayers/" #"/Volumes/backupdisc/Modular_learning/Data_MNIST/Revision/onelayer/"

#simulate each model in parallel on separate cores
cp = 5

worker_pool = []

def job(core=0):
    done = False
    for z in range(43,60):
        pars = combinations[core+z*cp]
        lrid = [pars[0]]
        repid = [pars[1], pars[1]+1]
        mid = pars[2]
        Sims.Simulation(nc, nr, ntr, res, lrid, repid, mid, Dir)
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
