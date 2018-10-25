
%% Defining amount of loops
Rep=10;                         %amount of replications
iterations=5;                   %number of iterations in negative phase
Tr=2400;                        %number of trials
betas=11;                       %beta iterations
beta=0:1/(betas-1):1;           %learning rate values

%other variables
POT_1=Tr/3;                     %point of switch to task rule 2
POT_2=2*Tr/3;                   %switch again to task rule 1
part1=1:POT_1;                  %first part of task
part2=POT_1+1:POT_2;            %second part of task
part3=POT_2+1:Tr;               %third part of task
%% model build-up
nStim=6;                        %number of units in input layer
nM1=4;                          %number of units in hidden layer
nResp=2;                        %number of units in output layer
nInput=8;                       %number of input patterns
bias=5;                         %bias parameter

%% In- and output patterns
%Input patterns
Activation=zeros(nStim,nInput);
Activation(1:6,1)=[1,0,1,0,1,0];              %blauw links cirkel    (1)
Activation(1:6,2)=[1,0,0,1,1,0];              %blauw rechts cirkel   (2)
Activation(1:6,3)=[0,1,1,0,1,0];              %rood links cirkel     (3)
Activation(1:6,4)=[0,1,0,1,1,0];              %rood rechts cirkel    (4)
Activation(1:6,5)=[1,0,1,0,0,1];              %blauw links vierkant  (5)      
Activation(1:6,6)=[1,0,0,1,0,1];              %blauw rechts vierkant (6)   
Activation(1:6,7)=[0,1,1,0,0,1];              %rood links vierkant   (7)
Activation(1:6,8)=[0,1,0,1,0,1];              %rood rechts vierkant  (8)

%learning objectives for output layer
Objective=zeros(nResp,nInput,Tr);    
Objective(1,[1,2,5,7],part1)=1;
Objective(2,[3,4,6,8],part1)=1;
Objective(1,[1,2,5,7],part3)=1;
Objective(2,[3,4,6,8],part3)=1;
Objective(1,[3,4,6,8],part2)=1;
Objective(2,[1,2,5,7],part2)=1;

%% simulation loops
for b=1:betas
    for r=1:Rep
        
%% model initialization
%Processing module
%positive phase
Rate_Input_plus=zeros(nStim,Tr);                   %Input neurons positive phase
Rate_M1_plus=zeros(nM1,Tr);                        %Hidden neurons positive phase
Rate_Out_plus=zeros(nResp,Tr);                     %Output neurons positive phase

net_M1_plus=zeros(nM1,Tr);                         %net input hidden layer positive phase

Rate_Input_min=zeros(nStim,Tr,iterations);                    %Input neurons negative phase
Rate_M1_min=zeros(nM1,Tr,iterations);            %Hidden neurons negative phase
Rate_Out_min=zeros(nResp,Tr,iterations);         %Output neurons negative phase

net_M1_min=zeros(nM1,Tr,iterations);               %net input hidden layer negative phase
net_Out_min=zeros(nResp,Tr,iterations);            %net input output layer negative phase

%binarizations
bin_M1=zeros(nM1,Tr,iterations);

%weights
W_IM1=zeros(nStim,nM1,Tr);                         %weights between input and hidden layer
W_M1O=zeros(nM1,nResp,Tr);                         %weights between hidden and output layer
%starting values for weights
W_IM1(:,:,1)=rand(nStim,nM1)*5;        
W_M1O(:,:,1)=rand(nM1,nResp)*5;  

%% Learning

%weight change
delta_M1=zeros(nStim,nM1,Tr);       
delta_M1out=zeros(nM1,nResp,Tr); 
    
Errorscore=zeros(nResp,Tr);         %errorscore at negative phase

%% Input to model
In=repmat(1:nInput,Tr/nInput);  %make list of input patterns
In=In(1,:);                                     

Input=zeros(1,Tr);
Input(1,:)=In(1,randperm(Tr));             %randomization of these input list

%% recording
Z=zeros(nStim,Tr);
Q=zeros(nResp,Tr);
Q_min=zeros(nResp,Tr,iterations);
response=zeros(nResp,Tr,iterations);
rew=zeros(1,Tr);                   

