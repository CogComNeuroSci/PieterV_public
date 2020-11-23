#!/bin/bash

#PBS -N fitting_jneuro ## job name
#PBS -l nodes=1:ppn=6    ## single-node job, 8 cores in the node
#PBS -l walltime=72:00:00 ## max. 72u of walltime
#PBS -m abe				  ## send mail

# load relevant module
module load Python/3.6.6-intel-2018b

# cd and run first script
cd $HOME_DIR
cd ./scripts/
python estimating_PE_Sync_bis.py
