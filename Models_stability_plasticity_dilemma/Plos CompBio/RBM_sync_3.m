%{
   Script for running the full RBM model
%}
%% Defining amount of loops
Rep=10;                         %amount of replication
T=250;                          %trialtime
iterations=5;                   %number of iterations in negative phase
Tr=3600;                        %number of trials
betas=11;                       %beta iterations
beta=0:0.1:1;                   %learning rate values
ITI=250;

POT=Tr/6:Tr/6:Tr;                 %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);            %third part
part4=POT(3)+1:POT(4);            %...
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);

%% model build-up
% Processing units
nStim=12;                %number input nodes
nM1=6;                   %number hidden nodes in module 1
nM2=6;                   %hidden nodes in module 2
nM3=6;                   %...
nResp=3;                 %number of response options
nInput=81;               %number of input patterns
bias=5;                  %bias parameter
nmod=3;                  %number of Hidden modules
r2max=1;                 %max amplitude
Cg=0.58;                 %coupling gamma waves
damp=0.3;                %damping parameter
decay=0.9;               %decay parameter

%Control unit
r2_acc=1;               %radius pMFC
Ct=0.07;                %coupling theta waves
damp_acc=0.003;         %damping parameter pMFC
acc_slope=10;

% RL unit
lp=0.01;                %learning parameter V

%% in- and output patterns
%input patterns
Activation=zeros(nStim,nInput);      %input patterns
Activation(:,1)=[1,0,0,1,0,0,1,0,0,1,0,0];                %Congruent     (1)
Activation(:,2)=[0,1,0,1,0,0,1,0,0,1,0,0];              
Activation(:,3)=[0,0,1,1,0,0,1,0,0,1,0,0]; 

Activation(:,4)=[1,0,0,0,1,0,0,1,0,0,1,0];                %Congruent     (2)     
Activation(:,5)=[0,1,0,0,1,0,0,1,0,0,1,0];              
Activation(:,6)=[0,0,1,0,1,0,0,1,0,0,1,0];

Activation(:,7)=[1,0,0,0,0,1,0,0,1,0,0,1];                %Congruent     (3)         
Activation(:,8)=[0,1,0,0,0,1,0,0,1,0,0,1];              
Activation(:,9)=[0,0,1,0,0,1,0,0,1,0,0,1]; 

Activation(:,10)=[1,0,0,1,0,0,0,1,0,1,0,0];               %First dimension 1
Activation(:,11)=[1,0,0,1,0,0,0,0,1,1,0,0];                  
Activation(:,12)=[1,0,0,1,0,0,1,0,0,0,1,0];                
Activation(:,13)=[1,0,0,1,0,0,0,1,0,0,1,0];                 
Activation(:,14)=[1,0,0,1,0,0,0,0,1,0,1,0];                  
Activation(:,15)=[1,0,0,1,0,0,1,0,0,0,0,1];            
Activation(:,16)=[1,0,0,1,0,0,0,1,0,0,0,1];           
Activation(:,17)=[1,0,0,1,0,0,0,0,1,0,0,1]; 

Activation(:,18)=[1,0,0,0,1,0,1,0,0,1,0,0];               %First dimension 2
Activation(:,19)=[1,0,0,0,1,0,0,1,0,1,0,0];                  
Activation(:,20)=[1,0,0,0,1,0,0,0,1,1,0,0];                
Activation(:,21)=[1,0,0,0,1,0,1,0,0,0,1,0];                 
Activation(:,22)=[1,0,0,0,1,0,0,0,1,0,1,0];                  
Activation(:,23)=[1,0,0,0,1,0,1,0,0,0,0,1];            
Activation(:,24)=[1,0,0,0,1,0,0,1,0,0,0,1];           
Activation(:,25)=[1,0,0,0,1,0,0,0,1,0,0,1]; 

Activation(:,26)=[1,0,0,0,0,1,1,0,0,1,0,0];               %First dimension 3
Activation(:,27)=[1,0,0,0,0,1,0,1,0,1,0,0];                  
Activation(:,28)=[1,0,0,0,0,1,0,0,1,1,0,0];                
Activation(:,29)=[1,0,0,0,0,1,1,0,0,0,1,0];
Activation(:,30)=[1,0,0,0,0,1,0,1,0,0,1,0];
Activation(:,31)=[1,0,0,0,0,1,0,0,1,0,1,0];
Activation(:,32)=[1,0,0,0,0,1,1,0,0,0,0,1];            
Activation(:,33)=[1,0,0,0,0,1,0,1,0,0,0,1];           

Activation(:,34)=[0,1,0,1,0,0,0,1,0,1,0,0];               %Second dimension 1
Activation(:,35)=[0,1,0,1,0,0,0,0,1,1,0,0];                  
Activation(:,36)=[0,1,0,1,0,0,1,0,0,0,1,0];                
Activation(:,37)=[0,1,0,1,0,0,0,1,0,0,1,0];                 
Activation(:,38)=[0,1,0,1,0,0,0,0,1,0,1,0];                  
Activation(:,39)=[0,1,0,1,0,0,1,0,0,0,0,1];            
Activation(:,40)=[0,1,0,1,0,0,0,1,0,0,0,1];           
Activation(:,41)=[0,1,0,1,0,0,0,0,1,0,0,1]; 

Activation(:,42)=[0,1,0,0,1,0,1,0,0,1,0,0];               %Second dimension 2
Activation(:,43)=[0,1,0,0,1,0,0,1,0,1,0,0];                  
Activation(:,44)=[0,1,0,0,1,0,0,0,1,1,0,0];                
Activation(:,45)=[0,1,0,0,1,0,1,0,0,0,1,0];                 
Activation(:,46)=[0,1,0,0,1,0,0,0,1,0,1,0];                  
Activation(:,47)=[0,1,0,0,1,0,1,0,0,0,0,1];            
Activation(:,48)=[0,1,0,0,1,0,0,1,0,0,0,1];           
Activation(:,49)=[0,1,0,0,1,0,0,0,1,0,0,1]; 

Activation(:,50)=[0,1,0,0,0,1,1,0,0,1,0,0];               %Second dimension 3
Activation(:,51)=[0,1,0,0,0,1,0,1,0,1,0,0];                  
Activation(:,52)=[0,1,0,0,0,1,0,0,1,1,0,0];                
Activation(:,53)=[0,1,0,0,0,1,1,0,0,0,1,0];
Activation(:,54)=[0,1,0,0,0,1,0,1,0,0,1,0];
Activation(:,55)=[0,1,0,0,0,1,0,0,1,0,1,0];
Activation(:,56)=[0,1,0,0,0,1,1,0,0,0,0,1];            
Activation(:,57)=[0,1,0,0,0,1,0,1,0,0,0,1]; 
          
