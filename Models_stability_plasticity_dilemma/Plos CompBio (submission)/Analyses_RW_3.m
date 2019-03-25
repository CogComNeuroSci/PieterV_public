%{
    Script for the analyses of the RW model on the three-dimensional task
%}

%% Define variables

% Amounts of everything
betas=11;
Rep=10;
Tr=360;
nUnits=6;
syncUnits=12;

%Initialize all data matrices

Accuracy_conn=zeros(Tr,betas,Rep); %accuracy variable
Weights_conn=zeros(nUnits,nUnits,Tr+1,betas,Rep);

Accuracy_sync=zeros(Tr,betas,Rep); %accuracy variable
Weights_sync=zeros(syncUnits,syncUnits,Tr+1,betas,Rep);

Gamma=zeros(syncUnits,2,500,Tr,betas,Rep);        %gamma waves for pac measure (4000 is just approximation of timesteps until response)
Theta=zeros(2,500,Tr,betas,Rep);          %theta waves for pac measure
Synchronization=zeros(syncUnits,syncUnits,Tr,betas,Rep);   %synchronization
module=zeros(2,betas,Rep);
Switcher=zeros(Tr+1,betas,Rep);

%% load data and store in data matrices

%extract accuracy data from workspaces for synaptic model
for b=1:betas
        for r=1:Rep
            load(['Beta',num2str(b),'Rep',num2str(r),'_RWonly'],'rew','W');
            Accuracy_conn(:,b,r)=squeeze(rew);
            Weights_conn(:,:,:,b,r)=W;
        end;
end;

%Full model
for b=1:betas
        for r=1:Rep
            load(['Beta',num2str(b),'Rep',num2str(r),'_RWsync'],'Phase','ACC','sync','rew','W','S','LFC');
            Gamma(:,:,:,:,b,r)=Phase(:,:,1:500,:);        %extract gamma
            Theta(:,:,:,b,r)=ACC(:,1:500,:);              %extract theta
            Synchronization(:,:,:,b,r)=sync;      %extract synchronization
            Accuracy_sync(:,b,r)=squeeze(rew);
            Weights_sync(:,:,:,b,r)=W;
            Switcher(:,b,r)=squeeze(S);

            % derive which module was used first, second and third
            if LFC(2,1)==1
                module(1,b,r)=1;
            elseif LFC(3,1)==1
                module(1,b,r)=2;
            else
               module(1,b,r)=3; 
            end;
            if LFC(2,80)==1
                module(2,b,r)=1;
            elseif LFC(3,80)==1
                module(2,b,r)=2;
            else
               module(2,b,r)=3; 
            end;
        end;
end;

%% General performance of the synaptic model

