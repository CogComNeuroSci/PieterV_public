
%% Defining amount of loops
Rep=10;                         %amount of replications
T=500;                         %trialtime
Tr=2400;                        %amount of trials
betas=11;                       %beta iterations
beta=0:1/(betas-1):1;                   %values of beta (learning rate)
ITI=250;

%other variables
POT_1=Tr/3;                     %point of switch to task rule 2
POT_2=2*Tr/3;                   %switch again to task rule 1
part1=1:POT_1;                  %first part of task
part2=POT_1+1:POT_2;            %second part of task
part3=POT_2+1:Tr;               %third part of task

%% Model build-up
% Processing module
nStim=6;                %number of Input units
nM1=4;                  %number of Hidden module 1 units
nM2=4;                  %number of Hidden module 2 units
nmod=2;                 %number of Hidden modules
nResp=2;                %number of Response options
nInput=(nStim/3)^3;     %number of Input patterns
r2max=1;                %max amplitude
Cg=0.58;                 %coupling gamma waves
damp=0.3;              %damping parameter
decay=0.9;              %decay parameter
bias=5;                 %bias parameter

%Control module
r2_acc=0.05;               %radius ACC
Ct=0.07;                %coupling theta waves
damp_acc=0.003;          %damping parameter ACC
acc_slope=10;           %acc slope parameter

%Critic
lp=0.01;                %learning parameter critic

%% in- and output patterns

%Input patterns according to presented stimulus
Activation=zeros(nStim,nInput);
Activation(:,1)=[1,0,1,0,1,0];         %blauw links cirkel => response1
Activation(:,2)=[1,0,0,1,1,0];         %blauw rechts cirkel => response 1
Activation(:,3)=[0,1,1,0,1,0];         %rood links cirkel => response 2
Activation(:,4)=[0,1,0,1,1,0];         %rood rechts cirkel => response 2
Activation(:,5)=[1,0,1,0,0,1];         %blauw links vierkant => response 1       
Activation(:,6)=[1,0,0,1,0,1];         %blauw rechts vierkant => response 2   
Activation(:,7)=[0,1,1,0,0,1];         %rood links vierkant => response 1
Activation(:,8)=[0,1,0,1,0,1];         %rood rechts vierkant => response 2

%learning objectives for output units 
Objective=zeros(nResp,nInput,Tr);
Objective(1,[1,2,5,7],part1)=1;
Objective(2,[3,4,6,8],part1)=1;
Objective(1,[3,4,6,8],part2)=1;
Objective(2,[1,2,5,7],part2)=1;
Objective(1,[1,2,5,7],part3)=1;
Objective(2,[3,4,6,8],part3)=1;

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

Phase_Out=zeros(nResp,2,T,Tr);  %phase neurons output layer
Rate_Out=zeros(nResp,T,Tr);     %rate neurons output layer

net_M1=zeros(nM1,T,Tr);         %net_input received by hidden units M1
net_M2=zeros(nM1,T,Tr);         %net_input received by hidden units M2
net_Out=zeros(nResp,T,Tr);      %net_input received by output units

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

%Integrator layer 
Integr=zeros(nResp,T,Tr); %integrator unit

% Control module
LFC=zeros(nmod+1,Tr);         %LFC units
if rand>0.5
    LFC(1,1)=-1;
    LFC(2,1)=1;
else
    LFC(1,1)=1;
    LFC(2,1)=-1;
end;
LFC(3,1)=1;

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

%% Input
%randomization of input patterns
In=repmat(1:nInput,3,(POT_1));
Input=zeros(1,Tr);
Input(1,part1)=In(1,randperm(POT_1));
Input(1,part2)=In(2,randperm(POT_1));
Input(1,part3)=In(3,randperm(POT_1));

%% Other
%starting points of oscillations
start_Input=rand(nStim,2,1,1);   
start_M1=rand(nM1,2,1,1);
start_M2=rand(nM2,2,1,1);
start_Out=rand(nResp,2,1,1); 
start_ACC=rand(2,1,1);