Activation(:,58)=[0,0,1,1,0,0,0,1,0,1,0,0];               %Third dimension 1
Activation(:,59)=[0,0,1,1,0,0,0,0,1,1,0,0];                  
Activation(:,60)=[0,0,1,1,0,0,1,0,0,0,1,0];                
Activation(:,61)=[0,0,1,1,0,0,0,1,0,0,1,0];                 
Activation(:,62)=[0,0,1,1,0,0,0,0,1,0,1,0];                  
Activation(:,63)=[0,0,1,1,0,0,1,0,0,0,0,1];            
Activation(:,64)=[0,0,1,1,0,0,0,1,0,0,0,1];           
Activation(:,65)=[0,0,1,1,0,0,0,0,1,0,0,1]; 

Activation(:,66)=[0,0,1,0,1,0,1,0,0,1,0,0];               %Third dimension 2
Activation(:,67)=[0,0,1,0,1,0,0,1,0,1,0,0];                  
Activation(:,68)=[0,0,1,0,1,0,0,0,1,1,0,0];                
Activation(:,69)=[0,0,1,0,1,0,1,0,0,0,1,0];                 
Activation(:,70)=[0,0,1,0,1,0,0,0,1,0,1,0];                  
Activation(:,71)=[0,0,1,0,1,0,1,0,0,0,0,1];            
Activation(:,72)=[0,0,1,0,1,0,0,1,0,0,0,1];           
Activation(:,73)=[0,0,1,0,1,0,0,0,1,0,0,1]; 

Activation(:,74)=[0,0,1,0,0,1,1,0,0,1,0,0];               %Third dimension 3
Activation(:,75)=[0,0,1,0,0,1,0,1,0,1,0,0];                  
Activation(:,76)=[0,0,1,0,0,1,0,0,1,1,0,0];                
Activation(:,77)=[0,0,1,0,0,1,1,0,0,0,1,0];
Activation(:,78)=[0,0,1,0,0,1,0,1,0,0,1,0];
Activation(:,79)=[0,0,1,0,0,1,0,0,1,0,1,0];
Activation(:,80)=[0,0,1,0,0,1,1,0,0,0,0,1];            
Activation(:,81)=[0,0,1,0,0,1,0,1,0,0,0,1]; 

%Objectives at output layer
Objective=zeros(nResp,nInput,Tr); 
R1=[1:3, 10:17, 34:41, 58:65];
R2=[4:6, 18:25, 42:49, 66:73];
R3=[7:9, 26:33, 50:57, 74:81];
Objective(1,R1,[part1, part4])=1;
Objective(2,R2,[part1, part4])=1;
Objective(3,R3,[part1, part4])=1;
Objective(2,R1,[part2, part5])=1;
Objective(3,R2,[part2, part5])=1;
Objective(1,R3,[part2, part5])=1;
Objective(3,R1,[part3, part6])=1;
Objective(1,R2,[part3, part6])=1;
Objective(2,R3,[part3, part6])=1;

%% simulation loops
for b=1:betas
for r=1:Rep

%% Processing unit
%Positive phase
Phase_Input_plus=zeros(nStim,2,T,Tr); %phase neurons input layer
Rate_Input_plus=zeros(nStim,T,Tr);    %rate neurons input layer

Phase_M1_plus=zeros(nM1,2,T,Tr);     %phase neurons hidden module 1
Rate_M1_plus=zeros(nM1,T,Tr);        %rate neurons hidden module 1

Phase_M2_plus=zeros(nM2,2,T,Tr);     %phase neurons hidden module 2
Rate_M2_plus=zeros(nM2,T,Tr);        %rate neurons hidden module 2

Phase_M3_plus=zeros(nM3,2,T,Tr);     %phase neurons hidden module 2
Rate_M3_plus=zeros(nM3,T,Tr);        %rate neurons hidden module 2

Phase_Out_plus=zeros(nResp,2,T,Tr);  %phase neurons output layer
Rate_Out_plus=zeros(nResp,T,Tr);     %rate neurons output layer

net_M1_plus=zeros(nM1,T,Tr);         %net_input received by hidden nodes M1
net_M2_plus=zeros(nM2,T,Tr);         %net_input received by hidden nodes M2
net_M3_plus=zeros(nM3,T,Tr);         %net_input received by hidden nodes M2

%Negative phase all nodes have 2 values per iteration because of bidirectional activation flow
Phase_Input_min=zeros(nStim,2,T,Tr,iterations,2); %phase neurons input layer
Rate_Input_min=zeros(nStim,T,Tr,iterations,2);    %rate neurons input layer

Phase_M1_min=zeros(nM1,2,T,Tr,iterations,2);     %phase neurons hidden module 1
Rate_M1_min=zeros(nM1,T,Tr,iterations,2);        %rate neurons hidden module 1

Phase_M2_min=zeros(nM2,2,T,Tr,iterations,2);     %phase neurons hidden module 1
Rate_M2_min=zeros(nM2,T,Tr,iterations,2);        %rate neurons hidden module 1

Phase_M3_min=zeros(nM3,2,T,Tr,iterations,2);     %phase neurons hidden module 1
Rate_M3_min=zeros(nM3,T,Tr,iterations,2);        %rate neurons hidden module 1

Phase_Out_min=zeros(nResp,2,T,Tr,iterations,2);  %phase neurons output layer
Rate_Out_min=zeros(nResp,T,Tr,iterations,2);     %rate neurons output layer

net_M1_min=zeros(nM1,T,Tr,iterations);         %net_input received by hidden nodes M1
net_M2_min=zeros(nM2,T,Tr,iterations);         %net_input received by hidden nodes M2
net_M3_min=zeros(nM3,T,Tr,iterations);         %net_input received by hidden nodes M2
net_Out_min=zeros(nResp,T,Tr,iterations);      %net_input received by output nodes

%binarization of node activation
bin_M1=zeros(nM1,T,Tr,iterations);
bin_M2=zeros(nM2,T,Tr,iterations);
bin_M3=zeros(nM3,T,Tr,iterations);

%weights
W_IM1=zeros(nStim,nM1,Tr);      %input to hidden M1
W_IM2=zeros(nStim,nM2,Tr);      %input to hidden M2
W_IM3=zeros(nStim,nM3,Tr);      %input to hidden M3
W_M1O=zeros(nM1,nResp,Tr);      %hidden M1 to output
W_M2O=zeros(nM2,nResp,Tr);      %hidden M2 to output
W_M3O=zeros(nM2,nResp,Tr);      %hidden M3 to output

