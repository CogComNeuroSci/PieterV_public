
%% Defining amount of loops
Rep=10;                         %amount of replication
T=500;                         %trialtime
iterations=5;                   %number of iterations in negative phase
Tr=2400;                        %number of trials
betas=11;                       %beta iterations
beta=0:0.1:1;                   %learning rate values
ITI=250;

%other variables
POT_1=Tr/3;                     %point of switch to task rule 2
POT_2=2*Tr/3;                   %switch again to task rule 1
part1=1:POT_1;                  %first part of task
part2=POT_1+1:POT_2;            %second part of task
part3=POT_2+1:Tr;               %third part of task

%% model build-up
%Processing module
nStim=6;                %number of units in input layer
nM1=4;                  %number of units in hidden layer M1
nM2=4;                  %number of units in hidden layer M2
nmod=2;                 %number of modules
nResp=2;                %number of units in output layer
nInput=8;               %number of input patterns
decay=0.9;              %decay parameter
r2max=1;                %max amplitude
Cg=0.58;                 %coupling gamma waves
damp=0.3;              %damping parameter
bias=5;                 %bias term

%Control module
r2_acc=1;               %radius ACC
Ct=0.07;                %coupling theta waves
damp_acc=0.003;         %damping parameter ACC
acc_slope=10;           %acc slope parameter

%Critic
lp=0.01;                    %learning parameter critic

%% in- and output patterns
%input patterns
Activation=zeros(nStim,nInput);    
Activation(1:6,1)=[1,0,1,0,1,0];              %blauw links cirkel    (1)
Activation(1:6,2)=[1,0,0,1,1,0];              %blauw rechts cirkel   (2)
Activation(1:6,3)=[0,1,1,0,1,0];              %rood links cirkel     (3)
Activation(1:6,4)=[0,1,0,1,1,0];              %rood rechts cirkel    (4)
Activation(1:6,5)=[1,0,1,0,0,1];              %blauw links vierkant  (5)      
Activation(1:6,6)=[1,0,0,1,0,1];              %blauw rechts vierkant (6)   
Activation(1:6,7)=[0,1,1,0,0,1];              %rood links vierkant   (7)
Activation(1:6,8)=[0,1,0,1,0,1];              %rood rechts vierkant  (8)

%Objectives at output layer
Objective=zeros(nResp,nInput,Tr);    
Objective(1,[1,2,5,7],part1)=1;
Objective(2,[3,4,6,8],part1)=1;
Objective(1,[1,2,5,7],part3)=1;
Objective(2,[3,4,6,8],part3)=1;
Objective(1,[3,4,6,8],part2)=1;
Objective(2,[1,2,5,7],part2)=1;

%% simulation loops
for b=11:betas
    for r=10:Rep
        
%% model initialization
%Processing module
%Positive phase
Phase_Input_plus=zeros(nStim,2,T,Tr); %phase neurons input layer
Rate_Input_plus=zeros(nStim,T,Tr);    %rate neurons input layer

Phase_M1_plus=zeros(nM1,2,T,Tr);     %phase neurons hidden module 1
Rate_M1_plus=zeros(nM1,T,Tr);        %rate neurons hidden module 1

Phase_M2_plus=zeros(nM2,2,T,Tr);     %phase neurons hidden module 2
Rate_M2_plus=zeros(nM2,T,Tr);        %rate neurons hidden module 2

Phase_Out_plus=zeros(nResp,2,T,Tr);  %phase neurons output layer
Rate_Out_plus=zeros(nResp,T,Tr);     %rate neurons output layer

net_M1_plus=zeros(nM1,T,Tr);         %net_input received by hidden units M1
net_M2_plus=zeros(nM2,T,Tr);         %net_input received by hidden units M2

%Negative phase all units have 2 values per iteration because of
%bidirectional activation flow
Phase_Input_min=zeros(nStim,2,T,Tr,iterations,2); %phase neurons input layer
Rate_Input_min=zeros(nStim,T,Tr,iterations,2);    %rate neurons input layer

