# Model_scripts

**scripts to simulate and fit the models but also to perform parameter and model recovery analyses**

___

## Prep_functions.py

contains two functions:

1 function to sample parameter values for performing the recovery analyses

A second function to perform the minimization of the log likelihood

___

## Likelihood_function.py

Provides a function to compute the likelihood for a given dataset under specified model parameters

___

## Simulation_function.py

Provides a function to simulate data under a specified set of model parameters.

___

## Fitting_function.py

Provides code/ a function to fit each of the six models to a given empirical dataset.

**The dataset for which one wants to execute the model fitting should be specified at the top of this file**

___

## executable_fit.py

Provides code to fit models on a dataset and perform this in parallel computation.

___

## job_script_fit.pbs

Provides code to perform model fitting in parallel on the High performance computing system of Ghent University.

___

## Optimize function.py

Provides a function to compute the cumulated reward for a given dataset under specified model parameters

___

## Optimize_function_new.py

Provides code/ a function to optimize (in terms of cumulated reward) each of the six models to a given empirical dataset.

**The dataset for which one wants to execute the model fitting should be specified at the top of this file**

___

## executable_opt.py

Provides code to optimize models (in terms of cumulated reward) on a dataset and perform this in parallel computation.

___

## job_script_Optimize.pbs

Provides code to perform model optimization (in terms of cumulated reward) in parallel on the High performance computing system of Ghent University.

___

## RNN.py

Provides code to optimize an RNN on each dataset and evaluate the activity.

___

## Ex_functions_recovery.py

Provides code/ a function to perform the parameter and model recovery analyses

___

## Recovery_XXX.py scripts

Each of these files provides an executable file to perform recovery analyses for the model XXX

___

## Combining_output_recovery.py

Provides code to combine all data from model recovery analyses.

These analyses were performed in parallel over multiple cores but also for multiple models.

___

for questions contact pjverbek.verbeke@ugent.be 
