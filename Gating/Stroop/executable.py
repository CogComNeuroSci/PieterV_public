import Dat as D
import model_fun_intest as mf
import Simulations_intest as Sims
import numpy as np
from   multiprocessing import Process, Pool

cp = 2

worker_pool = []

def job(core=0):
    done = False
    Sims.Simulation(Model = core)
    done = True
    return done

with Pool(cp) as pool:
    result = pool.map(job, np.arange(cp))
    print(result)
