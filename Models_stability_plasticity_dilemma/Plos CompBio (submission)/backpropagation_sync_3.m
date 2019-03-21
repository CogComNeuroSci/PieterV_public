
%% Defining amount of loops
Rep=10;                         %amount of replications
T=500;                         %trialtime
Tr=3600;                        %amount of trials
betas=11;                       %beta iterations
beta=0:1/(betas-1):1;                   %values of beta (learning rate)
ITI=250;

POT=Tr/6:Tr/6:Tr;                 %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);                %third part
part4=POT(3)+1:POT(4);
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);
%% Model build-up
% Processing module
nStim=13;                %number input units
nM1=6;                   %number hidden units in module 1
nM2=6;
nM3=6;
nResp=3;                 %number of response options
nInput=81;               %number of input patterns
bias=5;                  %bias parameter
nmod=3;                  %number of Hidden modules
r2max=1;                 %max amplitude
Cg=0.58;                 %coupling gamma waves
damp=0.3;                %damping parameter
decay=0.9;               %decay parameter

%Control module
r2_acc=0.05;               %radius ACC
Ct=0.07;                %coupling theta waves
damp_acc=0.003;          %damping parameter ACC
acc_slope=10;           %acc slope parameter

%Critic
lp=0.01;                %learning parameter critic

%% in- and output patterns

Activation=zeros(nStim,nInput);      %input patterns
Activation(:,1)=[1,0,0,1,0,0,1,0,0,1,0,0,1];                %Congruent     (1)
Activation(:,2)=[0,1,0,1,0,0,1,0,0,1,0,0,1];              
Activation(:,3)=[0,0,1,1,0,0,1,0,0,1,0,0,1]; 

Activation(:,4)=[1,0,0,0,1,0,0,1,0,0,1,0,1];                %Congruent     (2)     
Activation(:,5)=[0,1,0,0,1,0,0,1,0,0,1,0,1];              
Activation(:,6)=[0,0,1,0,1,0,0,1,0,0,1,0,1];

Activation(:,7)=[1,0,0,0,0,1,0,0,1,0,0,1,1];                %Congruent     (3)         
Activation(:,8)=[0,1,0,0,0,1,0,0,1,0,0,1,1];              
Activation(:,9)=[0,0,1,0,0,1,0,0,1,0,0,1,1]; 

Activation(:,10)=[1,0,0,1,0,0,0,1,0,1,0,0,1];               %First dimension 1
Activation(:,11)=[1,0,0,1,0,0,0,0,1,1,0,0,1];                  
Activation(:,12)=[1,0,0,1,0,0,1,0,0,0,1,0,1];                
Activation(:,13)=[1,0,0,1,0,0,0,1,0,0,1,0,1];                 
Activation(:,14)=[1,0,0,1,0,0,0,0,1,0,1,0,1];                  
Activation(:,15)=[1,0,0,1,0,0,1,0,0,0,0,1,1];            
Activation(:,16)=[1,0,0,1,0,0,0,1,0,0,0,1,1];           
Activation(:,17)=[1,0,0,1,0,0,0,0,1,0,0,1,1]; 

Activation(:,18)=[1,0,0,0,1,0,1,0,0,1,0,0,1];               %First dimension 2
Activation(:,19)=[1,0,0,0,1,0,0,1,0,1,0,0,1];                  
Activation(:,20)=[1,0,0,0,1,0,0,0,1,1,0,0,1];                
Activation(:,21)=[1,0,0,0,1,0,1,0,0,0,1,0,1];                 
Activation(:,22)=[1,0,0,0,1,0,0,0,1,0,1,0,1];                  
Activation(:,23)=[1,0,0,0,1,0,1,0,0,0,0,1,1];            
Activation(:,24)=[1,0,0,0,1,0,0,1,0,0,0,1,1];           
Activation(:,25)=[1,0,0,0,1,0,0,0,1,0,0,1,1]; 

