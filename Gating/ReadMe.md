# Using top-down modulation to optimally balance shared versus separated task representations

*https://doi.org/10.1016/j.neunet.2021.11.030*

___
The separate .py files are the code to run.  
The files that start with **Sim** are for *training* the networks.  
The files that start with **Test** are for *testing* the networks after training.  
The second part of the file name indicates the *dataset* (Stroop, Trees or MNIST).  
The third part mentions *other specifics*  
(the number of layers of the MNIST, exploring initialization, activation combination or concatenated vs separated transformation as described in the appendix).  
___

The folder **Preparation_functions** provides functions to *prepare the data* before simulating.  
The folder **Model_functions** provides functions to perform *one specific simulation* of the model.  
The folder **Simulation functions** provides code to *prepare and run each model version one time*   
with a specific learning rate and setup.  
The folder **Analyses functions** provides code for *analysing the data and making the plots* from the paper.  

___

for questions mail pjverbek.verbeke@ugent.be 
