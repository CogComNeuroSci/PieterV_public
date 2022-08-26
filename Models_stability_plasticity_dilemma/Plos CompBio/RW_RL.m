%{
   Script for RW model RL parameter exploration
%}
%% Defining amount of loops
T=500;                  %trialtime
Tr=360;                 %amount of trials
betas=1;                %beta iterations
Beta=[0.2, 0.8];        %learning rate values
ITI=250;                %intertrial interval

POT=Tr/6:Tr/6:Tr;                 %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);            %third part
part4=POT(3)+1:POT(4);            %...
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);

%% model build-up
% Processing module
nUnits=12;                  %model units
r2max=1;                    %max amplitude
Cg=0.58;                    %coupling gamma waves (sampling frequency =500)
damp=0.3;                   %damping parameter
decay=0.9;                  %decay parameter

%Control module
r2_acc=0.05;                %radius ACC
Ct=0.07;                    %coupling theta waves
damp_acc=0.003;             %damping parameter ACC
acc_slope=10;               %acc_slope

%Critic
lp=[0.01, 0.05, 0.1, 0.2];  %learning rate RL unit
%% other variables
%Input patterns
Activation=zeros(nUnits,3);
Activation(1,1)=1;
Activation(2,2)=1;
Activation(3,3)=1;

%% Learning objectives
R1_units=4:3:12;
R2_units=5:3:12;
R3_units=6:3:12;

objective=zeros(nUnits,nUnits,Tr);

%objectives are different for each part
objective(1,R1_units,[part1,part4])=1;
objective(2,R2_units,[part1,part4])=1;
objective(3,R3_units,[part1,part4])=1;
objective(1,R2_units,[part2,part5])=1;
objective(2,R3_units,[part2,part5])=1;
objective(3,R1_units,[part2,part5])=1;
objective(1,R3_units,[part3,part6])=1;
objective(2,R1_units,[part3,part6])=1;
objective(3,R2_units,[part3,part6])=1;

accuracy=zeros(5,length(r2_acc),length(damp_acc),length(Ct),length(Cg),Tr); %record accuracy for each parameter setting
alpha =[0.2,0.5, 0.8];           %cumulation parameter of switch node
threshold= [0.2, 0.5, 0.8];      %switch threshold
%% simulation loops
for Rep=1:5                                           %5 replications
    for a=1:length(alpha)                             %3 cumulation rates
        for b=1:length(Beta)                          %2 RW learning rates
            for l= 1:length(lp)                       %4 learning rates in RL unit
                for tres=1:length(threshold)          %3 threshold values      
%% model initialization
%Processing module
Phase=zeros(nUnits,2,T,Tr); %phase neurons
Rate=zeros(nUnits,T,Tr);    %rate neurons

%weights
W=zeros(nUnits,nUnits,Tr);  
W(1:3,4:12,1)=rand(3,9);       %initial weigth strengths

%% Control module
Modules=1:3;
stm=datasample(Modules,1);

LFC=ones(4,Tr)*-1;         %LFC units
LFC(1,1)=1;
LFC(stm+1,1)=1;
Inhibition=zeros(length(Modules),Tr);

ACC=zeros(2,T,Tr);      %pMFC phase units
Be=zeros(T,Tr);         %bernoulli (rate code pMFC)

%Critic
rew=zeros(1,Tr);        %reward
V=zeros(1,Tr);          %value unit
E=zeros(3,Tr);          %value weights with responses
E(:,1)=0.5;             %initial values
negPE=zeros(1,Tr);      %negative prediction error
posPE=zeros(1,Tr);      %positive prediction error
S=zeros(1,Tr);          %Switch neuron

%% Input
%randomization of input patterns
In=repmat(1:3,6,(POT(1)));
Input=zeros(1,Tr);
Input(1,part1)=In(1,randperm(POT(1)));
Input(1,part2)=In(2,randperm(POT(1)));
Input(1,part3)=In(3,randperm(POT(1)));
Input(1,part4)=In(1,randperm(POT(1)));
Input(1,part5)=In(2,randperm(POT(1)));
Input(1,part6)=In(3,randperm(POT(1)));
%% Other
%starting points of oscillations
start=randn(nUnits,2,1,1);      %draw random starting points
start_ACC=randn(2,1,1);         %pMFC oscillations starting points
Phase(:,:,1,1)=start(:,:,1,1);  %assign to phase code units
ACC(:,1,1)=start_ACC;           %ACC = pMFC!!
r2=zeros(nUnits+1,T,Tr);        %radius