Activation(:,26)=[1,0,0,0,0,1,1,0,0,1,0,0,1];               %First dimension 3
Activation(:,27)=[1,0,0,0,0,1,0,1,0,1,0,0,1];                  
Activation(:,28)=[1,0,0,0,0,1,0,0,1,1,0,0,1];                
Activation(:,29)=[1,0,0,0,0,1,1,0,0,0,1,0,1];
Activation(:,30)=[1,0,0,0,0,1,0,1,0,0,1,0,1];
Activation(:,31)=[1,0,0,0,0,1,0,0,1,0,1,0,1];
Activation(:,32)=[1,0,0,0,0,1,1,0,0,0,0,1,1];            
Activation(:,33)=[1,0,0,0,0,1,0,1,0,0,0,1,1];           

Activation(:,34)=[0,1,0,1,0,0,0,1,0,1,0,0,1];               %Second dimension 1
Activation(:,35)=[0,1,0,1,0,0,0,0,1,1,0,0,1];                  
Activation(:,36)=[0,1,0,1,0,0,1,0,0,0,1,0,1];                
Activation(:,37)=[0,1,0,1,0,0,0,1,0,0,1,0,1];                 
Activation(:,38)=[0,1,0,1,0,0,0,0,1,0,1,0,1];                  
Activation(:,39)=[0,1,0,1,0,0,1,0,0,0,0,1,1];            
Activation(:,40)=[0,1,0,1,0,0,0,1,0,0,0,1,1];           
Activation(:,41)=[0,1,0,1,0,0,0,0,1,0,0,1,1]; 

Activation(:,42)=[0,1,0,0,1,0,1,0,0,1,0,0,1];               %Second dimension 2
Activation(:,43)=[0,1,0,0,1,0,0,1,0,1,0,0,1];                  
Activation(:,44)=[0,1,0,0,1,0,0,0,1,1,0,0,1];                
Activation(:,45)=[0,1,0,0,1,0,1,0,0,0,1,0,1];                 
Activation(:,46)=[0,1,0,0,1,0,0,0,1,0,1,0,1];                  
Activation(:,47)=[0,1,0,0,1,0,1,0,0,0,0,1,1];            
Activation(:,48)=[0,1,0,0,1,0,0,1,0,0,0,1,1];           
Activation(:,49)=[0,1,0,0,1,0,0,0,1,0,0,1,1]; 

Activation(:,50)=[0,1,0,0,0,1,1,0,0,1,0,0,1];               %Second dimension 3
Activation(:,51)=[0,1,0,0,0,1,0,1,0,1,0,0,1];                  
Activation(:,52)=[0,1,0,0,0,1,0,0,1,1,0,0,1];                
Activation(:,53)=[0,1,0,0,0,1,1,0,0,0,1,0,1];
Activation(:,54)=[0,1,0,0,0,1,0,1,0,0,1,0,1];
Activation(:,55)=[0,1,0,0,0,1,0,0,1,0,1,0,1];
Activation(:,56)=[0,1,0,0,0,1,1,0,0,0,0,1,1];            
Activation(:,57)=[0,1,0,0,0,1,0,1,0,0,0,1,1]; 
          
Activation(:,58)=[0,0,1,1,0,0,0,1,0,1,0,0,1];               %Third dimension 1
Activation(:,59)=[0,0,1,1,0,0,0,0,1,1,0,0,1];                  
Activation(:,60)=[0,0,1,1,0,0,1,0,0,0,1,0,1];                
Activation(:,61)=[0,0,1,1,0,0,0,1,0,0,1,0,1];                 
Activation(:,62)=[0,0,1,1,0,0,0,0,1,0,1,0,1];                  
Activation(:,63)=[0,0,1,1,0,0,1,0,0,0,0,1,1];            
Activation(:,64)=[0,0,1,1,0,0,0,1,0,0,0,1,1];           
Activation(:,65)=[0,0,1,1,0,0,0,0,1,0,0,1,1]; 

Activation(:,66)=[0,0,1,0,1,0,1,0,0,1,0,0,1];               %Third dimension 2
Activation(:,67)=[0,0,1,0,1,0,0,1,0,1,0,0,1];                  
Activation(:,68)=[0,0,1,0,1,0,0,0,1,1,0,0,1];                
Activation(:,69)=[0,0,1,0,1,0,1,0,0,0,1,0,1];                 
Activation(:,70)=[0,0,1,0,1,0,0,0,1,0,1,0,1];                  
Activation(:,71)=[0,0,1,0,1,0,1,0,0,0,0,1,1];            
Activation(:,72)=[0,0,1,0,1,0,0,1,0,0,0,1,1];           
Activation(:,73)=[0,0,1,0,1,0,0,0,1,0,0,1,1]; 

