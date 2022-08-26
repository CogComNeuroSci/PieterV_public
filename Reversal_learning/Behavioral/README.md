# Behavioral folder

The file **200327_behavioral_analyses.R** contains all code to perform the analyses of behavioral data.
*Keep in mind that this can only be done if all models are fitted*

**Folders contain (python) scripts for fitting all models** : one folder for each model
*Note: The ALR model as described in the paper is here refered to as hybrid model. During the publication process, we altered the name in the paper but we did not do this in the code*

Every folder contains 5 scripts:
1. *make_data_...* : extracts the relevant data from the raw behavioral files and then saves this data in a folder for fitting. This script should be run first
2. *likelihood_...* : contains a function for computing the likelihoods of responses under different parameter settings
3. *estimation_...* : contains a function for estimating the best fitting parameters by using the likelihood
4. *sim_data_...* : contains a function to simulate data with a given parameter set.
5. *Estimating_PE_...* : uses functions 2-4 to fit the models, and simulate some output under the optimal parameter values. This can be run after the make_data_... file.