Phase_M1_min=zeros(nM1,2,T,Tr,iterations,2);     %phase neurons hidden module 1
Rate_M1_min=zeros(nM1,T,Tr,iterations,2);        %rate neurons hidden module 1

Phase_M2_min=zeros(nM2,2,T,Tr,iterations,2);     %phase neurons hidden module 1
Rate_M2_min=zeros(nM2,T,Tr,iterations,2);        %rate neurons hidden module 1

Phase_Out_min=zeros(nResp,2,T,Tr,iterations,2);  %phase neurons output layer
Rate_Out_min=zeros(nResp,T,Tr,iterations,2);     %rate neurons output layer

net_M1_min=zeros(nM1,T,Tr,iterations);         %net_input received by hidden units M1
net_M2_min=zeros(nM1,T,Tr,iterations);         %net_input received by hidden units M2
net_Out_min=zeros(nResp,T,Tr,iterations);       %net_input received by output units

%binarization of unit activation
bin_M1=zeros(nM1,T,Tr,iterations);
bin_M2=zeros(nM2,T,Tr,iterations);

%weights
W_IM1=zeros(nStim,nM1,Tr);      %input to hidden M1
W_IM2=zeros(nStim,nM2,Tr);      %input to hidden M2
W_M1O=zeros(nM1,nResp,Tr);      %hidden M1 to output
W_M2O=zeros(nM2,nResp,Tr);      %hidden M2 to output

%random starting values for all weights
W_IM1(:,:,1)=rand(nStim,nM1)*5;   
W_IM2(:,:,1)=rand(nStim,nM2)*5;
W_M1O(:,:,1)=rand(nM1,nResp)*5;
W_M2O(:,:,1)=rand(nM2,nResp)*5;

%% Control module
LFC=zeros(nmod+1,Tr);         %LFC units
if rand>0.5
    LFC(1,1)=-1;
    LFC(2,1)=1;
else
    LFC(1,1)=1;
    LFC(2,1)=-1;
end;
LFC(3,1)=1;

ACC_plus=zeros(2,T,Tr);                       %ACC phase units pos phase
ACC_min=zeros(2,T,Tr,iterations,2);           %ACC phase units neg phase
Be_plus=zeros(T,Tr);                          %bernoulli pos phase
Be_min=zeros(T,Tr,iterations,2);              %bernoulli neg phase

%% Critic
rew=zeros(1,Tr);            %reward/accuracy record
V=zeros(1,Tr);              %value unit
S=zeros(1,Tr);              %switch unit
E=zeros(nmod,Tr);           %value weights with LFC
E(:,1)=0.5;                 %initial values
negPE=zeros(1,Tr);          %negative prediction error
posPE=zeros(1,Tr);          %positive prediction error

%% Input to model
%make list of input patterns
In=repmat(1:nInput,Tr/nInput);  
In=In(1,:);                                     
%randomization of this input list
Input=zeros(1,Tr);
Input(1,:)=In(1,randperm(Tr));             
%% Learning
delta_M1out=zeros(nM1,nResp,Tr);      %delta M1 to output
delta_M2out=zeros(nM2,nResp,Tr);      %delta M2 to output
delta_M1=zeros(nStim,nM1,Tr);          %delta Input to M1
delta_M2=zeros(nStim,nM2,Tr);          %delta Input to M2
                   
Errorscore=zeros(nResp,Tr);               %error score computed at negative phase

%% other
%starting points of oscillations
start_Input=rand(nStim,2,1,1);   
start_M1=rand(nM1,2,1,1);
start_M2=rand(nM2,2,1,1);
start_Out=rand(nResp,2,1,1); 
start_ACC=rand(2,1,1);    

%assign to phase code units
Phase_Input_plus(:,:,1,1)=start_Input;        
Phase_M1_plus(:,:,1,1)=start_M1;
Phase_M2_plus(:,:,1,1)=start_M2;
Phase_Out_plus(:,:,1,1)=start_Out;
ACC_plus(:,1,1)=start_ACC;