%random starting values for all weights
W_IM1(:,:,1)=rand(nStim,nM1)*2.5;   
W_IM2(:,:,1)=rand(nStim,nM2)*2.5;
W_IM3(:,:,1)=rand(nStim,nM2)*2.5;
W_M1O(:,:,1)=rand(nM1,nResp)*2.5;
W_M2O(:,:,1)=rand(nM2,nResp)*2.5;

%% Control unit
%choose random start module
Modules=1:3;
stm=datasample(Modules,1);

LFC=ones(4,Tr)*-1;         %LFC nodes
LFC(1,1)=1;
LFC(stm+1,1)=1;
Inhibition=zeros(length(Modules),Tr);

% Note!: The model pMFC = ACC in the code
ACC_plus=zeros(2,T,Tr);                       %pMFC phase neurons pos phase
ACC_min=zeros(2,T,Tr,iterations,2);           %pMFC phase neurons neg phase
Be_plus=zeros(T,Tr);                          %bernoulli pos phase
Be_min=zeros(T,Tr,iterations,2);              %bernoulli neg phase

%% RL unit
rew=zeros(1,Tr);            %reward/accuracy record
V=zeros(1,Tr);              %value neuron
S=zeros(1,Tr);              %switch neuron
E=zeros(nmod,Tr);           %value weights with LFC
E(:,1)=0.5;                 %initial values
negPE=zeros(1,Tr);          %negative prediction error
posPE=zeros(1,Tr);          %positive prediction error

%% Input to model

%list of input patterns

In=repmat(1:nInput,6,(POT(1)));

%randomization for each part seperately
Input=zeros(1,Tr);                       
Input(1,part1)=In(1,randperm(POT(1)));
Input(1,part2)=In(2,randperm(POT(1)));
Input(1,part3)=In(3,randperm(POT(1)));
Input(1,part4)=In(4,randperm(POT(1)));
Input(1,part5)=In(5,randperm(POT(1)));
Input(1,part6)=In(6,randperm(POT(1)));

%% Learning
delta_M1out=zeros(nM1,nResp,Tr);      %delta M1 to output
delta_M2out=zeros(nM2,nResp,Tr);      %delta M2 to output
delta_M3out=zeros(nM3,nResp,Tr);      %delta M2 to output
delta_M1=zeros(nStim,nM1,Tr);         %delta Input to M1
delta_M2=zeros(nStim,nM2,Tr);         %delta Input to M2
delta_M3=zeros(nStim,nM3,Tr);         %delta Input to M2
                   
Errorscore=zeros(nResp,Tr);           %error score computed at negative phase

%% other
%starting points of oscillations
start_Input=rand(nStim,2,1,1);   
start_M1=rand(nM1,2,1,1);
start_M2=rand(nM2,2,1,1);
start_M3=rand(nM3,2,1,1);
start_Out=rand(nResp,2,1,1); 
start_ACC=rand(2,1,1);    

%assign to phase code neurons
Phase_Input_plus(:,:,1,1)=start_Input;        
Phase_M1_plus(:,:,1,1)=start_M1;
Phase_M2_plus(:,:,1,1)=start_M2;
Phase_M3_plus(:,:,1,1)=start_M3;
Phase_Out_plus(:,:,1,1)=start_Out;
ACC_plus(:,1,1)=start_ACC;

%radius
%positive phase
r2_Input_plus=zeros(nStim,T,Tr);        
r2_M1_plus=zeros(nM1,T,Tr);
r2_M2_plus=zeros(nM2,T,Tr);
r2_M3_plus=zeros(nM3,T,Tr);
r2_ACC_plus=zeros(T,Tr);
r2_Out_plus=zeros(nResp,T,Tr);
%negative phase
r2_Input_min=zeros(nStim,T,Tr,iterations,2);        
r2_M1_min=zeros(nM1,T,Tr,iterations,2);
r2_M2_min=zeros(nM2,T,Tr,iterations,2);
r2_M3_min=zeros(nM3,T,Tr,iterations,2);
r2_ACC_min=zeros(T,Tr,iterations,2);
r2_Out_min=zeros(nResp,T,Tr,iterations,2);
r2_Out_bis=zeros(nResp,T,Tr,iterations,2);

%% extra
Z=zeros(nStim,Tr);                      %input matrix
Q=zeros(nResp,Tr);                      %output matrix pos phase
Q_min=zeros(nResp,Tr,iterations);       %output matrix neg phase
response=zeros(nResp,Tr,iterations);    %response record
sync_IM1=zeros(nStim,nM1,Tr);           %sync matrix (correlations)
sync_IM2=zeros(nStim,nM2,Tr);           %sync matrix (correlations)
sync_IM3=zeros(nStim,nM2,Tr);           %sync matrix (correlations)
Hit_plus=zeros(T,Tr);                   %Hit record pos phase                 
Hit_min=zeros(T,Tr,iterations,2);       %Hit record neg phase

%% Model
 
