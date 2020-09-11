# Neural synchrony for adaptive control

## Model.m file 
Matlab code to simulate the model. 
  - All three models can be simulated by changing parameter values.
  - Current parameter settings simulate the spatiotemporal adaptive model
  - Also the supplementary simulations of control on different timescales can be performed with slight adaptations to this script

## Pre_analyses.m 
combines relevant data of several simulations into one datafile that can be analyzed in R

## Analyses.R 
analyzes the data of all three models described in the paper and makes plots

## Parameter explorations
Simulation: Control_par_explore.m and Accumulator_par_explore.m
Analyzing: analyses_accumulator_explore.R and Analyses_control_explore.R

### Analyses_timescales.R 
script to analyze data from supplementary simulations on different timescales for control.

