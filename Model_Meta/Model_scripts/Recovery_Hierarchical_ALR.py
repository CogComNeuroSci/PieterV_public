import Ex_functions_recovery as exec
import Prep_functions as funct
import numpy as np
from   multiprocessing import Process, cpu_count, Pool

cp = cpu_count()
print(cp)

worker_pool = []

Data_folder = "/data/gent/430/vsc43099/Model_study/Behavioral_data/"
Design_folder = "/data/gent/430/vsc43099/Model_study/Designs/"

simfun = exec.ALRError_execution
with Pool(cp) as pool:
    result = pool.map(simfun, np.arange(cp))
