
%% Defining simulation parameters

Rep=27;                 %amount of replications
T=250;                  %trialtime
Tr=480;                 % amount of trials
Beta=0.8;
ITI=750;                %intertrial interval
mean_switch=30;
std_switch=15;
Nparts=Tr/mean_switch;
Nreversals=Nparts-1;

%% model build-up
% Processing module
nUnits=6;                   %model units
r2max=1;                    %max amplitude
Cg=6*(2*pi)/500;            %coupling gamma waves (sampling frequency =500)
Cg_R=6*(2*pi)/500;

damp=0.3;                   %damping parameter
decay=0.9;                  %decay parameter

%Control module
r2_acc=0.5;                 %radius ACC
Ct=6*(2*pi)/500;            %coupling theta waves
damp_acc=0.01;              %damping parameter ACC
acc_slope=10;               %slope of ACC burst function

%Critic
lp=0.1;
cumul=0.3;
%% other variables
%Input patterns
Activation=zeros(nUnits,2);
Activation(1,1)=1;
Activation(2,2)=1;

%% Learning objectives
R1_units=[3,5];
R2_units=[4,6];

%% simulation loops
for r=1:Rep            %replication loop
    
%define points of task rule switches at random
Ntrial_rule1=0;
Ntrial_rule2=0;
Points=zeros(1,Nparts);
POT=zeros(1,Nparts);

while (Ntrial_rule1 ~= Ntrial_rule2) || (Points(Nparts)<mean_switch-std_switch) || (Points(Nparts)>mean_switch+std_switch)
    for reversals=1:Nreversals
        Points(reversals)=round(mean_switch.*rand(1,1)+std_switch);
        if reversals==1
            POT(reversals)=Points(reversals);    
        else
            POT(reversals)=POT(reversals-1)+Points(reversals);
        end;
    POT(Nreversals+1)=Tr;
    Points(Nparts)=Tr-sum(Points(1:Nreversals));
    Ntrial_rule1=sum(Points(1:2:Nparts));
    Ntrial_rule2=sum(Points(2:2:Nparts));
    end;
end;

part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);            %third part
part4=POT(3)+1:POT(4);            %...
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);
part7=POT(6)+1:POT(7);            
part8=POT(7)+1:POT(8);           
part9=POT(8)+1:POT(9);
part10=POT(9)+1:POT(10);
part11=POT(10)+1:POT(11);
part12=POT(11)+1:POT(12);            
part13=POT(12)+1:POT(13);             
part14=POT(13)+1:POT(14);
part15=POT(14)+1:POT(15);
part16=POT(15)+1:POT(16);

rule_1=[part1, part3, part5, part7, part9, part11, part13, part15];
rule_2=[part2, part4, part6, part8, part10, part12, part14, part16];   


%Learning objectives based on rules
objective=zeros(nUnits,nUnits,Tr);

objective(1,R1_units,rule_1)=0.8;
objective(2,R2_units,rule_1)=0.8;
objective(1,R2_units,rule_1)=0.2;
objective(2,R1_units,rule_1)=0.2;

objective(1,R2_units,rule_2)=0.8;
objective(2,R1_units,rule_2)=0.8;
objective(1,R1_units,rule_2)=0.2;
objective(2,R2_units,rule_2)=0.2;

%% model initialization
%Processing module
Phase=zeros(nUnits,2,T+ITI,Tr); %phase neurons
Rate=zeros(nUnits,T+ITI,Tr);    %rate neurons

%weights
W=zeros(nUnits,nUnits,Tr);  
W(1:2,3:6,1)=rand(2,4);       %initial weigth strengths

%% Control module
Modules=2:3;
stm=datasample(Modules,1);

LFC=zeros(3,Tr);        %LFC units
LFC(1,1)=1;
LFC(stm,1)=1;

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
In=repmat(1:2,1,Tr/2);
Input=In(1,randperm(Tr));

