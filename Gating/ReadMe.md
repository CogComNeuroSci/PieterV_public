For this study we have 4 folders.
Three correspond to the three datasets to which the model is tested (see paper)
These are the Stroop, Trees and MNIST dataset
The 4th folder (Activation_exploration) contains scripts that are described in the supplementary information of the paper

Each folder contains a similar set of scripts:
First we train the model:
Dat.py preprocesses the data (input and labels) before training the model
model_fun.py contains model functions
Simulations.py applies (simulates) the model functions on the data that results from Dat.py
executable.py contains some code to perform parallel computing on the simulations

Then we test the model:
Generalization_prepare.py preprocesses the data before testing
Generalization_fun.py holds model functions 
Generalization_executable.py applies the model functions on the data 

Analyses.py and Analyses_generalization.py hold scripts to analyze the results after training and testing respectively

In the MNIST folder there are separate scripts for simulating the network with one or two hidden layers

The Plots_general.py file makes plots for the paper
