%{
    Script for the synaptic backpropagation model
%}
%% Defining amount of loops
Rep=10;                 %amount of replications
Tr=2400;                %amount of trials
betas=11;               %beta iterations
beta=0:1/(betas-1):1;           %values of beta (learning rate)

%other variables
POT_1=Tr/3;             %point of switch to task rule 2
POT_2=2*Tr/3;           %switch again to task rule 1
part1=1:POT_1;          %trials in first part
part2=POT_1+1:POT_2;    %trials in second part
part3=POT_2+1:Tr;       %trials in third part
%% basic model build-up
nStim=6;                %number input units
nM1=4;                  %number hidden units in module 1
nResp=2;                %number of response options
nInput=8;               %number of input patterns
bias=5;                 %bias parameter

%% in- and output patterns
Activation=zeros(nStim,nInput);      %input patterns
Activation(1:6,1)=[1,0,1,0,1,0];                %blauw links cirkel    (1)
Activation(1:6,2)=[1,0,0,1,1,0];                %blauw rechts cirkel   (2)
Activation(1:6,3)=[0,1,1,0,1,0];                %rood links cirkel     (3)
Activation(1:6,4)=[0,1,0,1,1,0];                %rood rechts cirkel    (4)
Activation(1:6,5)=[1,0,1,0,0,1];                %blauw links vierkant  (5)      
Activation(1:6,6)=[1,0,0,1,0,1];                %blauw rechts vierkant (6)   
Activation(1:6,7)=[0,1,1,0,0,1];                %rood links vierkant   (7)
Activation(1:6,8)=[0,1,0,1,0,1];                %rood rechts vierkant  (8)

%learning objectives for output layer per experimental part
Objective=zeros(nResp,nInput,Tr);    
Objective(1,[1,2,5,7],part1)=1;
Objective(2,[3,4,6,8],part1)=1;
Objective(1,[3,5,6,7],part2)=1;
Objective(2,[1,2,4,8],part2)=1;
Objective(1,[1,2,5,7],part3)=1;
Objective(2,[3,4,6,8],part3)=1; 

%% simulation loops
for b=11:betas
    for r=10:Rep
%% model initialization
%Processing module
Rate_Input=zeros(nStim,Tr);             %Input rate neurons
Rate_M1=zeros(nM1,Tr);                  %Hidden rate neurons
Rate_Out=zeros(nResp,Tr);               %Output rate neurons

net_M1=zeros(nM1,Tr);                   %net input for the hidden neurons
net_Out=zeros(nResp,Tr);                %net input for the output neurons

%weights
W_IM1=zeros(nStim,nM1,Tr);   
W_M1O=zeros(nM1,nResp,Tr); 
%initial random weight strength
W_IM1(:,:,1)=rand(nStim,nM1)*5;
W_M1O(:,:,1)=rand(nM1,nResp)*5; 

%% Learning 
Errorscore=zeros(nResp,Tr);             %errorscore
delta_out=zeros(nResp,Tr);              %weightchange hidden to output weights
delta_M1=zeros(nM1,Tr);                 %weightchange input to hidden weights

%% Input to model
In=repmat(1:nInput,3,(POT_1));      %make input list of patterns
%randomization for each part seperately
Input=zeros(1,Tr);                       
Input(1,part1)=In(1,randperm(POT_1));
Input(1,part2)=In(2,randperm(POT_1));
Input(1,part3)=In(3,randperm(POT_1));

%% extra
Z=zeros(nStim,Tr);
response=zeros(2,Tr);               %track responses
rew=zeros(1,Tr);                    %track accuracy
RT=zeros(1,Tr);

%% Model
%while trial <201 ||  mean(mean(Errorscore(:,trial-200:trial),1),2)>0.05
 %trial=trial+1;
%loop to test until convergence

%trial loop
for trial=1:Tr
    
    Z(:,trial)=Activation(:,Input(1,trial)); 

    %Input layer activation
    Rate_Input(:,trial)=Z(:,trial); 
       
    %Hidden layer activation
    net_M1(:,trial)=W_IM1(:,:,trial)'*Rate_Input(:,trial)-bias;
    Rate_M1(:,trial)=ones(nM1,1)./(ones(nM1,1)+exp(-net_M1(:,trial))); 
        
    %Output layer activation 
    net_Out(:,trial)=W_M1O(:,:,trial)'*Rate_M1(:,trial)-bias;
    Rate_Out(:,trial)=ones(nResp,1)./(ones(nResp,1)+exp(-net_Out(:,trial))); 
            
    if Rate_Out(1,trial)>Rate_Out(2,trial)  %response 1
        response(1,trial)= 1;
        response(2,trial)= 0;    
    else
        response(1,trial)= 0;
        response(2,trial)= 1;
    end;
    
    % accuracy determination
    if squeeze(response(:,trial))==squeeze(Objective(:,Input(1,trial),trial))
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    %Weight updating
    %compute general errorscore at each output unit
    Errorscore(:,trial)=(Objective(:,Input(1,trial),trial)-Rate_Out(:,trial).^2);
    %compute delta_output
    delta_out(:,trial)=squeeze((Objective(:,Input(1,trial),trial)-Rate_Out(:,trial)).*Rate_Out(:,trial).*(ones(nResp,1)-Rate_Out(:,trial)));
    %update weights from hidden M1 to output layer
    W_M1O(:,:,trial+1)=squeeze(W_M1O(:,:,trial))+beta(1,b)*Rate_M1(:,trial)*squeeze(delta_out(:,trial))';
    %compute delta hidden layer M1
    delta_M1(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M1O(:,:,trial))').*Rate_M1(:,trial)'.*(ones(nM1,1)-Rate_M1(:,trial))');
    %update weights from input to hidden layer
    W_IM1(:,:,trial+1)=squeeze(W_IM1(:,:,trial))+beta(1,b)*Rate_Input(:,trial)*squeeze(delta_M1(:,trial))';
    
    prog=trial
end;

%% track learning by accuracy over bins
 nbins=20;
 binned_Errorscore=zeros(1,nbins*3);
 binned_accuracy=zeros(1,nbins*3);
 bin_edges=zeros(1,(nbins*3)+1);
 
 bin_edges(1,1:nbins+1)=0:POT_1/nbins:POT_1;
 bin_edges(1,nbins+1:(nbins*2)+1)=POT_1:POT_1/nbins:POT_2;
 bin_edges(1,(2*nbins)+1:(nbins*3)+1)=POT_2:POT_1/nbins:Tr; 
  
 for bin=1:nbins*3
     binned_Errorscore(1,bin)=mean(mean(Errorscore(:,(bin_edges(bin)+1):bin_edges(bin+1))));
     binned_accuracy(1,bin)=mean(rew(1,(bin_edges(bin)+1):bin_edges(bin+1)));
 end;
    save(['backprop_nosync_Beta',num2str(b),'Rep',num2str(r)]);
    end;
end;