%assign to phase code units
Phase_Input(:,:,1,1)=start_Input;        
Phase_M1(:,:,1,1)=start_M1;
Phase_M2(:,:,1,1)=start_M2;
Phase_Out(:,:,1,1)=start_Out;
ACC(:,1,1)=start_ACC;

%radius
r2_Input=zeros(nStim,T,Tr);        
r2_M1=zeros(nM1,T,Tr);
r2_M2=zeros(nM2,T,Tr);
r2_ACC=zeros(T,Tr);
r2_Out=zeros(nResp,T,Tr);

%recordings 
Z=zeros(nStim,Tr);               %input matrix
response=zeros(nResp,Tr);        %response record
sync_IM1=zeros(nStim,nM1,Tr);    %sync matrix (correlations)
sync_IM2=zeros(nStim,nM2,Tr);    %sync matrix (correlations)
Hit=zeros(T,Tr);                 %Hit record

%% the model
    %trial loop 
    for trial=1:Tr  
        
        %oscillatory starting points are end points of previous trials
        if trial>1          
            Phase_Input(:,:,1,trial)=Phase_Input(:,:,time,trial-1);
            Phase_M1(:,:,1,trial)=Phase_M1(:,:,time,trial-1);
            Phase_M2(:,:,1,trial)=Phase_M2(:,:,time,trial-1);
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
            r2_Out(:,t,trial)=squeeze(dot(Phase_Out(:,:,t,trial),Phase_Out(:,:,t,trial),2));           %Output layer
            r2_ACC(t,trial)=dot(ACC(:,t,trial),ACC(:,t,trial));                                        %ACC
            
            %updating phase code neurons
            Phase_Input(:,1,t+1,trial)=Phase_Input(:,1,t,trial)-Cg*Phase_Input(:,2,t,trial)-damp*(r2_Input(:,t,trial)>r2max).*Phase_Input(:,1,t,trial); % excitatory cells
            Phase_Input(:,2,t+1,trial)=Phase_Input(:,2,t,trial)+Cg*Phase_Input(:,1,t,trial)-damp*(r2_Input(:,t,trial)>r2max).*Phase_Input(:,2,t,trial); % inhibitory cells

            Phase_M1(:,1,t+1,trial)=Phase_M1(:,1,t,trial)-Cg*Phase_M1(:,2,t,trial)-damp*(r2_M1(:,t,trial)>r2max).*Phase_M1(:,1,t,trial); % excitatory cells
            Phase_M1(:,2,t+1,trial)=Phase_M1(:,2,t,trial)+Cg*Phase_M1(:,1,t,trial)-damp*(r2_M1(:,t,trial)>r2max).*Phase_M1(:,2,t,trial); % inhibitory cells

            Phase_M2(:,1,t+1,trial)=Phase_M2(:,1,t,trial)-Cg*Phase_M2(:,2,t,trial)-damp*(r2_M2(:,t,trial)>r2max).*Phase_M2(:,1,t,trial); % excitatory cells
            Phase_M2(:,2,t+1,trial)=Phase_M2(:,2,t,trial)+Cg*Phase_M2(:,1,t,trial)-damp*(r2_M2(:,t,trial)>r2max).*Phase_M2(:,2,t,trial); % inhibitory cells

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
                Phase_Input(:,:,t+1,trial)=decay*Phase_Input(:,:,t,trial)+ LFC(3,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out(:,:,t+1,trial)=decay*Phase_Out(:,:,t,trial)+ LFC(3,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1(:,:,t+1,trial)=decay*Phase_M1(:,:,t,trial)+LFC(1,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2(:,:,t+1,trial)=decay*Phase_M2(:,:,t,trial)+LFC(2,trial)*(ones(nM2,1))* Gaussian;
            end;
        end;
        
        for time=ITI:T
            
            %computing radius of oscillations
            r2_Input(:,time,trial)=squeeze(dot(Phase_Input(:,:,time,trial),Phase_Input(:,:,time,trial),2));     %Input layer
            r2_M1(:,time,trial)=squeeze(dot(Phase_M1(:,:,time,trial),Phase_M1(:,:,time,trial),2));              %Hidden layer M1
            r2_M2(:,time,trial)=squeeze(dot(Phase_M2(:,:,time,trial),Phase_M2(:,:,time,trial),2));              %Hidden layer M1
            r2_Out(:,time,trial)=squeeze(dot(Phase_Out(:,:,time,trial),Phase_Out(:,:,time,trial),2));           %Output layer
            r2_ACC(time,trial)=dot(ACC(:,time,trial),ACC(:,time,trial));                                        %ACC
            
            %updating phase code neurons
            Phase_Input(:,1,time+1,trial)=Phase_Input(:,1,time,trial)-Cg*Phase_Input(:,2,time,trial)-damp*(r2_Input(:,time,trial)>r2max).*Phase_Input(:,1,time,trial); % excitatory cells
            Phase_Input(:,2,time+1,trial)=Phase_Input(:,2,time,trial)+Cg*Phase_Input(:,1,time,trial)-damp*(r2_Input(:,time,trial)>r2max).*Phase_Input(:,2,time,trial); % inhibitory cells

            Phase_M1(:,1,time+1,trial)=Phase_M1(:,1,time,trial)-Cg*Phase_M1(:,2,time,trial)-damp*(r2_M1(:,time,trial)>r2max).*Phase_M1(:,1,time,trial); % excitatory cells
            Phase_M1(:,2,time+1,trial)=Phase_M1(:,2,time,trial)+Cg*Phase_M1(:,1,time,trial)-damp*(r2_M1(:,time,trial)>r2max).*Phase_M1(:,2,time,trial); % inhibitory cells

            Phase_M2(:,1,time+1,trial)=Phase_M2(:,1,time,trial)-Cg*Phase_M2(:,2,time,trial)-damp*(r2_M2(:,time,trial)>r2max).*Phase_M2(:,1,time,trial); % excitatory cells
            Phase_M2(:,2,time+1,trial)=Phase_M2(:,2,time,trial)+Cg*Phase_M2(:,1,time,trial)-damp*(r2_M2(:,time,trial)>r2max).*Phase_M2(:,2,time,trial); % inhibitory cells

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
                Phase_Input(:,:,time+1,trial)=decay*Phase_Input(:,:,time,trial)+ LFC(3,trial)*(ones(nStim,1))*Gaussian;
                Phase_Out(:,:,time+1,trial)=decay*Phase_Out(:,:,time,trial)+ LFC(3,trial)*(ones(nResp,1))*Gaussian;
                Phase_M1(:,:,time+1,trial)=decay*Phase_M1(:,:,time,trial)+LFC(1,trial)*(ones(nM1,1))* Gaussian;
                Phase_M2(:,:,time+1,trial)=decay*Phase_M2(:,:,time,trial)+LFC(2,trial)*(ones(nM2,1))* Gaussian;
            end;
            
            %updating rate code units
            Rate_Input(:,time,trial)=(Z(:,trial)).*(ones(nStim,1)./(ones(nStim,1)+exp(-5*(squeeze(Phase_Input(:,1,time,trial))-0.6))));%+(noise * rand(nStim,1))));%Input layer

            net_M1(:,time,trial)=W_IM1(:,:,trial)'* Rate_Input(:,time,trial)-bias; %net input
            Rate_M1(:,time+1,trial)=(ones(nM1,1)./(ones(nM1,1) + exp(-net_M1(:,time,trial)))) .* (ones(nM1,1)./(ones(nM1,1)+exp(-5*(squeeze(Phase_M1(:,1,time,trial))-0.6))));%+(noise * rand(nM1,1)))); %M1 activation

            net_M2(:,time,trial)=W_IM2(:,:,trial)'* Rate_Input(:,time,trial)-bias; %net input
            Rate_M2(:,time+1,trial)=(ones(nM2,1)./(ones(nM2,1) + exp(-net_M2(:,time,trial)))) .* (ones(nM2,1)./(ones(nM2,1)+exp(-5*(squeeze(Phase_M2(:,1,time,trial))-0.6))));%+(noise * rand(nM2,1)))); %M2 activation

            net_Out(:,time,trial)=squeeze(W_M1O(:,:,trial))'*squeeze(Rate_M1(:,time,trial)) + squeeze(W_M2O(:,:,trial))'*squeeze(Rate_M2(:,time,trial))-bias; %net input
            Rate_Out(:,time+1,trial)=(ones(nResp,1)./(ones(nResp,1) + exp(-(net_Out(:,time,trial))))) .* (ones(nResp,1)./(ones(nResp,1)+exp(-5*(squeeze(Phase_Out(:,1,time,trial))-0.6)))); %Output layer
            
        end;        %end of trialloop 
        
        %response determination
        if max(Rate_Out(1,:,trial))>max(Rate_Out(2,:,trial))  %response 1
            response(1,trial)= 1;
            response(2,trial)= 0;    
        else
            response(1,trial)= 0;
            response(2,trial)= 1;
        end;
        
        %Critic processes
        %reward value/ accuracy determination
        if squeeze(response(:,trial))==squeeze(Objective(:,Input(1,trial),trial))
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
       
        %Weight updating
        %compute general errorscore at each output unit
        Errorscore(:,trial)=(Objective(:,Input(1,trial),trial)-max(Rate_Out(:,:,trial),[],2)).^2;
        %compute delta_output
        delta_out(:,trial)=(Objective(:,Input(1,trial),trial)-max(Rate_Out(:,:,trial),[],2)) .* max(Rate_Out(:,:,trial),[],2) .* (ones(nResp,1)-max(Rate_Out(:,:,trial),[],2));
        %update weights from hidden M1 to output layer
        W_M1O(:,:,trial+1)=W_M1O(:,:,trial)+beta(1,b) * max(Rate_M1(:,:,trial),[],2)* delta_out(:,trial)'; 
        %update weights from hidden M1 to output layer
        W_M2O(:,:,trial+1)=W_M2O(:,:,trial)+beta(1,b) * max(Rate_M2(:,:,trial),[],2)* delta_out(:,trial)';
        %compute delta hidden layer M1
        delta_M1(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M1O(:,:,trial))') .* max(Rate_M1(:,:,trial),[],2)' .* ((ones(nM1,1))-squeeze(max(Rate_M1(:,:,trial),[],2)))');
        %compute delta hidden layer M2
        delta_M2(:,trial)=squeeze((delta_out(:,trial)'*squeeze(W_M2O(:,:,trial))') .* max(Rate_M2(:,:,trial),[],2)' .* ((ones(nM1,1))-squeeze(max(Rate_M2(:,:,trial),[],2)))');
        %update weights from input to hidden layer M1
        W_IM1(:,:,trial+1)=W_IM1(:,:,trial)+ beta(1,b) * max(Rate_Input(:,:,trial),[],2) * delta_M1(:,trial)';
        %update weights from input to hidden layer M2
        W_IM2(:,:,trial+1)=W_IM2(:,:,trial)+ beta(1,b) * max(Rate_Input(:,:,trial),[],2) * delta_M2(:,trial)';
        
        %check synchronization
        for p=1:nStim
            for q=1:nM1
                %sync measure (cross correlation at phase lag zero)
                sync_IM1(p,q,trial)=corr(squeeze(Phase_Input(p,1,251:T,trial)),squeeze(Phase_M1(q,1,251:T,trial)));
            end;
            for M=1:nM2
                %sync measure (cross correlation at phase lag zero)
                sync_IM2(p,M,trial)=corr(squeeze(Phase_Input(p,1,251:,trial)),squeeze(Phase_M2(M,1,251:T,trial)));
            end;
        end;
        prog=trial
    end;
 
 %basic analyses
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
 save(['backprop_sync_Beta',num2str(b),'Rep',num2str(r)]);
    end;
end;
