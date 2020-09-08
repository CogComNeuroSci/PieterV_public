
%% Defining amount of loops
srate=500;
ITI=0.5*srate;                  %Inter Trial interval                     %Cue Target interval
Rep=25;

%% model build-up
% Processing unit
nColors=4;
nDimensions=2;
nStim=nColors*nDimensions;
nResp=nColors;
nUnits=nStim+nResp;         %model neurons
r2max=1;                    %max amplitude
Cg=(40/srate)*(2*pi);       %coupling gamma waves (sampling frequency =500)
Cg_R=(39/srate)*(2*pi);
damp=0.3;                   %damping parameter
decay=0.9;                  %decay parameter

nCongru=2;

Tr=((nColors^nDimensions-nColors)*nDimensions * length(ITI)* Rep);
T=max(ITI)+2*srate;

%Control unit
Ct=(6/srate)*(2*pi);       %coupling theta waves
damp_acc=0.05;             %damping parameter pMFC
acc_slope=10;
r2_acc=1;

%% other variables
%Input patterns
Activation=zeros(nUnits,nColors^nDimensions);
for d=1:nColors^(nDimensions-1)
    Activation(1:nColors,d*nColors-(nColors-1):nColors*d)=diag(ones(1,nColors));
    Activation(nColors+1:nUnits-nResp, d:nColors:end)=diag(ones(1,nColors));
end;

Congruent_trials=1:nColors+1:nColors^nDimensions;
Incongruent_trials=1:nColors^nDimensions;
Incongruent_trials=Incongruent_trials(~ismember(Incongruent_trials, Congruent_trials));
                    
A=zeros(nUnits,nResp); 
A(nStim+1:nUnits,:)=diag(ones(1,nResp)*0.5);

%Accumulator parameters
inh=0:0.005:0.1;
Threshold=5:5:40;
noise=0:0.05:0.5;

All_data=zeros(length(inh), length(Threshold), length(noise), Tr, 3);
Data_bis=zeros(length(inh)*length(Threshold)*length(noise)*Tr,7);

W=zeros(nUnits,nUnits);  
W(1:nColors,nStim+1:nUnits)=diag(ones(1,nColors)*0.9);
W(nColors+1:2*nColors,nStim+1:nUnits)=diag(ones(1,nColors));

sim=0;
for In=1:length(inh)
    for Thres=1:length(Threshold)
        for N=1:length(noise)

sim=sim+1;
            
inhibition=ones(nResp,nResp)*inh(In); 
for units=1:nResp
    inhibition(units,units)=0;      %diagonal of zeros
end;

%% Processing unit
Phase=zeros(nUnits,2,T,Tr); %phase neurons
Rate=zeros(nUnits,T,Tr);    %rate neurons

% Note!: The model pMFC = ACC in the code
MFC=zeros(2,T,Tr);      %pMFC phase neurons
Be=zeros(T,Tr);         %bernoulli (rate code pMFC)

%% Integrator
Integr=zeros(nResp,T,Tr); %integrator unit

%% RL unit
rew=zeros(1,Tr);        %reward
%% Input
%randomization of input pattern
Design_Congruent=(1:length(Congruent_trials))';
Design_Congruent(:,1)=Congruent_trials(Design_Congruent(:,1));
Design_Congruent=repmat([Design_Congruent, ones(size(Design_Congruent,1),1)],nColors-1,1);
Design_Incongruent=(1:length(Incongruent_trials))';
Design_Incongruent(:,1)=Incongruent_trials(Design_Incongruent(:,1));
Design_Incongruent=repmat([Design_Incongruent, zeros(size(Design_Incongruent,1),1)],1,1);

Design_all=vertcat(Design_Congruent, Design_Incongruent);

Design_all=repelem(Design_all,Tr/size(Design_all,1),1);
Design(:,1)=randperm(Tr);
Design=[Design, Design_all];
Design=sortrows(Design,1);

%% Other
%% Control unit
%choose random start module
LFC=ones(nDimensions+1,T,Tr);
LFC(2,:,:)=zeros(1,T,Tr);

%Control parameters
Gamma=0.25;
Theta=0.75;
Beta=10;
Eta=0.25;

%starting points of oscillations
start=randn(nUnits,2,1,1);      %draw random starting points
start_MFC=randn(2,1,1);         %pMFC oscillations starting points
Phase(:,:,1,1)=start(:,:,1,1);  %assign to phase code units
MFC(:,1,1)=start_MFC;
r2=zeros(nUnits+1,T,Tr);        %radius

%recordings
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(nResp,Tr);       %response record
Hit=zeros(T,Tr);                    %Hit record
Congruency=zeros(1,Tr);
RT=ones(1,Tr)*2000;
Control=ones(1,Tr);
Energy=zeros(T,Tr);
MAE=zeros(1,Tr);

