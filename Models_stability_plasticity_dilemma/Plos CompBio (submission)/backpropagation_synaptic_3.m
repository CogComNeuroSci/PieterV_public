%{
    Script for running the synaptic BP model for the three-dimensional task
%}

%% Defining amount of loops
Rep=10;                         %amount of replications
Tr=3600;                        %amount of trials
betas=11;                       %beta iterations
beta=0:1/(betas-1):1;           %values of beta (learning rate)

POT=Tr/6:Tr/6:Tr;               %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                 %first part
part2=POT(1)+1:POT(2);          %second part
part3=POT(2)+1:POT(3);          %third part
part4=POT(3)+1:POT(4);          %...
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);
%% basic model build-up
nStim=13;                       %number input units
nM1=6;                          %number hidden units in module 1
nResp=3;                        %number of response options
nInput=81;                      %number of input patterns
bias=5;                         %bias parameter

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
for b=1:betas                           %learning rates
    for r=1:Rep                         %replications
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
W_IM1(:,:,1)=rand(nStim,nM1)*2.5;
W_M1O(:,:,1)=rand(nM1,nResp)*2.5; 

%% Learning 
Errorscore=zeros(nResp,Tr);             %errorscore
delta_out=zeros(nResp,Tr);              %weightchange hidden to output weights
delta_M1=zeros(nM1,Tr);                 %weightchange input to hidden weights

%% Input to model
In=repmat(1:nInput,6,(POT(1)));      %make input list of patterns
%randomization for each part seperately
Input=zeros(1,Tr);                       
Input(1,part1)=In(1,randperm(POT(1)));
Input(1,part2)=In(2,randperm(POT(1)));
Input(1,part3)=In(3,randperm(POT(1)));
Input(1,part4)=In(4,randperm(POT(1)));
Input(1,part5)=In(5,randperm(POT(1)));
Input(1,part6)=In(6,randperm(POT(1)));

%% extra
Z=zeros(nStim,Tr);
response=zeros(3,Tr);               %track responses
rew=zeros(1,Tr);                    %track accuracy

%% the model

%trial loop
for trial=1:Tr
    
    %Initialize input vector
    Z(:,trial)=Activation(:,Input(1,trial)); 

    %Input layer activation
    Rate_Input(:,trial)=Z(:,trial); 
       
    %Hidden layer activation
    net_M1(:,trial)=W_IM1(:,:,trial)'*Rate_Input(:,trial)-bias;
    Rate_M1(:,trial)=ones(nM1,1)./(ones(nM1,1)+exp(-net_M1(:,trial))); 
        
    %Output layer activation 
    net_Out(:,trial)=W_M1O(:,:,trial)'*Rate_M1(:,trial)-bias;
    Rate_Out(:,trial)=ones(nResp,1)./(ones(nResp,1)+exp(-net_Out(:,trial))); 
    
    %Response determination
    [re,rid]=max(Rate_Out(:,trial));
    if rid==1
        response(1,trial)= 1;  
    elseif rid==2
        response(2,trial)= 1;
    elseif rid==3
        response(3,trial)= 1;    
    end;
    
    % accuracy determination
    if squeeze(response(:,trial))==squeeze(Objective(:,Input(1,trial),trial))
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    %Weight updating
    %compute general errorscore at each output unit
    Errorscore(:,trial)=(Objective(:,Input(1,trial),trial)-Rate_Out(:,trial)).^2;
    %compute delta_output
    delta_out(:,trial)=squeeze((Objective(:,Input(1,trial),trial)-Rate_Out(:,trial)).*Rate_Out(:,trial).*(ones(nResp,1)-Rate_Out(:,trial)));
    %update weights from hidden M1 to output layer
    W_M1O(:,:,trial+1)=squeeze(W_M1O(:,:,trial))+beta(1,b)*Rate_M1(:,trial)*squeeze(delta_out(:,trial))';
    %compute delta hidden layer M1
    delta_M1(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M1O(:,:,trial))').*Rate_M1(:,trial)'.*(ones(nM1,1)-Rate_M1(:,trial))');
    %update weights from input to hidden layer
    W_IM1(:,:,trial+1)=squeeze(W_IM1(:,:,trial))+beta(1,b)*Rate_Input(:,trial)*squeeze(delta_M1(:,trial))';
    
    %print progress
    prog=trial
end;

    %% save data
    save(['backprop_nosync_Beta',num2str(b),'Rep',num2str(r)],'rew', 'Errorscore');
    end;
end;