%% Other
%starting points of oscillations
start=randn(nUnits,2,1,1);      %draw random starting points
start_ACC=randn(2,1,1);         %acc oscillations starting points
Phase(:,:,1,1)=start(:,:,1,1);  %assign to phase code units
ACC(:,1,1)=start_ACC;
r2=zeros(nUnits+1,T+ITI,Tr);        %radius

%recordings
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(2,Tr);           %response record
sync=zeros(nUnits,nUnits,Tr);   %sync matrix (correlations)
Hit=zeros(T+ITI,Tr);            %Hit record
accuracy=zeros(1,Tr);
X=0;
Switch_made=zeros(1,Tr);
cond=zeros(1,Tr);

%% the model

    for trial=1:Tr          %trial loop
    
        if trial>1          %starting points are end points of previous trials + random phase shift
            Phase(:,:,1,trial)=Phase(:,:,t,trial-1);
            ACC(:,1,trial)=ACC(:,t,trial-1);
        end;
        
        Z(:,trial)=Activation(:,Input(1,trial));
        
        for time= 1:T
            
            %updating phase code units of processing module
            r2(1:nUnits,time,trial)=squeeze(dot(Phase(:,:,time,trial),Phase(:,:,time,trial),2));  %radius
            %stimulus neurons
            Phase(1:2,1,time+1,trial)=Phase(1:2,1,time,trial)-Cg*Phase(1:2,2,time,trial)-damp*(r2(1:2,time,trial)>r2max).*Phase(1:2,1,time,trial); % excitatory cells
            Phase(1:2,2,time+1,trial)=Phase(1:2,2,time,trial)+Cg*Phase(1:2,1,time,trial)-damp*(r2(1:2,time,trial)>r2max).*Phase(1:2,2,time,trial); % inhibitory cells
            %response neurons
            Phase(3:nUnits,1,time+1,trial)=Phase(3:nUnits,1,time,trial)-Cg_R*Phase(3:nUnits,2,time,trial)-damp*(r2(3:nUnits,time,trial)>r2max).*Phase(3:nUnits,1,time,trial); % excitatory cells
            Phase(3:nUnits,2,time+1,trial)=Phase(3:nUnits,2,time,trial)+Cg_R*Phase(3:nUnits,1,time,trial)-damp*(r2(3:nUnits,time,trial)>r2max).*Phase(3:nUnits,2,time,trial); % inhibitory cells
            
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
                Gaussian=(randn(1,2)*0.5)+1;
                for units=1:nUnits
                    lfc=ceil(units/2);
                    if abs(LFC(lfc,trial))>0 %only if there is a eligibility signal
                        Phase(units,:,time+1,trial)=decay*Phase(units,:,time,trial)+LFC(lfc,trial)*Gaussian;
                    end;
                end;
            end;
            
            %updating rate code units
            Rate(:,time+1,trial)=max(0,(Z(:,trial)+ (squeeze(W(:,:,trial))'*Rate(:,time,trial))).*(ones(6,1)./(ones(6,1)+exp(-5*(squeeze(Phase(:,1,time,trial))-0.6*ones(6,1))))));%processing module
            
        end;        %end of trial while loop
        
        %response determination
        maxi=squeeze(max(Rate(:,:,trial),[],2));
        [re,rid]=max(maxi(3:6,1));
        if rid==1 || rid==3
            response(1,trial)= 0.8;
            response(2,trial)= 0.2;    
        else
            response(1,trial)= 0.2;
            response(2,trial)= 0.8;
        end;
        
        %reward value determination
        if squeeze(objective(Input(1,trial),3:4,trial))'==response(:,trial)
            accuracy(1,trial)=1;
        else
            accuracy(1,trial)=0;
        end; 
        
        Reward_prob=rand;
        if (accuracy(1,trial)==1) && (Reward_prob<=0.8)
            rew(1,trial)=1;
            cond(1,trial)=3;
        elseif (accuracy(1,trial)==0) && (Reward_prob>=0.8)
            rew(1,trial)=1;
            cond(1,trial)=4;
        else
            cond(1,trial)=(accuracy(1,trial)*-1)+2;
            rew(1,trial)=0;
        end;
        
        V(1,trial)=E(:,trial)' * 0.5* (LFC(2:3,trial)+ones(2,1));   %value unit update
        
        negPE(1,trial)= max(0,V(1,trial)- rew(1,trial));      %negative PE value
        posPE(1,trial)= max(0,rew(1,trial)-V(1,trial));       %positive PE value
        
        E(:,trial+1)= E(:,trial) + lp * V(1,trial)* 0.5 * (LFC(2:3,trial)+ones(2,1)) *(posPE(1,trial)-negPE(1,trial));   %value weight update
        
        %switch unit update
        S(1,trial+1)=cumul*S(1,trial)+(1-cumul)*(negPE(1,trial));

        %LFC update
        if S(1,trial+1)>0.5
            X=X+1;
            Switch_made(1,X)=trial;
            LFC(3,trial+1)=-LFC(3,trial);
            LFC(2,trial+1)=-LFC(2,trial);
            LFC(3,trial+1)=(LFC(3,trial)-1)*-1;
            LFC(2,trial+1)=(LFC(2,trial)-1)*-1;
        else
            LFC(3,trial+1)=LFC(3,trial);
            LFC(2,trial+1)=LFC(2,trial);
        end;
        
        LFC(1,trial+1)=LFC(1,trial);
        
        % intertrial interval
        for t= T:T+ITI
            %updating phase code units of processing module
            r2(1:nUnits,t,trial)=squeeze(dot(Phase(:,:,t,trial),Phase(:,:,t,trial),2));  %radius
            Phase(1:2,1,t+1,trial)=Phase(1:2,1,t,trial)-Cg*Phase(1:2,2,t,trial)-damp*(r2(1:2,t,trial)>r2max).*Phase(1:2,1,t,trial); % excitatory cells
            Phase(1:2,2,t+1,trial)=Phase(1:2,2,t,trial)+Cg*Phase(1:2,1,t,trial)-damp*(r2(1:2,t,trial)>r2max).*Phase(1:2,2,t,trial); % inhibitory cells
            
            Phase(3:nUnits,1,t+1,trial)=Phase(3:nUnits,1,t,trial)-Cg_R*Phase(3:nUnits,2,t,trial)-damp*(r2(3:nUnits,t,trial)>r2max).*Phase(3:nUnits,1,t,trial); % excitatory cells
            Phase(3:nUnits,2,t+1,trial)=Phase(3:nUnits,2,t,trial)+Cg_R*Phase(3:nUnits,1,t,trial)-damp*(r2(3:nUnits,t,trial)>r2max).*Phase(3:nUnits,2,t,trial); % inhibitory cells
            
            %updating phase code units in ACC
            r2(nUnits+1,t,trial)=squeeze(dot(ACC(:,t,trial),ACC(:,t,trial),1));   %radius
            ACC(1,t+1,trial)=ACC(1,t,trial)-Ct*ACC(2,t,trial)-damp_acc*(r2(nUnits+1,t,trial)>r2_acc)*ACC(1,t,trial); % ACC exc cell
            ACC(2,t+1,trial)=ACC(2,t,trial)+Ct*ACC(1,t,trial)-damp_acc*(r2(nUnits+1,t,trial)>r2_acc)*ACC(2,t,trial); % ACC inh cell
            
            if negPE(1,trial)>0
                Be_ACC=gaussmf(t,[5,T+125]);
                prob_ACC=rand;
                if prob_ACC< Be_ACC
                    Gaussian_ACC=(randn(2,1)*0.5)+1;
                    ACC(:,t+1,trial)=decay*ACC(:,t,trial)+negPE(1,trial)*Gaussian_ACC;
                end;
            end;

            %bernoulli process in ACC rate
            Be(t,trial)=1/(1+exp(-acc_slope*(ACC(1,t,trial)-1)));
            prob=rand;
            
            %burst
            if prob<Be(t,trial)
                Hit(t,trial)=1;
                Gaussian=(randn(1,2)*0.5)+1;
                for units=1:nUnits
                    lfc=ceil(units/2);
                    if abs(LFC(lfc,trial))>0 %only if there is a eligibility signal
                        Phase(units,:,t+1,trial)=decay*Phase(units,:,t,trial)+LFC(lfc,trial+1)*Gaussian;
                    end;
                end;
            end;
            
            %updating rate code units
            Rate(:,t+1,trial)=0;
        end;
        
        for p=1:2
            for q=3:6
                %weight updating (only for weights different than zero)
                W(p,q,trial+1)=W(p,q,trial)+Beta*(objective(p,q,trial)-maxi(q,1))*maxi(p,1)*maxi(q,1);%
            end;
        end;
        %print progress
        prog=trial
    end;
    
    % Make behavioral data file
    B_dat=zeros(Tr,11);
    B_dat(:,1)=0:Tr-1;
    B_dat(part1,[2,4])=[0*ones(1,length(part1)); 0:length(part1)-1]';
    B_dat(part2,[2,4])=[1*ones(1,length(part2)); 0:length(part2)-1]';
    B_dat(part3,[2,4])=[2*ones(1,length(part3)); 0:length(part3)-1]';
    B_dat(part4,[2,4])=[3*ones(1,length(part4)); 0:length(part4)-1]';
    B_dat(part5,[2,4])=[4*ones(1,length(part5)); 0:length(part5)-1]';
    B_dat(part6,[2,4])=[5*ones(1,length(part6)); 0:length(part6)-1]';
    B_dat(part7,[2,4])=[6*ones(1,length(part7)); 0:length(part7)-1]';
    B_dat(part8,[2,4])=[7*ones(1,length(part8)); 0:length(part8)-1]';
    B_dat(part9,[2,4])=[8*ones(1,length(part9)); 0:length(part9)-1]';
    B_dat(part10,[2,4])=[9*ones(1,length(part10)); 0:length(part10)-1]';
    B_dat(part11,[2,4])=[10*ones(1,length(part11)); 0:length(part11)-1]';
    B_dat(part12,[2,4])=[11*ones(1,length(part12)); 0:length(part12)-1]';
    B_dat(part13,[2,4])=[12*ones(1,length(part13)); 0:length(part13)-1]';
    B_dat(part14,[2,4])=[13*ones(1,length(part14)); 0:length(part14)-1]';
    B_dat(part15,[2,4])=[14*ones(1,length(part15)); 0:length(part15)-1]';
    B_dat(part16,[2,4])=[15*ones(1,length(part16)); 0:length(part16)-1]';
    B_dat(rule_1,3)=0;
    B_dat(rule_2,3)=1;
    B_dat(:,5)=Input-1;
    [a,Resp]=max(response,[],1);
    B_dat(:,6)=Resp-1;
    B_dat(:,7)=accuracy;
    B_dat(:,8)=rew;
    B_dat(Switch_made(Switch_made>0),9)=1;
    B_dat(:,10)=cond;
    prediction_error=posPE-negPE;
    B_dat(:,11)=prediction_error;
    
    %Make EEG data file
    EEG_dat_stim=squeeze(Phase(1:2,1,:,:));
    EEG_dat_resp=squeeze(Phase(3:nUnits,1,:,:));
    EEG_dat_MFC=squeeze(ACC(1,:,:));
    save(['Tasksim_',num2str(r)], 'B_dat', 'EEG_dat_stim', 'EEG_dat_resp', 'EEG_dat_MFC'); %write data to file 
    fprintf(['\n ********\n done with simulation ' num2str(r) '\n mean accuracy was ' num2str(mean(accuracy)*100) ' \n ********\n'])
end; 

%clear all