RD=2*srate;        %Response deadline
%% the model
for trial=1:Tr          %trial loop
    
    if trial>1          %starting points are end points of previous trials
        Phase(:,:,1,trial)=randn(nUnits,2,1,1);
        MFC(:,1,trial)=randn(2,1,1);
        r2_acc=Control(1,trial);
    end;
        
    Z(:,trial)=Activation(:,Design(trial,2));
    
    for time = 1: ITI+RD    
        
        %updating phase code neurons of processing unit
        r2(1:nUnits,time,trial)=squeeze(dot(Phase(:,:,time,trial),Phase(:,:,time,trial),2));  %radius
        Phase(1:nStim,1,time+1,trial)=Phase(1:nStim,1,time,trial)-Cg*Phase(1:nStim,2,time,trial)-damp*(r2(1:nStim,time,trial)>r2max).*Phase(1:nStim,1,time,trial); % excitatory cells
        Phase(1:nStim,2,time+1,trial)=Phase(1:nStim,2,time,trial)+Cg*Phase(1:nStim,1,time,trial)-damp*(r2(1:nStim,time,trial)>r2max).*Phase(1:nStim,2,time,trial); % inhibitory cells
        
        Phase(nStim+1:nUnits,1,time+1,trial)=Phase(nStim+1:nUnits,1,time,trial)-Cg_R*Phase(nStim+1:nUnits,2,time,trial)-damp*(r2(nStim+1:nUnits,time,trial)>r2max).*Phase(nStim+1:nUnits,1,time,trial); % excitatory cells
        Phase(nStim+1:nUnits,2,time+1,trial)=Phase(nStim+1:nUnits,2,time,trial)+Cg_R*Phase(nStim+1:nUnits,1,time,trial)-damp*(r2(nStim+1:nUnits,time,trial)>r2max).*Phase(nStim+1:nUnits,2,time,trial); % inhibitory cells
        
        %updating phase code units in pMFC
        r2(nUnits+1,time,trial)=MFC(:,time,trial)'*MFC(:,time,trial);   %radius
        MFC(1,time+1,trial)=MFC(1,time,trial)-Ct*MFC(2,time,trial)-damp_acc*((r2(nUnits+1,time,trial)>r2_acc)*2-1)*MFC(1,time,trial); % ACC exc cell
        MFC(2,time+1,trial)=MFC(2,time,trial)+Ct*MFC(1,time,trial)-damp_acc*((r2(nUnits+1,time,trial)>r2_acc)*2-1)*MFC(2,time,trial); % ACC inh cell

        %bernoulli process in pMFC rate
        Be(time,trial)=1/(1+exp(-acc_slope*(MFC(1,time,trial)-0.8)));
        prob=rand;
        
        if prob<Be(time,trial)
            Gaussian=randn(1,2);
            for d=1:nDimensions+1
                if abs(LFC(d,time,trial))>0
                    Phase((d-1)*nColors+1:d*nColors,:,time+1,trial)=decay*Phase((d-1)*nColors+1:d*nColors,:,time,trial)+(LFC(d,time,trial)*Gaussian);
                    Hit(time,trial)=1;
                end;
            end;
        end;
        
        if time>ITI && sum(response(:,trial)) == 0
            %updating rate code neurons
            Rate(:,time+1,trial)=max(0,(Z(:,trial)+ (squeeze(W(:,:))'*Rate(:,time,trial))+ noise(N)*randn(nUnits,1)).*(ones(nUnits,1)./(ones(nUnits,1)+exp(-5*(squeeze(Phase(:,1,time,trial))-0.6*ones(nUnits,1))))));%processing unit
            Integr(:,time+1,trial)= max(0,(Integr(:,time,trial) + (A' * Rate(:,time,trial))- (inhibition*Integr(:,time,trial)))+noise(N)*randn(nResp,1));  %integrator module
        else
            Rate(:,time+1,trial)=0;
            Integr(:,time+1,trial)=0;
        end;
        
        cum_E=(squeeze(Integr(:,time,trial))./Threshold(Thres))*(squeeze(Integr(:,time,trial))'./Threshold(Thres));
        cum_E(1:5:end)=0;
        Energy(time,trial)=sum(sum(cum_E));
        r2_acc=Control(1,trial)+Beta*Energy(time,trial);
        
        if r2_acc>Theta
            LFC(2,time:end,trial)=0;
        end;
        
        response(:,trial)=double(Integr(:,time,trial)>Threshold(Thres));
        
        if sum(response(:,trial)) > 0 && RT(1,trial)==2000
            RT(1,trial)=(time-ITI)*(1000/srate);
        end;
        
    end;       
        
    MAE(1,trial)=max(Energy(1:time,trial));
    
    if sum(response(:,trial))~=1
        response(:,trial)=zeros(nResp,1);
        [M,I]=max(squeeze(Integr(:,time,trial)));
        response(I,trial)=1;
    end;
    
    if Z(1:nColors,trial)==response(:,trial)
        rew(1,trial)=1;
    else
        rew(1,trial)=0;
    end;
    
    Control(1,trial+1)=Gamma*Control(1,trial)+(1-Gamma)*(Beta*MAE(1,trial)+Eta);
    
    LFC(2,:,trial+1)=Control(1,trial+1)<Theta;
    
end;
    
Data=Design;
All_data(In, Thres, N, :,1)=rew';
All_data(In, Thres, N, :,2)=RT';
All_data(In, Thres, N, :,3)=Design(:,3);

Data_bis((sim-1)*Tr+1:sim*Tr,1)=sim;
Data_bis((sim-1)*Tr+1:sim*Tr,2)=inh(In);
Data_bis((sim-1)*Tr+1:sim*Tr,3)=Threshold(Thres);
Data_bis((sim-1)*Tr+1:sim*Tr,4)=noise(N);
Data_bis((sim-1)*Tr+1:sim*Tr,5)=rew';
Data_bis((sim-1)*Tr+1:sim*Tr,6)=RT';
Data_bis((sim-1)*Tr+1:sim*Tr,7)=Design(:,3);
        end;
    end;
end;

save('Accumulator_pars_tres', 'All_data')

fid = fopen('Data_accumulator_pars_tres.txt','wt');
for i = 1:size(Data_bis,1)
    fprintf(fid,'%g\t',Data_bis(i,:));
    fprintf(fid,'\n');
end
fclose(fid)