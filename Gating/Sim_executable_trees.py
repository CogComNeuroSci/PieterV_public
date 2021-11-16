from Simulation_functions import Simulations as Sims
import numpy as np
from multiprocessing import Process, Pool

#Define parameters
nc = 4
nr = 3
ntr = 450
lr = np.arange(0,1.1,0.1)
rep = [0,30]

#Dir = "/Volumes/backupdisc/Modular_learning/Data_Trees/Revision/"+str(res)+"/"
#simulate each model in parallel on separate cores
cp = 8

worker_pool = []

def job(core=0):
    done = False
    if core <4:
        res =12
    else:
        res =24
    mid = int(core%4)
    Dir = "/Volumes/backupdisc/Modular_learning/Data_Revision/Trees/"+ str(res)+"/"
    Sims.Simulation(nc, nr, ntr, res, lr, rep, mid, Dir,False,"Trees")
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