%recordings
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(3,Tr);           %response record
sync=zeros(nUnits,nUnits,Tr);   %sync matrix (correlations)
Hit=zeros(T,Tr);                %Hit/Burst record
%% the model

    for trial=1:Tr          %trial loop
    
        if trial>1          %starting points are end points of previous trials
            Phase(:,:,1,trial)=Phase(:,:,time,trial-1);
            ACC(:,1,trial)=ACC(:,time,trial-1);
        end;
        
        Z(:,trial)=Activation(:,Input(1,trial));
        
        % intertrial interval
        for t= 1:ITI
            %updating phase code units of processing module
            r2(1:nUnits,t,trial)=squeeze(dot(Phase(:,:,t,trial),Phase(:,:,t,trial),2));  %radius
            Phase(:,1,t+1,trial)=Phase(:,1,t,trial)-Cg*Phase(:,2,t,trial)-damp*(r2(1:nUnits,t,trial)>r2max).*Phase(:,1,t,trial); % excitatory cells
            Phase(:,2,t+1,trial)=Phase(:,2,t,trial)+Cg*Phase(:,1,t,trial)-damp*(r2(1:nUnits,t,trial)>r2max).*Phase(:,2,t,trial); % inhibitory cells
       
            %updating phase code units in ACC
            r2(nUnits+1,t,trial)=squeeze(dot(ACC(:,t,trial),ACC(:,t,trial),1));   %radius
            ACC(1,t+1,trial)=ACC(1,t,trial)-Ct*ACC(2,t,trial)-damp_acc*(r2(nUnits+1,t,trial)>r2_acc)*ACC(1,t,trial); % ACC exc cell
            ACC(2,t+1,trial)=ACC(2,t,trial)+Ct*ACC(1,t,trial)-damp_acc*(r2(nUnits+1,t,trial)>r2_acc)*ACC(2,t,trial); % ACC inh cell
            
            %Burst to pMFC
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

            %bernoulli process in pMFC rate
            Be(t,trial)=1/(1+exp(-acc_slope*(ACC(1,t,trial)-1)));
            prob=rand;
            
            %Burst to processing unit
            if prob<Be(t,trial)
                Hit(t,trial)=1;
                Gaussian=randn(1,2);
                for units=1:nUnits
                    lfc=ceil(units/3);
                    if abs(LFC(lfc,trial))>0 %only if there is a eligibility signal
                        Phase(units,:,t+1,trial)=decay*Phase(units,:,t,trial)+LFC(lfc,trial)*Gaussian;
                    end;
                end;
            end;
            
            %updating rate code units
            Rate(:,t+1,trial)=0;
        end;
        
        %trial period
        for time= ITI:T
            
            %updating phase code units of processing module
            r2(1:nUnits,time,trial)=squeeze(dot(Phase(:,:,time,trial),Phase(:,:,time,trial),2));  %radius
            Phase(:,1,time+1,trial)=Phase(:,1,time,trial)-Cg*Phase(:,2,time,trial)-damp*(r2(1:nUnits,time,trial)>r2max).*Phase(:,1,time,trial); % excitatory cells
            Phase(:,2,time+1,trial)=Phase(:,2,time,trial)+Cg*Phase(:,1,time,trial)-damp*(r2(1:nUnits,time,trial)>r2max).*Phase(:,2,time,trial); % inhibitory cells
       
            %updating phase code units in pMFC
            r2(nUnits+1,time,trial)=ACC(:,time,trial)'*ACC(:,time,trial);   %radius
            ACC(1,time+1,trial)=ACC(1,time,trial)-Ct*ACC(2,time,trial)-damp_acc*(r2(nUnits+1,time,trial)>r2_acc)*ACC(1,time,trial); % ACC exc cell
            ACC(2,time+1,trial)=ACC(2,time,trial)+Ct*ACC(1,time,trial)-damp_acc*(r2(nUnits+1,time,trial)>r2_acc)*ACC(2,time,trial); % ACC inh cell
            
            %bernoulli process in pMFC rate
            Be(time,trial)=1/(1+exp(-acc_slope*(ACC(1,time,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be(time,trial)
                Hit(time,trial)=1;
                Gaussian=randn(1,2);
                for units=1:nUnits
                    lfc=ceil(units/3);
                    Phase(units,:,time+1,trial)=decay*Phase(units,:,time,trial)+LFC(lfc,trial)*Gaussian;
                end;
            end;
            
            %updating rate code units
            Rate(:,time+1,trial)=max(0,(Z(:,trial)+ (squeeze(W(:,:,trial))'*Rate(:,time,trial))).*(ones(nUnits,1)./(ones(nUnits,1)+exp(-5*(squeeze(Phase(:,1,time,trial))-0.6*ones(nUnits,1))))));%processing module
            
        end;        %end of trial while loop
        
        %response determination
        maxi=squeeze(max(Rate(:,:,trial),[],2));
        [re,rid]=max(maxi(4:12,1));
        if rid==1 || rid==4 || rid==7
            response(1,trial)= 1;  
        elseif rid==2 || rid==5 || rid==8
            response(2,trial)= 1;
        elseif rid==3 || rid==6 || rid==9
            response(3,trial)= 1;    
        end;
        
        %reward value determination
        if squeeze(objective(Input(1,trial),4:6,trial))'==response(:,trial)
            rew(1,trial)=1;
        else
            rew(1,trial)=0;
        end; 
        
        V(1,trial)=E(:,trial)' * 0.5* (LFC(2:4,trial)+ones(3,1));   %value unit update
        
        negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
        posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
        E(:,trial+1)= E(:,trial) + lp(l) * V(1,trial)* 0.5 * (LFC(2:4,trial)+ones(3,1)) *(posPE(1,trial)-negPE(1,trial));   %value weight update
        
        %switch unit update
        S(1,trial+1)=alpha(a)*S(1,trial)+(1-alpha(a))*(negPE(1,trial));

        %LFC update
        if trial > 1
            Inhibition(:,trial)=Inhibition(:,trial-1)*0.9;
        end;
        
        %If switch is needed
        if S(1,trial+1)>threshold(tres)
            
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
        
        %Input has constant LFC
        LFC(1,trial+1)=LFC(1,trial);
        
        for p=1:nUnits
            for q=1:nUnits
                %sync measure (cross correlation at phase lag zero)
                sync(p,q,trial)=corr(squeeze(Phase(p,1,1:t,trial)),squeeze(Phase(q,1,1:t,trial)));
            end;  
        end;
        
        for p=1:3
            for q=4:12
                %weight updating (only for weights different than zero)
                W(p,q,trial+1)=W(p,q,trial)+Beta(1,b)*(objective(p,q,trial)-maxi(q,1))*maxi(p,1)*maxi(q,1);%
            end;
        end;

    end;
    accuracy(Rep,a,b,l,tres,:)=rew; %record accuracy
    
    %track progress
    prog = Rep * a * b * l * tres
                end; 
            end;
        end;
    end;
end;
save('RL_check','accuracy');