%radius
%positive phase
r2_Input_plus=zeros(nStim,T,Tr);        
r2_M1_plus=zeros(nM1,T,Tr);
r2_M2_plus=zeros(nM2,T,Tr);
r2_ACC_plus=zeros(T,Tr);
r2_Out_plus=zeros(nResp,T,Tr);
%negative phase
r2_Input_min=zeros(nStim,T,Tr,iterations,2);        
r2_M1_min=zeros(nM1,T,Tr,iterations,2);
r2_M2_min=zeros(nM2,T,Tr,iterations,2);
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
Hit_plus=zeros(T,Tr);                   %Hit record pos phase                 
Hit_min=zeros(T,Tr,iterations,2);       %Hit record neg phase

%% Model
 
%trial loop
for trial=1:400
    
    %starting values phase units (end of previous trial)
    if trial>1          
        Phase_Input_plus(:,:,1,trial)=Phase_Input_min(:,:,time,trial-1,i,2);
        Phase_M1_plus(:,:,1,trial)=Phase_M1_min(:,:,time,trial-1,i,2);
        Phase_M2_plus(:,:,1,trial)=Phase_M2_min(:,:,time,trial-1,i,2);
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
            r2_Out_plus(:,time,trial)=squeeze(dot(Phase_Out_plus(:,:,time,trial),Phase_Out_plus(:,:,time,trial),2));           %Output layer
            r2_ACC_plus(time,trial)=dot(ACC_plus(:,time,trial),ACC_plus(:,time,trial));                                        %ACC
            
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
            %Output
            Phase_Out_plus(:,1,time+1,trial)=Phase_Out_plus(:,1,time,trial)-Cg*Phase_Out_plus(:,2,time,trial)-damp*(r2_Out_plus(:,time,trial)>r2max).*Phase_Out_plus(:,1,time,trial); % excitatory cells
            Phase_Out_plus(:,2,time+1,trial)=Phase_Out_plus(:,2,time,trial)+Cg*Phase_Out_plus(:,1,time,trial)-damp*(r2_Out_plus(:,time,trial)>r2max).*Phase_Out_plus(:,2,time,trial); % inhibitory cells
            %ACC
            ACC_plus(1,time+1,trial)=ACC_plus(1,time,trial)-Ct*ACC_plus(2,time,trial)-damp_acc*(r2_ACC_plus(time,trial)>r2_acc)*ACC_plus(1,time,trial); % ACC exc cell
            ACC_plus(2,time+1,trial)=ACC_plus(2,time,trial)+Ct*ACC_plus(1,time,trial)-damp_acc*(r2_ACC_plus(time,trial)>r2_acc)*ACC_plus(2,time,trial); % ACC inh cell
            
            %bernoulli process in ACC rate
            Be_plus(time,trial)=1/(1+exp(-acc_slope*(ACC_plus(1,time,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be_plus(time,trial)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_plus(time,trial)=1;   %record hit is given
                Phase_Input_plus(:,:,time+1,trial)=decay*Phase_Input_plus(:,:,time,trial)+ LFC(3,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_plus(:,:,time+1,trial)=decay*Phase_Out_plus(:,:,time,trial)+ LFC(3,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_plus(:,:,time+1,trial)=decay*Phase_M1_plus(:,:,time,trial)+LFC(1,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_plus(:,:,time+1,trial)=decay*Phase_M2_plus(:,:,time,trial)+LFC(2,trial)*(ones(nM2,1))* Gaussian;
            end;
            
            %updating rate code units
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
    end;
    
    %Negative phase
    for i=1:iterations
        
        if i==1 %take over end values of oscillations in positive phase 
            Phase_Input_min(:,:,1,trial,1,1)=Phase_Input_plus(:,:,time,trial);
            Phase_M1_min(:,:,1,trial,1,1)=Phase_M1_plus(:,:,time,trial);
            Phase_M2_min(:,:,1,trial,1,1)=Phase_M2_plus(:,:,time,trial);
            Phase_Out_min(:,:,1,trial,1,1)=Phase_Out_plus(:,:,time,trial);
            ACC_min(:,1,trial,1,1)=ACC_plus(:,time,trial);
        else %take over end values of oscillations in previous iteration 
            Phase_Input_min(:,:,1,trial,i,1)=Phase_Input_min(:,:,time,trial,i-1,2);
            Phase_M1_min(:,:,1,trial,i,1)=Phase_M1_min(:,:,time,trial,i-1,2);
            Phase_M2_min(:,:,1,trial,i,1)=Phase_M2_min(:,:,time,trial,i-1,2);
            Phase_Out_min(:,:,1,trial,i,1)=Phase_Out_min(:,:,time,trial,i-1,2);
            ACC_min(:,1,trial,i,1)=ACC_min(:,time,trial,i-1,2);
        end;
        
    % step 1: In and output to hidden layer   
    for time=1:T%ITI:T  
            %computing radius of oscillations
            r2_Input_min(:,time,trial,i,1)=squeeze(dot(Phase_Input_min(:,:,time,trial,i,1),Phase_Input_min(:,:,time,trial,i,1),2));     %Input layer
            r2_M1_min(:,time,trial,i,1)=squeeze(dot(Phase_M1_min(:,:,time,trial,i,1),Phase_M1_min(:,:,time,trial,i,1),2));              %Hidden layer M1
            r2_M2_min(:,time,trial,i,1)=squeeze(dot(Phase_M2_min(:,:,time,trial,i,1),Phase_M2_min(:,:,time,trial,i,1),2));              %Hidden layer M1
            r2_Out_min(:,time,trial,i,1)=squeeze(dot(Phase_Out_min(:,:,time,trial,i,1),Phase_Out_min(:,:,time,trial,i,1),2));           %Output layer
            r2_ACC_min(time,trial,i,1)=dot(ACC_min(:,time,trial,i,1),ACC_min(:,time,trial,i,1));                                                %ACC
            
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
            %Output
            Phase_Out_min(:,1,time+1,trial,i,1)=Phase_Out_min(:,1,time,trial,i,1)-Cg*Phase_Out_min(:,2,time,trial,i,1)-damp*(r2_Out_min(:,time,trial,i,1)>r2max).*Phase_Out_min(:,1,time,trial,i,1); % excitatory cells
            Phase_Out_min(:,2,time+1,trial,i,1)=Phase_Out_min(:,2,time,trial,i,1)+Cg*Phase_Out_min(:,1,time,trial,i,1)-damp*(r2_Out_min(:,time,trial,i,1)>r2max).*Phase_Out_min(:,2,time,trial,i,1); % inhibitory cells
            %ACC
            ACC_min(1,time+1,trial,i,1)=ACC_min(1,time,trial,i,1)-Ct*ACC_min(2,time,trial,i,1)-damp_acc*(r2_ACC_min(time,trial,i,1)>r2_acc)*ACC_min(1,time,trial,i,1); % ACC exc cell
            ACC_min(2,time+1,trial,i,1)=ACC_min(2,time,trial,i,1)+Ct*ACC_min(1,time,trial,i,1)-damp_acc*(r2_ACC_min(time,trial,i,1)>r2_acc)*ACC_min(2,time,trial,i,1); % ACC inh cell
            
            %bernoulli process in ACC rate
            Be_min(time,trial,i,1)=1/(1+exp(-acc_slope*(ACC_min(1,time,trial,i,1)-1)));
            prob=rand;
            
            %burst
            if prob<Be_min(time,trial,i,1)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_min(time,trial,i,1)=1;   %record hit is given
                Phase_Input_min(:,:,time+1,trial,i,1)=decay*Phase_Input_min(:,:,time,trial,i,1)+ LFC(3,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_min(:,:,time+1,trial,i,1)=decay*Phase_Out_min(:,:,time,trial,i,1)+ LFC(3,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_min(:,:,time+1,trial,i,1)=decay*Phase_M1_min(:,:,time,trial,i,1)+LFC(1,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_min(:,:,time+1,trial,i,1)=decay*Phase_M2_min(:,:,time,trial,i,1)+LFC(2,trial)*(ones(nM2,1))* Gaussian;
            end;
            
            %updating rate code units
            %Input
            Rate_Input_min(:,time,trial,i,1)=(Z(:,trial)).*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input_min(:,1,time,trial,i,1))-0.6))));%Input layer
            Rate_Out_min(:,time,trial,i,1)=squeeze(Q_min(:,trial,i)).*(ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out_min(:,1,time,trial,i,1))-0.6))));
            %Hidden M1
            net_M1_min(:,time,trial,i)=W_IM1(:,:,trial)'* Rate_Input_min(:,time,trial,i,1)+W_M1O(:,:,trial)*Rate_Out_min(:,time,trial,i,1)-bias; %net input
            Rate_M1_min(:,time,trial,i,1)=(ones(nM1,1)./(ones(nM1,1) + exp(-net_M1_min(:,time,trial,i)))) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1_min(:,1,time,trial,i,1))-0.6)))); %M1 activation
            %Hidden M2
            net_M2_min(:,time,trial,i)=W_IM2(:,:,trial)'* Rate_Input_min(:,time,trial,i,1)+W_M2O(:,:,trial)*Rate_Out_min(:,time,trial,i,1)-bias; %net input
            Rate_M2_min(:,time,trial,i,1)=(ones(nM2,1)./(ones(nM2,1) + exp(-net_M2_min(:,time,trial,i)))) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2_min(:,1,time,trial,i,1))-0.6)))); %M2 activation
    end;
    %stochastic binarization
    bin_M1(:,trial,i)=max(Rate_M1_min(:,:,trial,i,1),[],2)>rand(nM1,1);
    bin_M2(:,trial,i)=max(Rate_M2_min(:,:,trial,i,1),[],2)>rand(nM2,1);
    
    %step 2: hidden back to output layer
    %take over end values of before
    Phase_Input_min(:,:,1,trial,i,2)=Phase_Input_min(:,:,time,trial,i,1);
    Phase_M1_min(:,:,1,trial,i,2)=Phase_M1_min(:,:,time,trial,i,1);
    Phase_M2_min(:,:,1,trial,i,2)=Phase_M2_min(:,:,time,trial,i,1);
    Phase_Out_min(:,:,1,trial,i,2)=Phase_Out_min(:,:,time,trial,i,1);
    ACC_min(:,1,trial,i,2)=ACC_min(:,time,trial,i,1);
        
    for time=1:T  
            %computing radius of oscillations
            r2_Input_min(:,time,trial,i,2)=squeeze(dot(Phase_Input_min(:,:,time,trial,i,2),Phase_Input_min(:,:,time,trial,i,2),2));     %Input layer
            r2_M1_min(:,time,trial,i,2)=squeeze(dot(Phase_M1_min(:,:,time,trial,i,2),Phase_M1_min(:,:,time,trial,i,2),2));              %Hidden layer M1
            r2_M2_min(:,time,trial,i,2)=squeeze(dot(Phase_M2_min(:,:,time,trial,i,2),Phase_M2_min(:,:,time,trial,i,2),2));              %Hidden layer M1
            r2_Out_min(:,time,trial,i,2)=squeeze(dot(Phase_Out_min(:,:,time,trial,i,2),Phase_Out_min(:,:,time,trial,i,2),2));           %Output layer
            r2_ACC_min(time,trial,i,2)=dot(ACC_min(:,time,trial,i,2),ACC_min(:,time,trial,i,2));                                                %ACC
            
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
            %Output
            Phase_Out_min(:,1,time+1,trial,i,2)=Phase_Out_min(:,1,time,trial,i,2)-Cg*Phase_Out_min(:,2,time,trial,i,2)-damp*(r2_Out_min(:,time,trial,i,2)>r2max).*Phase_Out_min(:,1,time,trial,i,2); % excitatory cells
            Phase_Out_min(:,2,time+1,trial,i,2)=Phase_Out_min(:,2,time,trial,i,2)+Cg*Phase_Out_min(:,1,time,trial,i,2)-damp*(r2_Out_min(:,time,trial,i,2)>r2max).*Phase_Out_min(:,2,time,trial,i,2); % inhibitory cells
            %ACC
            ACC_min(1,time+1,trial,i,2)=ACC_min(1,time,trial,i,2)-Ct*ACC_min(2,time,trial,i,2)-damp_acc*(r2_ACC_min(time,trial,i,2)>r2_acc)*ACC_min(1,time,trial,i,2); % ACC exc cell
            ACC_min(2,time+1,trial,i,2)=ACC_min(2,time,trial,i,2)+Ct*ACC_min(1,time,trial,i,2)-damp_acc*(r2_ACC_min(time,trial,i,2)>r2_acc)*ACC_min(2,time,trial,i,2); % ACC inh cell
            
            %bernoulli process in ACC rate
            Be_min(time,trial,i,2)=1/(1+exp(-acc_slope*(ACC_min(1,time,trial,i,2)-1)));
            prob=rand;
            
            %burst
            if prob<Be_min(time,trial,i,2)
                Gaussian=randn(1,2); %Gaussian noise
                Hit_min(time,trial,i,2)=1;   %record hit is given
                Phase_Input_min(:,:,time+1,trial,i,2)=decay*Phase_Input_min(:,:,time,trial,i,2)+ LFC(3,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out_min(:,:,time+1,trial,i,2)=decay*Phase_Out_min(:,:,time,trial,i,2)+ LFC(3,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1_min(:,:,time+1,trial,i,2)=decay*Phase_M1_min(:,:,time,trial,i,2)+LFC(1,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2_min(:,:,time+1,trial,i,2)=decay*Phase_M2_min(:,:,time,trial,i,2)+LFC(2,trial)*(ones(nM2,1))* Gaussian;
            end;
            
            %updating rate code units
            %Input
            Rate_Input_min(:,time,trial,i,2)=Z(:,trial) .*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input_min(:,1,time,trial,i,2))-0.6))));%Input layer
            %Hidden M1
            Rate_M1_min(:,time,trial,i,2)=bin_M1(:,trial,i) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1_min(:,1,time,trial,i,2))-0.6)))); %M1 activation
            %Hidden M2
            Rate_M2_min(:,time,trial,i,2)=bin_M2(:,trial,i) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2_min(:,1,time,trial,i,2))-0.6)))); %M2 activation
            %Output
            net_Out_min(:,time,trial,i)=squeeze(W_M1O(:,:,trial))'*squeeze(Rate_M1_min(:,time,trial,i,2)) + squeeze(W_M2O(:,:,trial))'*squeeze(Rate_M2_min(:,time,trial,i,2))-bias; %net input
            Rate_Out_min(:,time,trial,i,2)=(ones(nResp,1)./(ones(nResp,1) + exp(-net_Out_min(:,time,trial,i)))) .* (ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out_min(:,1,time,trial,i,2))-0.6))));%(exp(net_Out_min(:,time,trial,i))./sum(exp(net_Out_min(:,time,trial,i)))) %Output layer
    end;
    
    %here choose max
    if squeeze(max(Rate_Out_min(1,:,trial,i,2),[],2)) > squeeze(max(Rate_Out_min(2,:,trial,i,2),[],2))
        response(1,trial,i)=1;
    else
        response(2,trial,i)=1;
    end;
            
        Q_min(:,trial,i+1)=response(:,trial,i);   
    end;
    
    %keep track of accuracy/reward
    if Q(:,trial)==response(:,trial,i)
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    %value unit update
    V(1,trial)=E(:,trial)'* 0.5* (LFC(1:nmod,trial)+ones(nmod,1)); 
        
    %Prediction errors
    negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
    posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
    %Value weight update
    E(:,trial+1)= E(:,trial) + lp * V(1,trial) * (posPE(1,trial)-negPE(1,trial)) * 0.5 * (LFC(1:nmod,trial)+ones(nmod,1));
        
    %switch unit update
    S(1,trial+1)=0.8*S(1,trial)+0.2*(negPE(1,trial));
    
    %LFC update
    if S(1,trial)>0.5
        LFC(1,trial+1)=-LFC(1,trial);
        LFC(2,trial+1)=-LFC(2,trial);
        S(1,trial+1)=0;
    else
        LFC(1,trial+1)=LFC(1,trial);
        LFC(2,trial+1)=LFC(2,trial);
    end;
        
    LFC(3,trial+1)=LFC(3,trial);
    
    %keep track of errorscore in both test and negative phase
    Errorscore(:,trial)=(Q(:,trial)-squeeze(max(Rate_Out_min(:,:,trial,i-1,2),[],2))).^2;
    
    %compute weightchange
    delta_M1out(:,:,trial)=beta(1,b) *((max(Rate_Out_plus(:,:,trial),[],2)*max(Rate_M1_plus(:,:,trial),[],2)')'-(max(Rate_Out_min(:,:,trial,i-1,2),[],2)*max(Rate_M1_min(:,:,trial,i,1),[],2)')');
    delta_M2out(:,:,trial)=beta(1,b) *((max(Rate_Out_plus(:,:,trial),[],2)*max(Rate_M2_plus(:,:,trial),[],2)')'-(max(Rate_Out_min(:,:,trial,i-1,2),[],2)*max(Rate_M2_min(:,:,trial,i,1),[],2)')');
    delta_M1(:,:,trial)=beta(1,b) * ((max(Rate_Input_plus(:,:,trial),[],2)*max(Rate_M1_plus(:,:,trial),[],2)')-(max(Rate_Input_min(:,:,trial,i,2),[],2)*max(Rate_M1_min(:,:,trial,i,1),[],2)'));
    delta_M2(:,:,trial)=beta(1,b) * ((max(Rate_Input_plus(:,:,trial),[],2)*max(Rate_M2_plus(:,:,trial),[],2)')-(max(Rate_Input_min(:,:,trial,i,2),[],2)*max(Rate_M2_min(:,:,trial,i,1),[],2)'));
    %change weights
    W_IM1(:,:,trial+1)=W_IM1(:,:,trial) + delta_M1(:,:,trial);
    W_IM2(:,:,trial+1)= W_IM2(:,:,trial) + delta_M2(:,:,trial);
    W_M1O(:,:,trial+1)=W_M1O(:,:,trial) + delta_M1out(:,:,trial);
    W_M2O(:,:,trial+1)= W_M2O(:,:,trial) + delta_M2out(:,:,trial);
    
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
        end;    
    prog=trial
end;

%% track learning by accuracy over bins
 nbins=20;
 binned_Errorscore_min=zeros(1,nbins*3);
 binned_accuracy_min=zeros(1,nbins*3);

 bin_edges=zeros(1,(nbins*3)+1);
 
 bin_edges(1,1:nbins+1)=0:POT_1/nbins:POT_1;
 bin_edges(1,nbins+1:(nbins*2)+1)=POT_1:POT_1/nbins:POT_2;
 bin_edges(1,(2*nbins)+1:(nbins*3)+1)=POT_2:POT_1/nbins:Tr; 
  
 for bin=1:nbins*3
     binned_Errorscore_min(1,bin)=mean(mean(Errorscore(:,(bin_edges(bin)+1):bin_edges(bin+1))));
     binned_accuracy_min(1,bin)=mean(rew(1,(bin_edges(bin)+1):bin_edges(bin+1)));
 end;
 save(['RBM_sync_Beta',num2str(b),'Rep',num2str(Rep)],'binned_Errorscore_min', 'binned_accuracy_min','LFC','S', 'sync_IM1','sync_IM2');
    end;
end;