%trial loop
for trial=1:Tr
    
    %starting values phase nodes (end of previous trial)
    if trial>1          
        Phase_Input_plus(:,:,1,trial)=Phase_Input_min(:,:,time,trial-1,i,2);
        Phase_M1_plus(:,:,1,trial)=Phase_M1_min(:,:,time,trial-1,i,2);
        Phase_M2_plus(:,:,1,trial)=Phase_M2_min(:,:,time,trial-1,i,2);
        Phase_M3_plus(:,:,1,trial)=Phase_M3_min(:,:,time,trial-1,i,2);
        Phase_Out_plus(:,:,1,trial)=Phase_Out_min(:,:,time,trial-1,i,2);
        ACC_plus(:,1,trial)=ACC_min(:,time,trial-1,i,2);
    end; 
    
    %Assigning input and output pattern
    Z(:,trial)=Activation(:,Input(1,trial));
    Q(:,trial)=squeeze(Objective(:,Input(1,trial),trial));
    
    %positive phase
    for time=1:T 
            
            %computing radius of oscillations
            r2_Input_plus(:,time,trial)=squeeze(dot(Phase_Input_plus(:,:,time,trial),Phase_Input_plus(:,:,time,trial),2));     %Input layer
            r2_M1_plus(:,time,trial)=squeeze(dot(Phase_M1_plus(:,:,time,trial),Phase_M1_plus(:,:,time,trial),2));              %Hidden layer M1
            r2_M2_plus(:,time,trial)=squeeze(dot(Phase_M2_plus(:,:,time,trial),Phase_M2_plus(:,:,time,trial),2));              %Hidden layer M1
            r2_M3_plus(:,time,trial)=squeeze(dot(Phase_M3_plus(:,:,time,trial),Phase_M3_plus(:,:,time,trial),2));              %Hidden layer M1
            r2_Out_plus(:,time,trial)=squeeze(dot(Phase_Out_plus(:,:,time,trial),Phase_Out_plus(:,:,time,trial),2));           %Output layer
            r2_ACC_plus(time,trial)=dot(ACC_plus(:,time,trial),ACC_plus(:,time,trial));                                        %pMFC
            
            %updating phase code neurons
            %Input
            Phase_Input_plus(:,1,time+1,trial)=Phase_Input_plus(:,1,time,trial)-Cg*Phase_Input_plus(:,2,time,trial)-damp*(r2_Input_plus(:,time,trial)>r2max).*Phase_Input_plus(:,1,time,trial); % excitatory cells
            Phase_Input_plus(:,2,time+1,trial)=Phase_Input_plus(:,2,time,trial)+Cg*Phase_Input_plus(:,1,time,trial)-damp*(r2_Input_plus(:,time,trial)>r2max).*Phase_Input_plus(:,2,time,trial); % inhibitory cells
            %Hidden M1
            Phase_M1_plus(:,1,time+1,trial)=Phase_M1_plus(:,1,time,trial)-Cg*Phase_M1_plus(:,2,time,trial)-damp*(r2_M1_plus(:,time,trial)>r2max).*Phase_M1_plus(:,1,time,trial); % excitatory cells
            Phase_M1_plus(:,2,time+1,trial)=Phase_M1_plus(:,2,time,trial)+Cg*Phase_M1_plus(:,1,time,trial)-damp*(r2_M1_plus(:,time,trial)>r2max).*Phase_M1_plus(:,2,time,trial); % inhibitory cells
            %Hidden M2
            Phase_M2_plus(:,1,time+1,trial)=Phase_M2_plus(:,1,time,trial)-Cg*Phase_M2_plus(:,2,time,trial)-damp*(r2_M2_plus(:,time,trial)>r2max).*Phase_M2_plus(:,1,time,trial); % excitatory cells
            Phase_M2_plus(:,2,time+1,trial)=Phase_M2_plus(:,2,time,trial)+Cg*Phase_M2_plus(:,1,time,trial)-damp*(r2_M2_plus(:,time,trial)>r2max).*Phase_M2_plus(:,2,time,trial); % inhibitory cells
            %Hidden M3
            Phase_M3_plus(:,1,time+1,trial)=Phase_M3_plus(:,1,time,trial)-Cg*Phase_M3_plus(:,2,time,trial)-damp*(r2_M3_plus(:,time,trial)>r2max).*Phase_M3_plus(:,1,time,trial); % excitatory cells
            Phase_M3_plus(:,2,time+1,trial)=Phase_M3_plus(:,2,time,trial)+Cg*Phase_M3_plus(:,1,time,trial)-damp*(r2_M3_plus(:,time,trial)>r2max).*Phase_M3_plus(:,2,time,trial); % inhibitory cells
            %Output
            Phase_Out_plus(:,1,time+1,trial)=Phase_Out_plus(:,1,time,trial)-Cg*Phase_Out_plus(:,2,time,trial)-damp*(r2_Out_plus(:,time,trial)>r2max).*Phase_Out_plus(:,1,time,trial); % excitatory cells
            Phase_Out_plus(:,2,time+1,trial)=Phase_Out_plus(:,2,time,trial)+Cg*Phase_Out_plus(:,1,time,trial)-damp*(r2_Out_plus(:,time,trial)>r2max).*Phase_Out_plus(:,2,time,trial); % inhibitory cells
            %pMFC
            ACC_plus(1,time+1,trial)=ACC_plus(1,time,trial)-Ct*ACC_plus(2,time,trial)-damp_acc*(r2_ACC_plus(time,trial)>r2_acc)*ACC_plus(1,time,trial); % pMFC exc cell
            ACC_plus(2,time+1,trial)=ACC_plus(2,time,trial)+Ct*ACC_plus(1,time,trial)-damp_acc*(r2_ACC_plus(time,trial)>r2_acc)*ACC_plus(2,time,trial); % pMFC inh cell
            
            %bernoulli process in pMFC rate
            Be_plus(time,trial)=1/(1+exp(-acc_slope*(ACC_plus(1,time,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be_plus(time,trial)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_plus(time,trial)=1;   %record hit is given
                Phase_Input_plus(:,:,time+1,trial)=decay*Phase_Input_plus(:,:,time,trial)+ LFC(1,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_plus(:,:,time+1,trial)=decay*Phase_Out_plus(:,:,time,trial)+ LFC(1,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_plus(:,:,time+1,trial)=decay*Phase_M1_plus(:,:,time,trial)+LFC(2,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_plus(:,:,time+1,trial)=decay*Phase_M2_plus(:,:,time,trial)+LFC(3,trial)*(ones(nM2,1))* Gaussian;
                Phase_M3_plus(:,:,time+1,trial)=decay*Phase_M3_plus(:,:,time,trial)+LFC(4,trial)*(ones(nM3,1))* Gaussian;
            end;
            
            %updating rate code neurons
            %Input
            Rate_Input_plus(:,time,trial)=(Z(:,trial)).*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input_plus(:,1,time,trial))-0.6))));%Input layer
            %Output
            Rate_Out_plus(:,time,trial)=(Q(:,trial)) .* (ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out_plus(:,1,time,trial))-0.6)))); %Output layer
            %Hidden M1
            net_M1_plus(:,time,trial)=W_IM1(:,:,trial)'* Rate_Input_plus(:,time,trial) + W_M1O(:,:,trial)*Rate_Out_plus(:,time,trial)-bias; %net input
            Rate_M1_plus(:,time,trial)=(ones(nM1,1)./(ones(nM1,1) + exp(-net_M1_plus(:,time,trial)))) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1_plus(:,1,time,trial))-0.6)))); %M1 activation
            %Hidden M2
            net_M2_plus(:,time,trial)=W_IM2(:,:,trial)'* Rate_Input_plus(:,time,trial)+ W_M2O(:,:,trial)*Rate_Out_plus(:,time,trial)-bias; %net input
            Rate_M2_plus(:,time,trial)=(ones(nM2,1)./(ones(nM2,1) + exp(-net_M2_plus(:,time,trial)))) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2_plus(:,1,time,trial))-0.6)))); %M2 activation
            %Hidden M3
            net_M3_plus(:,time,trial)=W_IM3(:,:,trial)'* Rate_Input_plus(:,time,trial)+ W_M3O(:,:,trial)*Rate_Out_plus(:,time,trial)-bias; %net input
            Rate_M3_plus(:,time,trial)=(ones(nM3,1)./(ones(nM3,1) + exp(-net_M3_plus(:,time,trial)))) .* (ones(nM3,1)./(ones(nM3,1)+exp(-5*(squeeze(Phase_M3_plus(:,1,time,trial))-0.6)))); %M2 activation
    end;
    
    %Negative phase
    for i=1:iterations
        
        if i==1 %take over end values of oscillations in positive phase 
            Phase_Input_min(:,:,1,trial,1,1)=Phase_Input_plus(:,:,time,trial);
            Phase_M1_min(:,:,1,trial,1,1)=Phase_M1_plus(:,:,time,trial);
            Phase_M2_min(:,:,1,trial,1,1)=Phase_M2_plus(:,:,time,trial);
            Phase_M3_min(:,:,1,trial,1,1)=Phase_M3_plus(:,:,time,trial);            
            Phase_Out_min(:,:,1,trial,1,1)=Phase_Out_plus(:,:,time,trial);
            ACC_min(:,1,trial,1,1)=ACC_plus(:,time,trial);
        else %take over end values of oscillations in previous iteration 
            Phase_Input_min(:,:,1,trial,i,1)=Phase_Input_min(:,:,time,trial,i-1,2);
            Phase_M1_min(:,:,1,trial,i,1)=Phase_M1_min(:,:,time,trial,i-1,2);
            Phase_M2_min(:,:,1,trial,i,1)=Phase_M2_min(:,:,time,trial,i-1,2);
            Phase_M3_min(:,:,1,trial,i,1)=Phase_M3_min(:,:,time,trial,i-1,2);
            Phase_Out_min(:,:,1,trial,i,1)=Phase_Out_min(:,:,time,trial,i-1,2);
            ACC_min(:,1,trial,i,1)=ACC_min(:,time,trial,i-1,2);
        end;
        
    % step 1: In and output to hidden layer   
    for time=1:T%ITI:T  
            %computing radius of oscillations
            r2_Input_min(:,time,trial,i,1)=squeeze(dot(Phase_Input_min(:,:,time,trial,i,1),Phase_Input_min(:,:,time,trial,i,1),2));     %Input layer
            r2_M1_min(:,time,trial,i,1)=squeeze(dot(Phase_M1_min(:,:,time,trial,i,1),Phase_M1_min(:,:,time,trial,i,1),2));              %Hidden layer M1
            r2_M2_min(:,time,trial,i,1)=squeeze(dot(Phase_M2_min(:,:,time,trial,i,1),Phase_M2_min(:,:,time,trial,i,1),2));              %Hidden layer M2
            r2_M3_min(:,time,trial,i,1)=squeeze(dot(Phase_M3_min(:,:,time,trial,i,1),Phase_M3_min(:,:,time,trial,i,1),2));              %Hidden layer M3
            r2_Out_min(:,time,trial,i,1)=squeeze(dot(Phase_Out_min(:,:,time,trial,i,1),Phase_Out_min(:,:,time,trial,i,1),2));           %Output layer
            r2_ACC_min(time,trial,i,1)=dot(ACC_min(:,time,trial,i,1),ACC_min(:,time,trial,i,1));                                        %pMFC
            
            %updating phase code neurons
            %Input
            Phase_Input_min(:,1,time+1,trial,i,1)=Phase_Input_min(:,1,time,trial,i,1)-Cg*Phase_Input_min(:,2,time,trial,i,1)-damp*(r2_Input_min(:,time,trial,i,1)>r2max).*Phase_Input_min(:,1,time,trial,i,1); % excitatory cells
            Phase_Input_min(:,2,time+1,trial,i,1)=Phase_Input_min(:,2,time,trial,i,1)+Cg*Phase_Input_min(:,1,time,trial,i,1)-damp*(r2_Input_min(:,time,trial,i,1)>r2max).*Phase_Input_min(:,2,time,trial,i,1); % inhibitory cells
            %Hidden M1
            Phase_M1_min(:,1,time+1,trial,i,1)=Phase_M1_min(:,1,time,trial,i,1)-Cg*Phase_M1_min(:,2,time,trial,i,1)-damp*(r2_M1_min(:,time,trial,i,1)>r2max).*Phase_M1_min(:,1,time,trial,i,1); % excitatory cells
            Phase_M1_min(:,2,time+1,trial,i,1)=Phase_M1_min(:,2,time,trial,i,1)+Cg*Phase_M1_min(:,1,time,trial,i,1)-damp*(r2_M1_min(:,time,trial,i,1)>r2max).*Phase_M1_min(:,2,time,trial,i,1); % inhibitory cells
            %Hidden M2
            Phase_M2_min(:,1,time+1,trial,i,1)=Phase_M2_min(:,1,time,trial,i,1)-Cg*Phase_M2_min(:,2,time,trial,i,1)-damp*(r2_M2_min(:,time,trial,i,1)>r2max).*Phase_M2_min(:,1,time,trial,i,1); % excitatory cells
            Phase_M2_min(:,2,time+1,trial,i,1)=Phase_M2_min(:,2,time,trial,i,1)+Cg*Phase_M2_min(:,1,time,trial,i,1)-damp*(r2_M2_min(:,time,trial,i,1)>r2max).*Phase_M2_min(:,2,time,trial,i,1); % inhibitory cells
            %Hidden M3
            Phase_M3_min(:,1,time+1,trial,i,1)=Phase_M3_min(:,1,time,trial,i,1)-Cg*Phase_M3_min(:,2,time,trial,i,1)-damp*(r2_M3_min(:,time,trial,i,1)>r2max).*Phase_M3_min(:,1,time,trial,i,1); % excitatory cells
            Phase_M3_min(:,2,time+1,trial,i,1)=Phase_M3_min(:,2,time,trial,i,1)+Cg*Phase_M3_min(:,1,time,trial,i,1)-damp*(r2_M3_min(:,time,trial,i,1)>r2max).*Phase_M3_min(:,2,time,trial,i,1); % inhibitory cells
            %Output
            Phase_Out_min(:,1,time+1,trial,i,1)=Phase_Out_min(:,1,time,trial,i,1)-Cg*Phase_Out_min(:,2,time,trial,i,1)-damp*(r2_Out_min(:,time,trial,i,1)>r2max).*Phase_Out_min(:,1,time,trial,i,1); % excitatory cells
            Phase_Out_min(:,2,time+1,trial,i,1)=Phase_Out_min(:,2,time,trial,i,1)+Cg*Phase_Out_min(:,1,time,trial,i,1)-damp*(r2_Out_min(:,time,trial,i,1)>r2max).*Phase_Out_min(:,2,time,trial,i,1); % inhibitory cells
            %pMFC
            ACC_min(1,time+1,trial,i,1)=ACC_min(1,time,trial,i,1)-Ct*ACC_min(2,time,trial,i,1)-damp_acc*(r2_ACC_min(time,trial,i,1)>r2_acc)*ACC_min(1,time,trial,i,1); % pMFC exc cell
            ACC_min(2,time+1,trial,i,1)=ACC_min(2,time,trial,i,1)+Ct*ACC_min(1,time,trial,i,1)-damp_acc*(r2_ACC_min(time,trial,i,1)>r2_acc)*ACC_min(2,time,trial,i,1); % pMFC inh cell
            
            %bernoulli process in pMFC rate
            Be_min(time,trial,i,1)=1/(1+exp(-acc_slope*(ACC_min(1,time,trial,i,1)-1)));
            prob=rand;
            
            %burst
            if prob<Be_min(time,trial,i,1)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_min(time,trial,i,1)=1;   %record hit is given
                Phase_Input_min(:,:,time+1,trial,i,1)=decay*Phase_Input_min(:,:,time,trial,i,1)+ LFC(1,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_min(:,:,time+1,trial,i,1)=decay*Phase_Out_min(:,:,time,trial,i,1)+ LFC(1,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_min(:,:,time+1,trial,i,1)=decay*Phase_M1_min(:,:,time,trial,i,1)+LFC(2,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_min(:,:,time+1,trial,i,1)=decay*Phase_M2_min(:,:,time,trial,i,1)+LFC(3,trial)*(ones(nM2,1))* Gaussian;
                Phase_M3_min(:,:,time+1,trial,i,1)=decay*Phase_M3_min(:,:,time,trial,i,1)+LFC(4,trial)*(ones(nM3,1))* Gaussian;
            end;
            
            %updating rate code neurons
            %Input
            Rate_Input_min(:,time,trial,i,1)=(Z(:,trial)).*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input_min(:,1,time,trial,i,1))-0.6))));%Input layer
            Rate_Out_min(:,time,trial,i,1)=squeeze(Q_min(:,trial,i)).*(ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out_min(:,1,time,trial,i,1))-0.6))));
            %Hidden M1
            net_M1_min(:,time,trial,i)=W_IM1(:,:,trial)'* Rate_Input_min(:,time,trial,i,1)+W_M1O(:,:,trial)*Rate_Out_min(:,time,trial,i,1)-bias; %net input
            Rate_M1_min(:,time,trial,i,1)=(ones(nM1,1)./(ones(nM1,1) + exp(-net_M1_min(:,time,trial,i)))) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1_min(:,1,time,trial,i,1))-0.6)))); %M1 activation
            %Hidden M2
            net_M2_min(:,time,trial,i)=W_IM2(:,:,trial)'* Rate_Input_min(:,time,trial,i,1)+W_M2O(:,:,trial)*Rate_Out_min(:,time,trial,i,1)-bias; %net input
            Rate_M2_min(:,time,trial,i,1)=(ones(nM2,1)./(ones(nM2,1) + exp(-net_M2_min(:,time,trial,i)))) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2_min(:,1,time,trial,i,1))-0.6)))); %M2 activation
            %Hidden M3
            net_M3_min(:,time,trial,i)=W_IM3(:,:,trial)'* Rate_Input_min(:,time,trial,i,1)+W_M3O(:,:,trial)*Rate_Out_min(:,time,trial,i,1)-bias; %net input
            Rate_M3_min(:,time,trial,i,1)=(ones(nM3,1)./(ones(nM3,1) + exp(-net_M3_min(:,time,trial,i)))) .* (ones(nM3,1)./(ones(nM3,1)+exp(-5*(squeeze(Phase_M3_min(:,1,time,trial,i,1))-0.6)))); %M2 activation            
    end;
    %stochastic binarization
    bin_M1(:,trial,i)=max(Rate_M1_min(:,:,trial,i,1),[],2)>rand(nM1,1);
    bin_M2(:,trial,i)=max(Rate_M2_min(:,:,trial,i,1),[],2)>rand(nM2,1);
    bin_M3(:,trial,i)=max(Rate_M3_min(:,:,trial,i,1),[],2)>rand(nM3,1);  
    
    %step 2: hidden back to output layer
    %take over end values of before
    Phase_Input_min(:,:,1,trial,i,2)=Phase_Input_min(:,:,time,trial,i,1);
    Phase_M1_min(:,:,1,trial,i,2)=Phase_M1_min(:,:,time,trial,i,1);
    Phase_M2_min(:,:,1,trial,i,2)=Phase_M2_min(:,:,time,trial,i,1);
    Phase_M3_min(:,:,1,trial,i,2)=Phase_M3_min(:,:,time,trial,i,1);    
    Phase_Out_min(:,:,1,trial,i,2)=Phase_Out_min(:,:,time,trial,i,1);
    ACC_min(:,1,trial,i,2)=ACC_min(:,time,trial,i,1);
        
    for time=1:T  
            %computing radius of oscillations
            r2_Input_min(:,time,trial,i,2)=squeeze(dot(Phase_Input_min(:,:,time,trial,i,2),Phase_Input_min(:,:,time,trial,i,2),2));     %Input layer
            r2_M1_min(:,time,trial,i,2)=squeeze(dot(Phase_M1_min(:,:,time,trial,i,2),Phase_M1_min(:,:,time,trial,i,2),2));              %Hidden layer M1
            r2_M2_min(:,time,trial,i,2)=squeeze(dot(Phase_M2_min(:,:,time,trial,i,2),Phase_M2_min(:,:,time,trial,i,2),2));              %Hidden layer M1
            r2_M3_min(:,time,trial,i,2)=squeeze(dot(Phase_M3_min(:,:,time,trial,i,2),Phase_M3_min(:,:,time,trial,i,2),2));              %Hidden layer M1            
            r2_Out_min(:,time,trial,i,2)=squeeze(dot(Phase_Out_min(:,:,time,trial,i,2),Phase_Out_min(:,:,time,trial,i,2),2));           %Output layer
            r2_ACC_min(time,trial,i,2)=dot(ACC_min(:,time,trial,i,2),ACC_min(:,time,trial,i,2));                                                %pMFC
            
            %updating phase code neurons
            %Input
            Phase_Input_min(:,1,time+1,trial,i,2)=Phase_Input_min(:,1,time,trial,i,2)-Cg*Phase_Input_min(:,2,time,trial,i,2)-damp*(r2_Input_min(:,time,trial,i,2)>r2max).*Phase_Input_min(:,1,time,trial,i,2); % excitatory cells
            Phase_Input_min(:,2,time+1,trial,i,2)=Phase_Input_min(:,2,time,trial,i,2)+Cg*Phase_Input_min(:,1,time,trial,i,2)-damp*(r2_Input_min(:,time,trial,i,2)>r2max).*Phase_Input_min(:,2,time,trial,i,2); % inhibitory cells
            %Hidden M1
            Phase_M1_min(:,1,time+1,trial,i,2)=Phase_M1_min(:,1,time,trial,i,2)-Cg*Phase_M1_min(:,2,time,trial,i,2)-damp*(r2_M1_min(:,time,trial,i,2)>r2max).*Phase_M1_min(:,1,time,trial,i,2); % excitatory cells
            Phase_M1_min(:,2,time+1,trial,i,2)=Phase_M1_min(:,2,time,trial,i,2)+Cg*Phase_M1_min(:,1,time,trial,i,2)-damp*(r2_M1_min(:,time,trial,i,2)>r2max).*Phase_M1_min(:,2,time,trial,i,2); % inhibitory cells
            %Hidden M2
            Phase_M2_min(:,1,time+1,trial,i,2)=Phase_M2_min(:,1,time,trial,i,2)-Cg*Phase_M2_min(:,2,time,trial,i,2)-damp*(r2_M2_min(:,time,trial,i,2)>r2max).*Phase_M2_min(:,1,time,trial,i,2); % excitatory cells
            Phase_M2_min(:,2,time+1,trial,i,2)=Phase_M2_min(:,2,time,trial,i,2)+Cg*Phase_M2_min(:,1,time,trial,i,2)-damp*(r2_M2_min(:,time,trial,i,2)>r2max).*Phase_M2_min(:,2,time,trial,i,2); % inhibitory cells
            %Hidden M3
            Phase_M3_min(:,1,time+1,trial,i,2)=Phase_M3_min(:,1,time,trial,i,2)-Cg*Phase_M3_min(:,2,time,trial,i,2)-damp*(r2_M3_min(:,time,trial,i,2)>r2max).*Phase_M3_min(:,1,time,trial,i,2); % excitatory cells
            Phase_M3_min(:,2,time+1,trial,i,2)=Phase_M3_min(:,2,time,trial,i,2)+Cg*Phase_M3_min(:,1,time,trial,i,2)-damp*(r2_M3_min(:,time,trial,i,2)>r2max).*Phase_M3_min(:,2,time,trial,i,2); % inhibitory cells            
            %Output
            Phase_Out_min(:,1,time+1,trial,i,2)=Phase_Out_min(:,1,time,trial,i,2)-Cg*Phase_Out_min(:,2,time,trial,i,2)-damp*(r2_Out_min(:,time,trial,i,2)>r2max).*Phase_Out_min(:,1,time,trial,i,2); % excitatory cells
            Phase_Out_min(:,2,time+1,trial,i,2)=Phase_Out_min(:,2,time,trial,i,2)+Cg*Phase_Out_min(:,1,time,trial,i,2)-damp*(r2_Out_min(:,time,trial,i,2)>r2max).*Phase_Out_min(:,2,time,trial,i,2); % inhibitory cells
            %pMFC
            ACC_min(1,time+1,trial,i,2)=ACC_min(1,time,trial,i,2)-Ct*ACC_min(2,time,trial,i,2)-damp_acc*(r2_ACC_min(time,trial,i,2)>r2_acc)*ACC_min(1,time,trial,i,2); % pMFC exc cell
            ACC_min(2,time+1,trial,i,2)=ACC_min(2,time,trial,i,2)+Ct*ACC_min(1,time,trial,i,2)-damp_acc*(r2_ACC_min(time,trial,i,2)>r2_acc)*ACC_min(2,time,trial,i,2); % pMFC inh cell
            
            %bernoulli process in pMFC rate
            Be_min(time,trial,i,2)=1/(1+exp(-acc_slope*(ACC_min(1,time,trial,i,2)-1)));
            prob=rand;
            
            %burst
            if prob<Be_min(time,trial,i,2)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_min(time,trial,i,2)=1;   %record hit is given
                Phase_Input_min(:,:,time+1,trial,i,2)=decay*Phase_Input_min(:,:,time,trial,i,2)+ LFC(1,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_min(:,:,time+1,trial,i,2)=decay*Phase_Out_min(:,:,time,trial,i,2)+ LFC(1,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_min(:,:,time+1,trial,i,2)=decay*Phase_M1_min(:,:,time,trial,i,2)+LFC(2,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_min(:,:,time+1,trial,i,2)=decay*Phase_M2_min(:,:,time,trial,i,2)+LFC(3,trial)*(ones(nM2,1))* Gaussian;
                Phase_M3_min(:,:,time+1,trial,i,2)=decay*Phase_M3_min(:,:,time,trial,i,2)+LFC(4,trial)*(ones(nM3,1))* Gaussian;
            end;
            
            %updating rate code neurons
            %Input
            Rate_Input_min(:,time,trial,i,2)=Z(:,trial) .*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input_min(:,1,time,trial,i,2))-0.6))));%Input layer
            %Hidden M1
            Rate_M1_min(:,time,trial,i,2)=bin_M1(:,trial,i) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1_min(:,1,time,trial,i,2))-0.6)))); %M1 activation
            %Hidden M2
            Rate_M2_min(:,time,trial,i,2)=bin_M2(:,trial,i) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2_min(:,1,time,trial,i,2))-0.6)))); %M2 activation
            %Hidden M3
            Rate_M3_min(:,time,trial,i,2)=bin_M3(:,trial,i) .* (ones(nM3,1)./(ones(nM3,1)+exp(-5*(squeeze(Phase_M3_min(:,1,time,trial,i,2))-0.6)))); %M2 activation
            %Output
            net_Out_min(:,time,trial,i)=squeeze(W_M1O(:,:,trial))'*squeeze(Rate_M1_min(:,time,trial,i,2)) + squeeze(W_M2O(:,:,trial))'*squeeze(Rate_M2_min(:,time,trial,i,2))+ squeeze(W_M3O(:,:,trial))'*squeeze(Rate_M3_min(:,time,trial,i,2))-bias; %net input
            Rate_Out_min(:,time,trial,i,2)=(ones(nResp,1)./(ones(nResp,1) + exp(-net_Out_min(:,time,trial,i)))) .* (ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out_min(:,1,time,trial,i,2))-0.6))));%(exp(net_Out_min(:,time,trial,i))./sum(exp(net_Out_min(:,time,trial,i)))) %Output layer
    end;
    
    maxi=squeeze(max(Rate_Out_min(:,:,trial,i,2),[],2));
    [re,rid]=max(maxi);
    if rid==1
        response(1,trial,i)= 1;  
    elseif rid==2
        response(2,trial,i)= 1;
    elseif rid==3
        response(3,trial,i)= 1;    
    end;
    
    Q_min(:,trial,i+1)=response(:,trial,i);   
    end;
    
    %keep track of accuracy/reward
    if Q(:,trial)==response(:,trial,i)
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    %value neuron update
    V(1,trial)=E(:,trial)'* 0.5* (LFC(2:end,trial)+ones(nmod,1)); 
        
    %Prediction errors
    negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
    posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
    %Value weight update
    E(:,trial+1)= E(:,trial) + lp * V(1,trial) * (posPE(1,trial)-negPE(1,trial)) * 0.5 * (LFC(2:end,trial)+ones(nmod,1));
        
    %switch neuron update
    S(1,trial+1)=0.8*S(1,trial)+0.2*(negPE(1,trial));
    
    %LFC update
    if S(1,trial)>0.5
            
        Inhibition(stm,trial)=-2;
            
        LFC(2:4,trial+1)=ones(3,1)*-1;
            
        Cprob=E(:,trial)+Inhibition(:,trial);
            
        softmax=exp(Cprob)./sum(exp(Cprob));
        softprob=cumsum(softmax);
        p=rand;
        if rand<softprob(1)
            LFC(2,trial+1)=1;
            stm=1;
        elseif rand<softprob(2)
            LFC(3,trial+1)=1;
            stm=2;
        else
            LFC(4,trial+1)=1;
            stm=3;
        end;
            
        S(1,trial+1)=0;
            
    else
        LFC(2:4,trial+1)=LFC(2:4,trial);
    end;
        
    LFC(1,trial+1)=LFC(1,trial);
    
    %keep track of errorscore in negative phase
    Errorscore(:,trial)=(Q(:,trial)-squeeze(max(Rate_Out_min(:,:,trial,i-1,2),[],2))).^2;
    
    %compute weightchange
    delta_M1out(:,:,trial)=beta(1,b) *((max(Rate_Out_plus(:,:,trial),[],2)*max(Rate_M1_plus(:,:,trial),[],2)')'-(max(Rate_Out_min(:,:,trial,i-1,2),[],2)*max(Rate_M1_min(:,:,trial,i,1),[],2)')');
    delta_M2out(:,:,trial)=beta(1,b) *((max(Rate_Out_plus(:,:,trial),[],2)*max(Rate_M2_plus(:,:,trial),[],2)')'-(max(Rate_Out_min(:,:,trial,i-1,2),[],2)*max(Rate_M2_min(:,:,trial,i,1),[],2)')');
    delta_M3out(:,:,trial)=beta(1,b) *((max(Rate_Out_plus(:,:,trial),[],2)*max(Rate_M3_plus(:,:,trial),[],2)')'-(max(Rate_Out_min(:,:,trial,i-1,2),[],2)*max(Rate_M3_min(:,:,trial,i,1),[],2)')');
    delta_M1(:,:,trial)=beta(1,b) * ((max(Rate_Input_plus(:,:,trial),[],2)*max(Rate_M1_plus(:,:,trial),[],2)')-(max(Rate_Input_min(:,:,trial,i,2),[],2)*max(Rate_M1_min(:,:,trial,i,1),[],2)'));
    delta_M2(:,:,trial)=beta(1,b) * ((max(Rate_Input_plus(:,:,trial),[],2)*max(Rate_M2_plus(:,:,trial),[],2)')-(max(Rate_Input_min(:,:,trial,i,2),[],2)*max(Rate_M2_min(:,:,trial,i,1),[],2)'));
    delta_M3(:,:,trial)=beta(1,b) * ((max(Rate_Input_plus(:,:,trial),[],2)*max(Rate_M3_plus(:,:,trial),[],2)')-(max(Rate_Input_min(:,:,trial,i,2),[],2)*max(Rate_M3_min(:,:,trial,i,1),[],2)'));
    %change weights
    W_IM1(:,:,trial+1)=W_IM1(:,:,trial) + delta_M1(:,:,trial);
    W_IM2(:,:,trial+1)= W_IM2(:,:,trial) + delta_M2(:,:,trial);
    W_IM3(:,:,trial+1)= W_IM3(:,:,trial) + delta_M3(:,:,trial);
    W_M1O(:,:,trial+1)=W_M1O(:,:,trial) + delta_M1out(:,:,trial);
    W_M2O(:,:,trial+1)= W_M2O(:,:,trial) + delta_M2out(:,:,trial);
    W_M3O(:,:,trial+1)= W_M3O(:,:,trial) + delta_M3out(:,:,trial);
    
        %check synchronization (in positive phase)
        for p=1:nStim
            for q=1:nM1
                %sync measure (cross correlation at phase lag zero)
                sync_IM1(p,q,trial)=corr(squeeze(Phase_Input_plus(p,1,1:time,trial)),squeeze(Phase_M1_plus(q,1,1:time,trial)));
            end;
            for M=1:nM2
                %sync measure (cross correlation at phase lag zero)
                sync_IM2(p,M,trial)=corr(squeeze(Phase_Input_plus(p,1,1:time,trial)),squeeze(Phase_M2_plus(M,1,1:time,trial)));
            end;
            for M=1:nM3
                %sync measure (cross correlation at phase lag zero)
                sync_IM3(p,M,trial)=corr(squeeze(Phase_Input_plus(p,1,1:time,trial)),squeeze(Phase_M3_plus(M,1,1:time,trial)));
            end;
        end;    
    prog=trial
end;

%% save data
save(['RBM_sync_Beta',num2str(b),'Rep',num2str(r)],'Errorscore', 'rew','LFC','S', 'sync_IM1','sync_IM2','sync_IM3');
    end;
end;

