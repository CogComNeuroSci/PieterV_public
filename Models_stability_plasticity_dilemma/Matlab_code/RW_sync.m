
%% Defining amount of loops
Rep=10;                 %amount of replications
T=500;                  %trialtime
Tr=240;                 % amount of trials
betas=11;               %beta iterations
Beta=0:1/(betas-1):1;   %learning rate values
ITI=250;                %intertrial interval

POT_1=Tr/3;                 %point of switch to task rule 2 (trial 20)
POT_2=2*Tr/3;               %switch again to task rule 1    (trial 40)
part1=1:POT_1;              %first part
part2=POT_1+1:POT_2;        %second part
part3=POT_2+1:Tr;           %third part
%% model build-up
% Processing module
nUnits=6;                   %model units
r2max=1;                    %max amplitude
Cg=0.58;                    %coupling gamma waves (sampling frequency =500)
damp=0.3;                   %damping parameter
decay=0.9;                  %decay parameter

%Control module

r2_acc=0.05;       %radius ACC
Ct=0.07;        %coupling theta waves
damp_acc=0.003;  %damping parameter ACC
acc_slope=10;   %acc_slope

%Critic
lp=0.2;                 %learning rate critic
%% other variables
%Input patterns
Activation=zeros(nUnits,2);
Activation(:,1)=[1,0,0,0,0,0];
Activation(:,2)=[0,1,0,0,0,0];

%% Learning objectives
objective=zeros(nUnits,nUnits,Tr); 
objective(1,3,part1)=1;
objective(2,4,part1)= objective(1,3,part1);
objective(2,3,part2)=1;     
objective(1,4,part2)=objective(2,3,part2);
objective(1,3,part3)=1;  
objective(2,4,part3)=objective(1,3,part3); 
objective(1,5:6,:)=objective(1,3:4,:);
objective(2,5:6,:)=objective(2,3:4,:);

%% simulation loops
for b=11:11%betas
    for r=1:1%Rep            %replication loop
%% model initialization
%Processing module
Phase=zeros(nUnits,2,T,Tr); %phase neurons
Rate=zeros(nUnits,T,Tr);    %rate neurons

%weights
W=zeros(nUnits,nUnits,Tr);  
W(1:2,3:6,1)=rand(2,4);       %initial weigth strengths

%% Control module
LFC=zeros(3,Tr);         %LFC units
LFC(1,1)=1;
if rand>0.5
    LFC(3,1)=-1;
    LFC(2,1)=1;
else
    LFC(3,1)=1;
    LFC(2,1)=-1;
end;

ACC=zeros(2,T,Tr);      %ACC phase units
Be=zeros(T,Tr);         %bernoulli (rate code ACC)

%Critic
rew=zeros(1,Tr);        %reward
V=zeros(1,Tr);          %value unit
E=zeros(2,Tr);          %value weights with Integrator
E(:,1)=0.5;             %initial values
negPE=zeros(1,Tr);      %negative prediction error
posPE=zeros(1,Tr);      %positive prediction error
S=zeros(1,Tr);          %Switch neuron

%% Input
%randomization of input patterns
In=repmat(1:2,3,(POT_1));
Input=zeros(1,Tr);
Input(1,part1)=In(1,randperm(POT_1));
Input(1,part2)=In(2,randperm(POT_1));
Input(1,part3)=In(3,randperm(POT_1));

%% Other
%starting points of oscillations
start=randn(nUnits,2,1,1);      %draw random starting points
start_ACC=randn(2,1,1);         %acc oscillations starting points
Phase(:,:,1,1)=start(:,:,1,1);  %assign to phase code units
ACC(:,1,1)=start_ACC;
r2=zeros(nUnits+1,T,Tr);        %radius

