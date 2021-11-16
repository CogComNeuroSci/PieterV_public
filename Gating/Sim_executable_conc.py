from Model_functions import model_sim_fun_conc as mf
from Preparation_functions import Prep_Stroop_Sim as D
from Simulation_functions import Simulations_conc as Sims
import numpy as np
from multiprocessing import Process, Pool

#Define parameters
nc = 5
nr = 3
ntr = 25
res = 12
lr = np.arange(0,1.1,0.1)
rep = [0,30]

#Dir = "/Users/pieter/Desktop/DataFolder/"
#simulate each model in parallel on separate cores
cp = 8

worker_pool = []

def job(core=0):
    done = False
    if core <4:
        task = "Stroop"
        nc = 5
        ntr = 25
        mult = True
    else:
        task = "Trees"
        nc = 4
        ntr = 450
        mult = False

    Dir = '/Volumes/backupdisc/Modular_learning/Data_Revision/sep/' + task + "/"#"/data/gent/430/vsc43099/GatingModel_data/conc/"+task+"/"
    mid = int(core%4)
    Sims.Simulation(nc, nr, ntr, res, lr, rep, mid, Dir, mult,task)
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