%compute binned accuracy: divide 360 trials in 120 bins
binned_accuracy_conn=zeros(120,betas,Rep);
bin_edges=(1:Tr/120:Tr+1)-1;
for i =1:length(bin_edges)-1
    binned_accuracy_conn(i,:,:)=mean(Accuracy_conn(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

%compute means and confidence intervals (accuracy)
mean_accuracy_conn=squeeze(mean(Accuracy_conn,3))*100; %over replications
std_accuracy_conn=squeeze(std(Accuracy_conn.*100,0,3));
CI_accuracy_conn=2*(std_accuracy_conn./sqrt(Rep));

mean_ACC_conn=squeeze(mean(mean_accuracy_conn,1)); %over trials
CI_ACC_conn=(2*squeeze(std(mean(Accuracy_conn,1),0,3))./sqrt(Rep)).*100;

%% General performance of the full model

%compute binned accuracy: divide 360 trials in 120 bins
binned_accuracy_sync=zeros(120,betas,Rep);
for i =1:length(bin_edges)-1
    binned_accuracy_sync(i,:,:)=mean(Accuracy_sync(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

%compute means and confidence intervals (accuracy)
mean_accuracy_sync=squeeze(mean(Accuracy_sync,3))*100; %over replications
std_accuracy_sync=squeeze(std(Accuracy_sync.*100,0,3));
CI_accuracy_sync=2*(std_accuracy_sync./sqrt(Rep));

mean_ACC_sync=squeeze(mean(mean_accuracy_sync,1)); %over trials
CI_ACC_sync=(2*squeeze(std(mean(Accuracy_sync,1),0,3))./sqrt(Rep)).*100;

%% Compute stability and plasticity for both models

%determine critical moments to compute stability and plasticity values (in trial bins)
stability_R1_1=15:20;
stability_R1_2=61:65;
stability_R2_1=35:40;
stability_R2_2=81:85;
stability_R3_1=55:60;
stability_R3_2=101:105;
plasticity_1=1:5;
plasticity_2=21:25;
plasticity_3=41:60;

% The synaptic model
Stability_conn(1,:,:)=mean(binned_accuracy_conn(stability_R1_2,:,:),1)-mean(binned_accuracy_conn(stability_R1_1,:,:),1);
Stability_conn(2,:,:)=mean(binned_accuracy_conn(stability_R2_2,:,:),1)-mean(binned_accuracy_conn(stability_R2_1,:,:),1);
Stability_conn(3,:,:)=mean(binned_accuracy_conn(stability_R3_2,:,:),1)-mean(binned_accuracy_conn(stability_R3_1,:,:),1);

Plasticity_conn(1,:,:)=mean(binned_accuracy_conn(plasticity_1,:,:),1);
Plasticity_conn(2,:,:)=mean(binned_accuracy_conn(plasticity_2,:,:),1);
Plasticity_conn(3,:,:)=mean(binned_accuracy_conn(plasticity_3,:,:),1);

Stability_sync(1,:,:)=mean(binned_accuracy_sync(stability_R1_2,:,:),1)-mean(binned_accuracy_sync(stability_R1_1,:,:),1);
Stability_sync(2,:,:)=mean(binned_accuracy_sync(stability_R2_2,:,:),1)-mean(binned_accuracy_sync(stability_R2_1,:,:),1);
Stability_sync(3,:,:)=mean(binned_accuracy_sync(stability_R3_2,:,:),1)-mean(binned_accuracy_sync(stability_R3_1,:,:),1);

Plasticity_sync(1,:,:)=mean(binned_accuracy_sync(plasticity_1,:,:),1);
Plasticity_sync(2,:,:)=mean(binned_accuracy_sync(plasticity_2,:,:),1);
Plasticity_sync(3,:,:)=mean(binned_accuracy_sync(plasticity_3,:,:),1);

% Average and confidence intervals
mean_plas_sync=mean(Plasticity_sync,3)*100;
std_plas_sync=std(Plasticity_sync,0,3);
CI_plas_sync=2*std_plas_sync./sqrt(Rep)*100;
mean_stab_sync=mean(Stability_sync,3)*100;
std_stab_sync=std(Stability_sync,0,3);
CI_stab_sync=2*std_stab_sync./sqrt(Rep)*100;

mean_plas_conn=mean(Plasticity_conn,3)*100;
std_plas_conn=std(Plasticity_conn,0,3);
CI_plas_conn=2*std_plas_conn./sqrt(Rep)*100;
mean_stab_conn=mean(Stability_conn,3)*100;
std_stab_conn=std(Stability_conn,0,3);
CI_stab_conn=2*std_stab_conn./sqrt(Rep)*100;

Plas_sync_for_paper(1,:)=mean(mean_plas_sync(2:3,:),1);
Plas_sync_for_paper(2,:)=mean(CI_plas_sync(2:3,:),1);
Stab_sync_for_paper(1,:)=mean(mean_stab_sync,1);
Stab_sync_for_paper(2,:)=mean(CI_stab_sync,1);

Plas_conn_for_paper(1,:)=mean(mean_plas_conn(2:3,:),1);
Plas_conn_for_paper(2,:)=mean(CI_plas_conn(2:3,:),1);
Stab_conn_for_paper(1,:)=mean(mean_stab_conn,1);
Stab_conn_for_paper(2,:)=mean(CI_stab_conn,1);

%% Synchronization of task modules

%compute means     
sync_rule1=zeros(3,3,Tr,betas,Rep);
sync_rule2=zeros(3,3,Tr,betas,Rep);
sync_rule3=zeros(3,3,Tr,betas,Rep);

% for exploration purposes we also checked the weight change
weights_rule1_sync=zeros(3,3,Tr+1,betas,Rep);
weights_rule2_sync=zeros(3,3,Tr+1,betas,Rep);
weights_rule3_sync=zeros(3,3,Tr+1,betas,Rep);

% check according to the chosen module for every task rule
for b=1:betas
    for r=1:Rep
        if module(1,b,r)==1
            sync_rule1(:,:,:,b,r)=Synchronization(1:3,4:6,:,b,r);
            weights_rule1_sync(:,:,:,b,r)=Weights_sync(1:3,4:6,:,b,r);
            if module(2,b,r)==2
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,7:9,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,7:9,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,10:12,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,10:12,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,10:12,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,10:12,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,7:9,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,7:9,:,b,r);
            end;
        elseif module(1,b,r)==2
            sync_rule1(:,:,:,b,r)=Synchronization(1:3,7:9,:,b,r);
            weights_rule1_sync(:,:,:,b,r)=Weights_sync(1:3,7:9,:,b,r);
            if module(2,b,r)==1
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,4:6,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,4:6,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,10:12,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,10:12,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,10:12,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,10:12,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,4:6,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,4:6,:,b,r);
            end;
        else
            sync_rule1(:,:,:,b,r)=Synchronization(1:3,10:12,:,b,r);
            weights_rule1_sync(:,:,:,b,r)=Weights_sync(1:3,10:12,:,b,r);
            if module(2,b,r)==1
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,4:6,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,4:6,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,7:9,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,7:9,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=Synchronization(1:3,7:9,:,b,r);
                weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:3,7:9,:,b,r);
                sync_rule3(:,:,:,b,r)=Synchronization(1:3,4:6,:,b,r);
                weights_rule3_sync(:,:,:,b,r)=Weights_sync(1:3,4:6,:,b,r);
            end;
        end;
    end;
end;

% average and confidence intervals
sync_rule1=squeeze(mean(mean(sync_rule1,1),2));
sync_rule2=squeeze(mean(mean(sync_rule2,1),2));
sync_rule3=squeeze(mean(mean(sync_rule3,1),2));
weights_rule1_sync=squeeze(mean(mean(weights_rule1_sync,1),2));
weights_rule2_sync=squeeze(mean(mean(weights_rule2_sync,1),2));
weights_rule3_sync=squeeze(mean(mean(weights_rule3_sync,1),2));

mean_sync_rule1=squeeze(mean(sync_rule1,3));
mean_sync_rule2=squeeze(mean(sync_rule2,3));
mean_sync_rule3=squeeze(mean(sync_rule3,3));
mean_weights_rule1_sync=squeeze(mean(weights_rule1_sync,3));
mean_weights_rule2_sync=squeeze(mean(weights_rule2_sync,3));
mean_weights_rule3_sync=squeeze(mean(weights_rule3_sync,3));

mean_weights_conn=squeeze(mean(Weights_conn,5));
weights_rule1_conn=squeeze((mean_weights_conn(1,4,:,:)+mean_weights_conn(2,5,:,:)+mean_weights_conn(3,6,:,:) )./3);
weights_rule2_conn=squeeze((mean_weights_conn(1,5,:,:)+mean_weights_conn(2,6,:,:)+mean_weights_conn(3,4,:,:))./3);
weights_rule3_conn=squeeze((mean_weights_conn(1,6,:,:)+mean_weights_conn(2,4,:,:)+mean_weights_conn(3,5,:,:))./3);


std_sync_rule1=std(sync_rule1,0,3);
std_sync_rule2=std(sync_rule2,0,3);
std_sync_rule3=std(sync_rule3,0,3);
std_weights_rule1_sync=std(weights_rule1_sync,0,3);
std_weights_rule2_sync=std(weights_rule2_sync,0,3);
std_weights_rule3_sync=std(weights_rule3_sync,0,3);
std_weights_conn=std(Weights_conn,0,5);


CI_sync_rule1=2*(std_sync_rule1./sqrt(Rep));
CI_sync_rule2=2*(std_sync_rule2./sqrt(Rep));
CI_sync_rule3=2*(std_sync_rule3./sqrt(Rep));
CI_weights_rule1_sync=2*(std_weights_rule1_sync./sqrt(Rep));
CI_weights_rule2_sync=2*(std_weights_rule2_sync./sqrt(Rep));
CI_weights_rule3_sync=2*(std_weights_rule3_sync./sqrt(Rep));

CI_weights_conn=2*(std_weights_conn./sqrt(Rep));
CI_weights_rule1_conn=squeeze((CI_weights_conn(1,4,:,:)+CI_weights_conn(2,5,:,:)+CI_weights_conn(3,6,:,:))./3);
CI_weights_rule2_conn=squeeze((CI_weights_conn(1,5,:,:)+CI_weights_conn(2,6,:,:)+CI_weights_conn(3,4,:,:))./3);
CI_weights_rule3_conn=squeeze((CI_weights_conn(1,6,:,:)+CI_weights_conn(2,4,:,:)+CI_weights_conn(3,5,:,:))./3);

%% Phase amplitude coupling

%extract gamma-amplitude
relevant_Gamma=zeros(500,Tr,betas,Rep);
%extract theta-phase
Theta_Phase=zeros(500,Tr,betas,Rep);

%actual pac measure (dpac(Van driel et al., 2015))
dpac=zeros(Tr,betas,Rep);

for b=1:betas
    for r=1:Rep
        for tr=1:Tr
            relevant_Gamma(:,tr,b,r)=sum(abs(Gamma(:,1,:,tr,b,r)),1)./9;
            Theta_Phase(:,tr,b,r)=angle(hilbert(Theta(1,:,tr,b,r)));
            dpac(tr,b,r)=abs(mean((exp(1i*Theta_Phase(:,tr,b,r))-mean(exp(1i*Theta_Phase(:,tr,b,r)))).*relevant_Gamma(:,tr,b,r)));
        end;
    end;
end;

% compute mean, std and 95% CI
mean_pac=squeeze(mean(dpac,3));
std_pac=std(dpac,0,3);
CI_pac=2*(std_pac./sqrt(Rep));

%% Time-frequency decomposition: we divide in error and correct trials
srate=  500;
frex    = linspace(1,10,10);
wavtime = -2:1/srate:2-1/srate;
nData   = 750;%ITI
nKern   = length(wavtime);
nConv   = nData + nKern -1;
halfwav = (length(wavtime)-1)/2;

% create wavelets
cmwX = zeros(10,nConv);
for fi=1:10
    
    % create time-domain wavelet
    cmw = exp(2*1i*pi*frex(fi).*wavtime) .* exp( (-wavtime.^2) / (2*(4/(2*pi*frex(fi))).^2) );
    
    % compute fourier coefficients of wavelet and normalize
    cmwX(fi,:) = fft(cmw,nConv);
    cmwX(fi,:) = cmwX(fi,:) ./ max(cmwX(fi,:));
end

ERN_dat=zeros(750,Tr*betas*Rep);
corr_dat=zeros(750,Tr*betas*Rep);
ERN_sim=zeros(750,betas,Rep);

prev_err=1;
err=0;
corr=0;
for b=1:betas
    for r=1:Rep
        bet_err=0;
        for tr=2:Tr
            if Accuracy_sync(tr-1,b,r)==1
                corr=corr+1;
                corr_dat(:,corr)=[Theta(1,251:500,tr-1,b,r) Theta(1,1:500,tr,b,r)];  
            else
                err=err+1;
                bet_err=bet_err+1;
                ERN_dat(:,err)=[Theta(1,251:500,tr-1,b,r) Theta(1,1:500,tr,b,r)]; 
            end;
        end;
        ERN_sim(:,b,r)=squeeze(mean(ERN_dat(:,prev_err:prev_err+bet_err-1),2));
        prev_err=prev_err+bet_err;
    end;
end;
ERN_dat=ERN_dat(:,1:err);
corr_dat=corr_dat(:,1:corr);
ERN_all=mean(ERN_dat,2);
ERN_lr=squeeze(mean(ERN_sim,3));
CI_ernlr=2*std(ERN_sim,0,3)./sqrt(Rep);

tf_dat_err=zeros(size(ERN_dat,2),10,750-1,3);

for i=1:size(ERN_dat,2)
     data=fft(ERN_dat(:,i)',nConv);
     
     for fi=1:10
        
        % second and third steps of convolution
        as = ifft( cmwX(fi,:).*data ,nConv );
        
        % cut wavelet back to size of data
        as = as(round(halfwav)+1:end-round(halfwav));
        
        % extract power and phase
        tf_dat_err(i,fi,:,1) = abs(as).^2;
        tf_dat_err(i,fi,:,2) = angle(as);
        tf_dat_err(i,fi,:,3) = real(as);
        
    end % end frequency loop
end;


tf_dat_corr=zeros(size(corr_dat,2),10,750-1,3);

for i=1:size(corr_dat,2)
     data=fft(corr_dat(:,i)',nConv);
     
     for fi=1:10
        
        % second and third steps of convolution
        as = ifft( cmwX(fi,:).*data ,nConv );
        
        % cut wavelet back to size of data
        as = as(round(halfwav)+1:end-round(halfwav));
        
        % extract power and phase
        tf_dat_corr(i,fi,:,1) = abs(as).^2;
        tf_dat_corr(i,fi,:,2) = angle(as);
        tf_dat_corr(i,fi,:,3) = real(as);
        
    end % end frequency loop
end;

% Power for error trials, correct trials and the contrast between them
freq_err=squeeze(mean(tf_dat_err(:,:,:,1),1));
freq_corr=squeeze(mean(tf_dat_corr(:,:,:,1),1));
freq_diff=freq_err-freq_corr;

%% save
save('RW_data_Date','CI_ACC_conn','CI_ACC_sync','CI_accuracy_conn','CI_accuracy_sync','CI_pac','CI_plas_conn','CI_plas_sync','CI_stab_conn','CI_stab_sync','CI_sync_rule1','CI_sync_rule2','CI_sync_rule3','CI_weights_conn','CI_weights_rule1_sync','CI_weights_rule2_sync','CI_weights_rule3_sync','ERN_all','ERN_sim','freq_corr','freq_err','freq_diff','mean_ACC_conn','mean_ACC_sync','mean_pac','mean_plas_conn','mean_plas_sync','mean_stab_conn','mean_stab_sync','mean_sync_rule1','mean_sync_rule2','mean_sync_rule3','mean_accuracy_conn','mean_accuracy_sync','mean_weights_conn', 'mean_weights_rule1_sync', 'mean_weights_rule2_sync', 'mean_weights_rule3_sync', 'Switcher','binned_accuracy_sync', 'binned_accuracy_conn','-v7.3')