Activation(:,74)=[0,0,1,0,0,1,1,0,0,1,0,0,1];               %Third dimension 3
Activation(:,75)=[0,0,1,0,0,1,0,1,0,1,0,0,1];                  
Activation(:,76)=[0,0,1,0,0,1,0,0,1,1,0,0,1];                
Activation(:,77)=[0,0,1,0,0,1,1,0,0,0,1,0,1];
Activation(:,78)=[0,0,1,0,0,1,0,1,0,0,1,0,1];
Activation(:,79)=[0,0,1,0,0,1,0,0,1,0,1,0,1];
Activation(:,80)=[0,0,1,0,0,1,1,0,0,0,0,1,1];            
Activation(:,81)=[0,0,1,0,0,1,0,1,0,0,0,1,1]; 

%learning objectives for output layer per experimental part
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
for b=11:betas
    for r=10:Rep
%% initialization model
%Processing module
Phase_Input=zeros(nStim,2,T,Tr); %phase neurons input layer
Rate_Input=zeros(nStim,T,Tr);    %rate neurons input layer

Phase_M1=zeros(nM1,2,T,Tr);     %phase neurons hidden module 1
Rate_M1=zeros(nM1,T,Tr);        %rate neurons hidden module 1

Phase_M2=zeros(nM2,2,T,Tr);     %phase neurons hidden module 2
Rate_M2=zeros(nM2,T,Tr);        %rate neurons hidden module 2

Phase_M3=zeros(nM3,2,T,Tr);     %phase neurons hidden module 2
Rate_M3=zeros(nM3,T,Tr);        %rate neurons hidden module 2

Phase_Out=zeros(nResp,2,T,Tr);  %phase neurons output layer
Rate_Out=zeros(nResp,T,Tr);     %rate neurons output layer

net_M1=zeros(nM1,T,Tr);         %net_input received by hidden units M1
net_M2=zeros(nM2,T,Tr);         %net_input received by hidden units M2
net_M3=zeros(nM3,T,Tr);         %net_input received by hidden units M3
net_Out=zeros(nResp,T,Tr);      %net_input received by output units

%weights
W_IM1=zeros(nStim,nM1,Tr);      %input to hidden M1
W_IM2=zeros(nStim,nM2,Tr);      %input to hidden M2
W_IM3=zeros(nStim,nM2,Tr);      %input to hidden M3
W_M1O=zeros(nM1,nResp,Tr);      %hidden M1 to output
W_M2O=zeros(nM2,nResp,Tr);      %hidden M2 to output
W_M3O=zeros(nM3,nResp,Tr);      %hidden M2 to output

%random starting values for all weights
W_IM1(:,:,1)=rand(nStim,nM1)*2.5;   
W_IM2(:,:,1)=rand(nStim,nM2)*2.5;
W_IM3(:,:,1)=rand(nStim,nM3)*2.5;
W_M1O(:,:,1)=rand(nM1,nResp)*2.5;
W_M2O(:,:,1)=rand(nM2,nResp)*2.5;
W_M3O(:,:,1)=rand(nM3,nResp)*2.5;

Modules=1:3;
stm=datasample(Modules,1);

LFC=ones(4,Tr)*-1;         %LFC units
LFC(1,1)=1;
LFC(stm+1,1)=1;
Inhibition=zeros(length(Modules),Tr);

ACC=zeros(2,T,Tr);           %ACC phase units
Be=zeros(T,Tr);              %bernoulli (rate code ACC)

% Critic
rew=zeros(1,Tr);            %reward/accuracy record
V=zeros(1,Tr);              %value unit
S=zeros(1,Tr);              %switch unit
E=zeros(nmod,Tr);           %value weights with LFC
E(:,1)=0.5;                 %initial values
negPE=zeros(1,Tr);          %negative prediction error
posPE=zeros(1,Tr);          %positive prediction error