%% Model
for trial=1:Tr
    
    %Positive phase
    Z(:,trial)=Activation(:,Input(1,trial));
    Q(:,trial)=Objective(:,Input(1,trial),trial);
    %clamping visible layers
    Rate_Input_plus(:,trial)=Z(:,trial);
    Rate_Out_plus(:,trial)=Q(:,trial);
    
    %Hidden activation
    net_M1_plus(:,trial)=W_IM1(:,:,trial)'*Rate_Input_plus(:,trial)+ W_M1O(:,:,trial) *Rate_Out_plus(:,trial)-bias; %input from both layers
    Rate_M1_plus(:,trial)=ones(nM1,1)./(ones(nM1,1)+exp(-net_M1_plus(:,trial)));
    
    %Negative phase
    for i=1:iterations
        Rate_Input_min(:,trial,i)=Z(:,trial);
    
        net_M1_min(:,trial,i)=W_IM1(:,:,trial)'*Rate_Input_min(:,trial)+ W_M1O(:,:,trial) *Q_min(:,trial,i)-bias;
        Rate_M1_min(:,trial,i)=ones(nM1,1)./(ones(nM1,1)+exp(-net_M1_min(:,trial,i)));
        
        bin_M1(:,trial,i)=Rate_M1_min(:,trial,i)>rand(nM1,1,1);
        
        net_Out_min(:,trial,i)=W_M1O(:,:,trial)'*bin_M1(:,trial,i)-bias;
        Rate_Out_min(:,trial,i)=ones(nResp,1)./(ones(nResp,1)+exp(-net_Out_min(:,trial,i)));
        
        %choose biggest 
        if Rate_Out_min(1,trial,i)>Rate_Out_min(2,trial,i)
            response(1,trial,i)=1;
        else
            response(2,trial,i)=1;
        end;
        Q_min(:,trial,i+1)=response(:,trial,i);

    end;
    
    if response(:,trial,i)== Q(:,trial)  
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    %compute errorscore at each output unit
    Errorscore(:,trial)=(Rate_Out_plus(:,trial)-squeeze(Rate_Out_min(:,trial,i))).^2;
    
    %compute weightchange
    delta_M1(:,:,trial+1)=beta(1,b) *((Rate_Input_plus(:,trial)*Rate_M1_plus(:,trial)')-(Rate_Input_min(:,trial,i)*squeeze(Rate_M1_min(:,trial,i))'));
    delta_M1out(:,:,trial+1)=beta(1,b) * ((Rate_M1_plus(:,trial)*Rate_Out_plus(:,trial)')-(Rate_M1_min(:,trial,i)*Rate_Out_min(:,trial,i)'));
    %change weights
    W_IM1(:,:,trial+1)=W_IM1(:,:,trial) + delta_M1(:,:,trial+1);
    W_M1O(:,:,trial+1)= W_M1O(:,:,trial) + delta_M1out(:,:,trial+1);
    
    prog=trial
end;

%% track learning by accuracy over bins
 nbins=20;
 binned_Errorscore_min=zeros(1,nbins*3);
 binned_accuracy_min=zeros(1,nbins*3);
 binned_Errorscore_test=zeros(1,nbins*3);
 binned_accuracy_test=zeros(1,nbins*3);

 bin_edges=zeros(1,(nbins*3)+1);
 
 bin_edges(1,1:nbins+1)=0:POT_1/nbins:POT_1;
 bin_edges(1,nbins+1:(nbins*2)+1)=POT_1:POT_1/nbins:POT_2;
 bin_edges(1,(2*nbins)+1:(nbins*3)+1)=POT_2:POT_1/nbins:Tr; 
  
 for bin=1:nbins*3
     binned_Errorscore_min(1,bin)=mean(mean(Errorscore(:,(bin_edges(bin)+1):bin_edges(bin+1))));
     binned_accuracy_min(1,bin)=mean(rew(1,(bin_edges(bin)+1):bin_edges(bin+1)));
 end;
 save(['RBM_nosync_Beta',num2str(b),'Rep',num2str(r)],'binned_Errorscore_min','binned_accuracy_min');
    end;
end;
    