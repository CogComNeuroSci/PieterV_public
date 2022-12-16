import Fitting_function as Fit
import Prep_functions as funct
import numpy as np
from   multiprocessing import Process, cpu_count, Pool

"""
Before running remember to change dataset variable in Fitting_function file
"""

cp = 18

worker_pool = []

with Pool(cp) as pool:
    result = pool.map(Fit.Fitting_execution, np.arange(cp))
