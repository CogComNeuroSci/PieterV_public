
%% Defining amount of loops
Rep=10;                         %amount of replications
iterations=5;                   %number of iterations in negative phase
Tr=3600;                        %number of trials
betas=11;                       %beta iterations
beta=0:1/(betas-1):1;           %learning rate values

%other variables
POT=Tr/6:Tr/6:Tr;                 %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);                %third part
part4=POT(3)+1:POT(4);
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);
%% basic model build-up
nStim=12;                %number input units
nM1=6;                  %number hidden units in module 1
nResp=3;                %number of response options
nInput=81;               %number of input patterns
bias=5;                 %bias parameter

%% in- and output patterns
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
W_IM1(:,:,1)=rand(nStim,nM1)*2.5;        
W_M1O(:,:,1)=rand(nM1,nResp)*2.5;  

%% Learning

%weight change
delta_M1=zeros(nStim,nM1,Tr);       
delta_M1out=zeros(nM1,nResp,Tr);   
Errorscore=zeros(nResp,Tr);         %errorscore at negative phase

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
        [re,rid]=max(Rate_Out_min(:,trial,i));
        if rid==1
            response(1,trial,i)= 1;  
        elseif rid==2
            response(2,trial,i)= 1;
        elseif rid==3
            response(3,trial,i)= 1;    
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
    delta_M1out(:,:,trial+1)=beta(1,b) * ((Rate_M1_plus(:,trial)*Rate_Out_plus(:,trial)')-(Rate_M1_min(:,trial,i)*Rate_Out_min(:,trial,i-1)'));
    %change weights
    W_IM1(:,:,trial+1)=W_IM1(:,:,trial) + delta_M1(:,:,trial+1);
    W_M1O(:,:,trial+1)= W_M1O(:,:,trial) + delta_M1out(:,:,trial+1);
    
    prog=trial
end;

%% track learning by accuracy over bins
 %nbins=20;
 %binned_Errorscore_min=zeros(1,nbins*3);
 %binned_accuracy_min=zeros(1,nbins*3);
 %binned_Errorscore_test=zeros(1,nbins*3);
 %binned_accuracy_test=zeros(1,nbins*3);

 %bin_edges=zeros(1,(nbins*3)+1);
 
 %bin_edges(1,1:nbins+1)=0:POT_1/nbins:POT_1;
 %bin_edges(1,nbins+1:(nbins*2)+1)=POT_1:POT_1/nbins:POT_2;
 %bin_edges(1,(2*nbins)+1:(nbins*3)+1)=POT_2:POT_1/nbins:Tr; 
  
 %for bin=1:nbins*3
 %    binned_Errorscore_min(1,bin)=mean(mean(Errorscore(:,(bin_edges(bin)+1):bin_edges(bin+1))));
 %    binned_accuracy_min(1,bin)=mean(rew(1,(bin_edges(bin)+1):bin_edges(bin+1)));
 %end;
 save(['RBM_nosync_Beta',num2str(b),'Rep',num2str(r)],'Errorscore','rew');
    end;
end;
    