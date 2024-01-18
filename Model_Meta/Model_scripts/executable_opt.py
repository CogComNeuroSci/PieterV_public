import Optimize_function_new as Opt
import numpy as np
from   multiprocessing import Pool

"""
Before running remember to change dataset variable in Fitting_function file
"""

cp = 18

worker_pool = []

with Pool(cp) as pool:
    result = pool.map(Opt.Fitting_execution, np.arange(cp))