%% Learning parameters
Errorscore=zeros(nResp,Tr);     %errorscore
delta_out=zeros(nResp,Tr);      %delta hidden to output layer
delta_M1=zeros(nM1,Tr);         %delta input to hidden layer M1
delta_M2=zeros(nM2,Tr);         %delta input to hidden layer M2
delta_M3=zeros(nM2,Tr);         %delta input to hidden layer M2
%% Input
In=repmat(1:nInput,6,(POT(1)));      %make input list of patterns
%randomization for each part seperately
Input=zeros(1,Tr);                       
Input(1,part1)=In(1,randperm(POT(1)));
Input(1,part2)=In(2,randperm(POT(1)));
Input(1,part3)=In(3,randperm(POT(1)));
Input(1,part4)=In(4,randperm(POT(1)));
Input(1,part5)=In(5,randperm(POT(1)));
Input(1,part6)=In(6,randperm(POT(1)));

%% Other
%starting points of oscillations
start_Input=rand(nStim,2,1,1);   
start_M1=rand(nM1,2,1,1);
start_M2=rand(nM2,2,1,1);
start_M3=rand(nM3,2,1,1);
start_Out=rand(nResp,2,1,1); 
start_ACC=rand(2,1,1);

%assign to phase code units
Phase_Input(:,:,1,1)=start_Input;        
Phase_M1(:,:,1,1)=start_M1;
Phase_M2(:,:,1,1)=start_M2;
Phase_M3(:,:,1,1)=start_M3;
Phase_Out(:,:,1,1)=start_Out;
ACC(:,1,1)=start_ACC;

%radius
r2_Input=zeros(nStim,T,Tr);        
r2_M1=zeros(nM1,T,Tr);
r2_M2=zeros(nM2,T,Tr);
r2_M3=zeros(nM3,T,Tr);
r2_ACC=zeros(T,Tr);
r2_Out=zeros(nResp,T,Tr);

%recordings 
Z=zeros(nStim,Tr);               %input matrix
response=zeros(nResp,Tr);        %response record
sync_IM1=zeros(nStim,nM1,Tr);    %sync matrix (correlations)
sync_IM2=zeros(nStim,nM2,Tr);    %sync matrix (correlations)
sync_IM3=zeros(nStim,nM2,Tr);    %sync matrix (correlations)
Hit=zeros(T,Tr);                 %Hit record

