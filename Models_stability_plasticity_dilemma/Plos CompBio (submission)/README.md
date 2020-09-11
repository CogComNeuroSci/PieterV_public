This folder contains scripts used for model simulation and analyses

The first part of the file name states which model is simulated or analysed.

The second part of the file name states whether it is a classic (synaptic), a sync model simulation or an analysis file.
sync files containing the model code with synchrony
synaptic files containing the model code without synchrony

The third part of the model file names states how many stimulusdimensions were included in the input layer.
for backpropagation we have seperate scripts for the 2 and 3 dimensional tasks
for RBM we only simulated a 3 dimensional task

Additionally, the 
RW_RL and RW_frequency are scripts used for the parameter explorations 
for respectively the RL unit and the oscillatory nodes