%recordings
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(2,Tr);    %response record
sync=zeros(nUnits,nUnits,Tr);   %sync matrix (correlations)
Hit=zeros(T,Tr);                %Hit record
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
                Hit(t,trial)=1;
                Gaussian=randn(1,2);
                for units=1:nUnits
                    lfc=ceil(units/2);
                    if abs(LFC(lfc,trial))>0 %only if there is a eligibility signal
                        Phase(units,:,t+1,trial)=decay*Phase(units,:,t,trial)+LFC(lfc,trial)*Gaussian;
                    end;
                end;
            end;
            
            %updating rate code units
            Rate(:,t+1,trial)=0;
        end;
        
        
        for time= ITI:T
            
            %updating phase code units of processing module
            r2(1:nUnits,time,trial)=squeeze(dot(Phase(:,:,time,trial),Phase(:,:,time,trial),2));  %radius
            Phase(:,1,time+1,trial)=Phase(:,1,time,trial)-Cg*Phase(:,2,time,trial)-damp*(r2(1:nUnits,time,trial)>r2max).*Phase(:,1,time,trial); % excitatory cells
            Phase(:,2,time+1,trial)=Phase(:,2,time,trial)+Cg*Phase(:,1,time,trial)-damp*(r2(1:nUnits,time,trial)>r2max).*Phase(:,2,time,trial); % inhibitory cells
       
            %updating phase code units in ACC
            r2(nUnits+1,time,trial)=ACC(:,time,trial)'*ACC(:,time,trial);   %radius
            ACC(1,time+1,trial)=ACC(1,time,trial)-Ct*ACC(2,time,trial)-damp_acc*(r2(nUnits+1,time,trial)>r2_acc)*ACC(1,time,trial); % ACC exc cell
            ACC(2,time+1,trial)=ACC(2,time,trial)+Ct*ACC(1,time,trial)-damp_acc*(r2(nUnits+1,time,trial)>r2_acc)*ACC(2,time,trial); % ACC inh cell
            
            %bernoulli process in ACC rate
            Be(time,trial)=1/(1+exp(-acc_slope*(ACC(1,time,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be(time,trial)
                Hit(time,trial)=1;
                Gaussian=randn(1,2);
                for units=1:nUnits
                    lfc=ceil(units/2);
                    Phase(units,:,time+1,trial)=decay*Phase(units,:,time,trial)+LFC(lfc,trial)*Gaussian;
                end;
            end;
            
            %updating rate code units
            Rate(:,time+1,trial)=max(0,(Z(:,trial)+ (squeeze(W(:,:,trial))'*Rate(:,time,trial))).*(ones(6,1)./(ones(6,1)+exp(-5*(squeeze(Phase(:,1,time,trial))-0.6*ones(6,1))))));%processing module
            
        end;        %end of trial while loop
        
        %response determination
        maxi=squeeze(max(Rate(:,:,trial),[],2));
        [re,rid]=max(maxi(3:6,1));
        if rid==1 || rid==3
            response(1,trial)= 1;
            response(2,trial)= 0;    
        else
            response(1,trial)= 0;
            response(2,trial)= 1;
        end;
        
        %reward value determination
        if squeeze(objective(Input(1,trial),3:4,trial))'==response(:,trial)
            rew(1,trial)=1;
        else
            rew(1,trial)=0;
        end; 
        
        V(1,trial)=E(:,trial)' * 0.5* (LFC(2:3,trial)+ones(2,1));   %value unit update
        
        negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
        posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
        E(:,trial+1)= E(:,trial) + lp * V(1,trial)* 0.5 * (LFC(2:3,trial)+ones(2,1)) *(posPE(1,trial)-negPE(1,trial));   %value weight update
        
        %switch unit update
        S(1,trial+1)=0.5*S(1,trial)+0.5*(negPE(1,trial));

        %LFC update
        if S(1,trial+1)>0.5
            LFC(3,trial+1)=-LFC(3,trial);
            LFC(2,trial+1)=-LFC(2,trial);
            S(1,trial+1)=0;
        else
            LFC(3,trial+1)=LFC(3,trial);
            LFC(2,trial+1)=LFC(2,trial);
        end;
        
        LFC(1,trial+1)=LFC(1,trial);
        
        for p=1:nUnits
            for q=1:nUnits
                %sync measure (cross correlation at phase lag zero)
                sync(p,q,trial)=corr(squeeze(Phase(p,1,1:t,trial)),squeeze(Phase(q,1,1:t,trial)));
            end;  
        end;
        
        for p=1:2
            for q=3:6
                %weight updating (only for weights different than zero)
                W(p,q,trial+1)=W(p,q,trial)+Beta(1,b)*(objective(p,q,trial)-maxi(q,1))*maxi(p,1)*maxi(q,1);%
            end;
        end;
        prog=trial
    end;
    
    save(['Beta',num2str(b),'Rep',num2str(r),'_RWsync']); %write data to file with beta iteration, epsilon iteration and replication as name
    end; 
end;