%% the model
    %trial loop 
    for trial=1:Tr  
        
        %oscillatory starting points are end points of previous trials
        if trial>1          
            Phase_Input(:,:,1,trial)=Phase_Input(:,:,time,trial-1);
            Phase_M1(:,:,1,trial)=Phase_M1(:,:,time,trial-1);
            Phase_M2(:,:,1,trial)=Phase_M2(:,:,time,trial-1);
            Phase_M3(:,:,1,trial)=Phase_M3(:,:,time,trial-1);
            Phase_Out(:,:,1,trial)=Phase_Out(:,:,time,trial-1);
            ACC(:,1,trial)=ACC(:,time,trial-1);
        end;
        
        %Assigning input pattern
        Z(:,trial)=Activation(:,Input(1,trial));
        
                % intertrial interval
        for t= 1:ITI
            
            %computing radius of oscillations
            r2_Input(:,t,trial)=squeeze(dot(Phase_Input(:,:,t,trial),Phase_Input(:,:,t,trial),2));     %Input layer
            r2_M1(:,t,trial)=squeeze(dot(Phase_M1(:,:,t,trial),Phase_M1(:,:,t,trial),2));              %Hidden layer M1
            r2_M2(:,t,trial)=squeeze(dot(Phase_M2(:,:,t,trial),Phase_M2(:,:,t,trial),2));              %Hidden layer M1
            r2_M3(:,t,trial)=squeeze(dot(Phase_M3(:,:,t,trial),Phase_M3(:,:,t,trial),2));
            r2_Out(:,t,trial)=squeeze(dot(Phase_Out(:,:,t,trial),Phase_Out(:,:,t,trial),2));           %Output layer
            r2_ACC(t,trial)=dot(ACC(:,t,trial),ACC(:,t,trial));                                        %ACC
            
            %updating phase code neurons
            Phase_Input(:,1,t+1,trial)=Phase_Input(:,1,t,trial)-Cg*Phase_Input(:,2,t,trial)-damp*(r2_Input(:,t,trial)>r2max).*Phase_Input(:,1,t,trial); % excitatory cells
            Phase_Input(:,2,t+1,trial)=Phase_Input(:,2,t,trial)+Cg*Phase_Input(:,1,t,trial)-damp*(r2_Input(:,t,trial)>r2max).*Phase_Input(:,2,t,trial); % inhibitory cells

            Phase_M1(:,1,t+1,trial)=Phase_M1(:,1,t,trial)-Cg*Phase_M1(:,2,t,trial)-damp*(r2_M1(:,t,trial)>r2max).*Phase_M1(:,1,t,trial); % excitatory cells
            Phase_M1(:,2,t+1,trial)=Phase_M1(:,2,t,trial)+Cg*Phase_M1(:,1,t,trial)-damp*(r2_M1(:,t,trial)>r2max).*Phase_M1(:,2,t,trial); % inhibitory cells

            Phase_M2(:,1,t+1,trial)=Phase_M2(:,1,t,trial)-Cg*Phase_M2(:,2,t,trial)-damp*(r2_M2(:,t,trial)>r2max).*Phase_M2(:,1,t,trial); % excitatory cells
            Phase_M2(:,2,t+1,trial)=Phase_M2(:,2,t,trial)+Cg*Phase_M2(:,1,t,trial)-damp*(r2_M2(:,t,trial)>r2max).*Phase_M2(:,2,t,trial); % inhibitory cells
            
            Phase_M3(:,1,t+1,trial)=Phase_M3(:,1,t,trial)-Cg*Phase_M3(:,2,t,trial)-damp*(r2_M3(:,t,trial)>r2max).*Phase_M3(:,1,t,trial); % excitatory cells
            Phase_M3(:,2,t+1,trial)=Phase_M3(:,2,t,trial)+Cg*Phase_M3(:,1,t,trial)-damp*(r2_M3(:,t,trial)>r2max).*Phase_M3(:,2,t,trial); % inhibitory cells
            
            Phase_Out(:,1,t+1,trial)=Phase_Out(:,1,t,trial)-Cg*Phase_Out(:,2,t,trial)-damp*(r2_Out(:,t,trial)>r2max).*Phase_Out(:,1,t,trial); % excitatory cells
            Phase_Out(:,2,t+1,trial)=Phase_Out(:,2,t,trial)+Cg*Phase_Out(:,1,t,trial)-damp*(r2_Out(:,t,trial)>r2max).*Phase_Out(:,2,t,trial); % inhibitory cells

            ACC(1,t+1,trial)=ACC(1,t,trial)-Ct*ACC(2,t,trial)-damp_acc*(r2_ACC(t,trial)>r2_acc)*ACC(1,t,trial); % ACC exc cell
            ACC(2,t+1,trial)=ACC(2,t,trial)+Ct*ACC(1,t,trial)-damp_acc*(r2_ACC(t,trial)>r2_acc)*ACC(2,t,trial); % ACC inh cell
            
            if trial>1
                if negPE(1,trial-1)>0 
                    Be_ACC=gaussmf(t,[12.5,100]);
                    prob_ACC=rand;
                    if prob_ACC< Be_ACC
                        Gaussian_ACC=randn(2,1);
                        ACC(:,t+1,trial)=decay*ACC(:,t,trial)-negPE(1,trial-1)*Gaussian_ACC;
                    end;
                end;
            end;

            %bernoulli process in ACC rate
            Be(t,trial)=1/(1+exp(-acc_slope*(ACC(1,t,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be(t,trial)
                Gaussian=randn(1,2); %Gaussian noise
                Hit(t,trial)=1;   %record hit is given
                Phase_Input(:,:,t+1,trial)=decay*Phase_Input(:,:,t,trial)+ LFC(1,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out(:,:,t+1,trial)=decay*Phase_Out(:,:,t,trial)+ LFC(1,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1(:,:,t+1,trial)=decay*Phase_M1(:,:,t,trial)+LFC(2,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2(:,:,t+1,trial)=decay*Phase_M2(:,:,t,trial)+LFC(3,trial)*(ones(nM2,1))* Gaussian;
                Phase_M3(:,:,t+1,trial)=decay*Phase_M3(:,:,t,trial)+LFC(4,trial)*(ones(nM3,1))* Gaussian;
            end;
        end;
        
        for time=ITI:T
            
            %computing radius of oscillations
            r2_Input(:,time,trial)=squeeze(dot(Phase_Input(:,:,time,trial),Phase_Input(:,:,time,trial),2));     %Input layer
            r2_M1(:,time,trial)=squeeze(dot(Phase_M1(:,:,time,trial),Phase_M1(:,:,time,trial),2));              %Hidden layer M1
            r2_M2(:,time,trial)=squeeze(dot(Phase_M2(:,:,time,trial),Phase_M2(:,:,time,trial),2));              %Hidden layer M1
            r2_M3(:,time,trial)=squeeze(dot(Phase_M3(:,:,time,trial),Phase_M3(:,:,time,trial),2));              %Hidden layer M1
            r2_Out(:,time,trial)=squeeze(dot(Phase_Out(:,:,time,trial),Phase_Out(:,:,time,trial),2));           %Output layer
            r2_ACC(time,trial)=dot(ACC(:,time,trial),ACC(:,time,trial));                                        %ACC
            
            %updating phase code neurons
            Phase_Input(:,1,time+1,trial)=Phase_Input(:,1,time,trial)-Cg*Phase_Input(:,2,time,trial)-damp*(r2_Input(:,time,trial)>r2max).*Phase_Input(:,1,time,trial); % excitatory cells
            Phase_Input(:,2,time+1,trial)=Phase_Input(:,2,time,trial)+Cg*Phase_Input(:,1,time,trial)-damp*(r2_Input(:,time,trial)>r2max).*Phase_Input(:,2,time,trial); % inhibitory cells

            Phase_M1(:,1,time+1,trial)=Phase_M1(:,1,time,trial)-Cg*Phase_M1(:,2,time,trial)-damp*(r2_M1(:,time,trial)>r2max).*Phase_M1(:,1,time,trial); % excitatory cells
            Phase_M1(:,2,time+1,trial)=Phase_M1(:,2,time,trial)+Cg*Phase_M1(:,1,time,trial)-damp*(r2_M1(:,time,trial)>r2max).*Phase_M1(:,2,time,trial); % inhibitory cells

            Phase_M2(:,1,time+1,trial)=Phase_M2(:,1,time,trial)-Cg*Phase_M2(:,2,time,trial)-damp*(r2_M2(:,time,trial)>r2max).*Phase_M2(:,1,time,trial); % excitatory cells
            Phase_M2(:,2,time+1,trial)=Phase_M2(:,2,time,trial)+Cg*Phase_M2(:,1,time,trial)-damp*(r2_M2(:,time,trial)>r2max).*Phase_M2(:,2,time,trial); % inhibitory cells

            Phase_M3(:,1,time+1,trial)=Phase_M3(:,1,time,trial)-Cg*Phase_M3(:,2,time,trial)-damp*(r2_M3(:,time,trial)>r2max).*Phase_M3(:,1,time,trial); % excitatory cells
            Phase_M3(:,2,time+1,trial)=Phase_M3(:,2,time,trial)+Cg*Phase_M3(:,1,time,trial)-damp*(r2_M3(:,time,trial)>r2max).*Phase_M3(:,2,time,trial); % inhibitory cells
            
            Phase_Out(:,1,time+1,trial)=Phase_Out(:,1,time,trial)-Cg*Phase_Out(:,2,time,trial)-damp*(r2_Out(:,time,trial)>r2max).*Phase_Out(:,1,time,trial); % excitatory cells
            Phase_Out(:,2,time+1,trial)=Phase_Out(:,2,time,trial)+Cg*Phase_Out(:,1,time,trial)-damp*(r2_Out(:,time,trial)>r2max).*Phase_Out(:,2,time,trial); % inhibitory cells

            ACC(1,time+1,trial)=ACC(1,time,trial)-Ct*ACC(2,time,trial)-damp_acc*(r2_ACC(time,trial)>r2_acc)*ACC(1,time,trial); % ACC exc cell
            ACC(2,time+1,trial)=ACC(2,time,trial)+Ct*ACC(1,time,trial)-damp_acc*(r2_ACC(time,trial)>r2_acc)*ACC(2,time,trial); % ACC inh cell
            
            %bernoulli process in ACC rate
            Be(time,trial)=1/(1+exp(-acc_slope*(ACC(1,time,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be(time,trial)
                Gaussian=randn(1,2); %Gaussian noise
                Hit(time,trial)=1;   %record hit is given
                Phase_Input(:,:,time+1,trial)=decay*Phase_Input(:,:,time,trial)+ LFC(1,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out(:,:,time+1,trial)=decay*Phase_Out(:,:,time,trial)+ LFC(1,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1(:,:,time+1,trial)=decay*Phase_M1(:,:,time,trial)+LFC(2,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2(:,:,time+1,trial)=decay*Phase_M2(:,:,time,trial)+LFC(3,trial)*(ones(nM2,1))* Gaussian;
                Phase_M3(:,:,time+1,trial)=decay*Phase_M3(:,:,time,trial)+LFC(4,trial)*(ones(nM3,1))* Gaussian;
            end;
            
            %updating rate code units
            Rate_Input(:,time,trial)=(Z(:,trial)).*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input(:,1,time,trial))-0.6))));%+(noise * rand(nStim,1))));%Input layer

            net_M1(:,time,trial)=W_IM1(:,:,trial)'* Rate_Input(:,time,trial)-bias; %net input
            Rate_M1(:,time+1,trial)=(ones(nM1,1)./(ones(nM1,1) + exp(-net_M1(:,time,trial)))) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1(:,1,time,trial))-0.6))));%+(noise * rand(nM1,1)))); %M1 activation

            net_M2(:,time,trial)=W_IM2(:,:,trial)'* Rate_Input(:,time,trial)-bias; %net input
            Rate_M2(:,time+1,trial)=(ones(nM2,1)./(ones(nM2,1) + exp(-net_M2(:,time,trial)))) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2(:,1,time,trial))-0.6))));%+(noise * rand(nM2,1)))); %M2 activation
            
            net_M3(:,time,trial)=W_IM3(:,:,trial)'* Rate_Input(:,time,trial)-bias; %net input
            Rate_M3(:,time+1,trial)=(ones(nM3,1)./(ones(nM3,1) + exp(-net_M3(:,time,trial)))) .* (ones(nM3,1)./(ones(nM3,1)+exp(-5*(squeeze(Phase_M3(:,1,time,trial))-0.6))));
            
            net_Out(:,time,trial)=squeeze(W_M1O(:,:,trial))'*squeeze(Rate_M1(:,time,trial)) + squeeze(W_M2O(:,:,trial))'*squeeze(Rate_M2(:,time,trial))+ squeeze(W_M3O(:,:,trial))'*squeeze(Rate_M3(:,time,trial))-bias; %net input
            Rate_Out(:,time+1,trial)=(ones(nResp,1)./(ones(nResp,1) + exp(-(net_Out(:,time,trial))))) .* (ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out(:,1,time,trial))-0.6)))); %Output layer
            
        end;        %end of trialloop 
        
        
        maxi=squeeze(max(Rate_Out(:,:,trial),[],2));
        [re,rid]=max(maxi);
        if rid==1
            response(1,trial)= 1;  
        elseif rid==2
            response(2,trial)= 1;
        elseif rid==3
            response(3,trial)= 1;    
        end;
        
        %Critic processes
        %reward value/ accuracy determination
        if squeeze(response(:,trial))==squeeze(Objective(:,Input(1,trial),trial))
            rew(1,trial)=1;
        else
            rew(1,trial)=0;
        end;
        
        %value unit update
        V(1,trial)=E(:,trial)'* 0.5* (LFC(2:end,trial)+ones(nmod,1)); 
        
        %Prediction errors
        negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
        posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
        %Value weight update
        E(:,trial+1)= E(:,trial) + lp * V(1,trial) * (posPE(1,trial)-negPE(1,trial)) * 0.5 * (LFC(2:end,trial)+ones(nmod,1));
        
        %switch unit update
        S(1,trial+1)=0.8*S(1,trial)+0.2*(negPE(1,trial));
        
        %LFC update
        if trial > 1
            Inhibition(:,trial)=Inhibition(:,trial-1)*0.9;
        end;
        
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
       
        %Weight updating
        %compute general errorscore at each output unit
        Errorscore(:,trial)=(Objective(:,Input(1,trial),trial)-max(Rate_Out(:,:,trial),[],2)).^2;
        %compute delta_output
        delta_out(:,trial)=(Objective(:,Input(1,trial),trial)-max(Rate_Out(:,:,trial),[],2)) .* max(Rate_Out(:,:,trial),[],2) .* (ones(nResp,1)-max(Rate_Out(:,:,trial),[],2));
        %update weights from hidden M1 to output layer
        W_M1O(:,:,trial+1)=W_M1O(:,:,trial)+beta(1,b) * max(Rate_M1(:,:,trial),[],2)* delta_out(:,trial)'; 
        %update weights from hidden M1 to output layer
        W_M2O(:,:,trial+1)=W_M2O(:,:,trial)+beta(1,b) * max(Rate_M2(:,:,trial),[],2)* delta_out(:,trial)';
        %update weights from hidden M1 to output layer
        W_M3O(:,:,trial+1)=W_M3O(:,:,trial)+beta(1,b) * max(Rate_M3(:,:,trial),[],2)* delta_out(:,trial)';
        %compute delta hidden layer M1
        delta_M1(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M1O(:,:,trial))') .* max(Rate_M1(:,:,trial),[],2)' .* ((ones(nM1,1))-squeeze(max(Rate_M1(:,:,trial),[],2)))');
        %compute delta hidden layer M2
        delta_M2(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M2O(:,:,trial))') .* max(Rate_M2(:,:,trial),[],2)' .* ((ones(nM2,1))-squeeze(max(Rate_M2(:,:,trial),[],2)))');
        %compute delta hidden layer M2
        delta_M3(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M3O(:,:,trial))') .* max(Rate_M3(:,:,trial),[],2)' .* ((ones(nM3,1))-squeeze(max(Rate_M3(:,:,trial),[],2)))');
        %update weights from input to hidden layer M1
        W_IM1(:,:,trial+1)=W_IM1(:,:,trial)+ beta(1,b) * max(Rate_Input(:,:,trial),[],2) * delta_M1(:,trial)';
        %update weights from input to hidden layer M2
        W_IM2(:,:,trial+1)=W_IM2(:,:,trial)+ beta(1,b) * max(Rate_Input(:,:,trial),[],2) * delta_M2(:,trial)';
        %update weights from input to hidden layer M2
        W_IM3(:,:,trial+1)=W_IM3(:,:,trial)+ beta(1,b) * max(Rate_Input(:,:,trial),[],2) * delta_M3(:,trial)';
        
        %check synchronization
        for p=1:nStim
            for q=1:nM1
                %sync measure (cross correlation at phase lag zero)
                sync_IM1(p,q,trial)=corr(squeeze(Phase_Input(p,1,251:T,trial)),squeeze(Phase_M1(q,1,251:T,trial)));
            end;
            for M=1:nM2
                %sync measure (cross correlation at phase lag zero)
                sync_IM2(p,M,trial)=corr(squeeze(Phase_Input(p,1,251:T,trial)),squeeze(Phase_M2(M,1,251:T,trial)));
            end;
            for M=1:nM3
                %sync measure (cross correlation at phase lag zero)
                sync_IM3(p,M,trial)=corr(squeeze(Phase_Input(p,1,251:T,trial)),squeeze(Phase_M3(M,1,251:T,trial)));
            end;
        end;
        prog=trial
    end;
 
 %%basic analyses
 %nbins=20;
 %binned_Errorscore=zeros(1,nbins*3);
 %binned_accuracy=zeros(1,nbins*3);
 %bin_edges=zeros(1,(nbins*3)+1);
 
 %bin_edges(1,1:nbins+1)=0:POT_1/nbins:POT_1;
 %bin_edges(1,nbins+1:(nbins*2)+1)=POT_1:POT_1/nbins:POT_2;
 %bin_edges(1,(2*nbins)+1:(nbins*3)+1)=POT_2:POT_1/nbins:Tr; 
  
 %for bin=1:nbins*3
 %    binned_Errorscore(1,bin)=mean(mean(Errorscore(:,(bin_edges(bin)+1):bin_edges(bin+1))));
 %    binned_accuracy(1,bin)=mean(rew(1,(bin_edges(bin)+1):bin_edges(bin+1)));
 %end;
 %save(['backprop_sync_Beta',num2str(b),'Rep',num2str(r)]);
    end;
end;
