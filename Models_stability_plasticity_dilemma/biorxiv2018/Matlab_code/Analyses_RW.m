%{
    Script for analyses of RW model
}

%% define variables

betas=11;
Rep=10;
Tr=240;

Accuracy_conn=zeros(Tr,betas,Rep); %accuracy variable
Weights_conn=zeros(4,4,Tr+1,betas,Rep);

Accuracy_sync=zeros(Tr,betas,Rep); %accuracy variable
Weights_sync=zeros(6,6,Tr+1,betas,Rep);

Gamma=zeros(6,2,500,Tr,betas,Rep);        %gamma waves for pac measure (4000 is just approximation of timesteps until response)
Theta=zeros(2,500,Tr,betas,Rep);          %theta waves for pac measure
Synchronization=zeros(6,6,Tr,betas,Rep);   %synchronization
module=zeros(betas,Rep);
Switcher=zeros(Tr+1,betas,Rep);

%% extract data from files

%extract accuracy data from workspaces
for b=1:betas
        for r=1:Rep
            load(['Beta',num2str(b),'Rep',num2str(r),'_RWonly'],'rew','W');
            Accuracy_conn(:,b,r)=squeeze(rew);
            Weights_conn(:,:,:,b,r)=W;
        end;
end;
for b=1:betas
        for r=1:Rep
            load(['Beta',num2str(b),'Rep',num2str(r),'_RWsync'],'Phase','ACC','sync','rew','W','S','LFC');
            Gamma(:,:,:,:,b,r)=Phase(:,:,1:500,:);        %extract gamma
            Theta(:,:,:,b,r)=ACC(:,1:500,:);              %extract theta
            Synchronization(:,:,:,b,r)=sync;      %extract synchronization
            Accuracy_sync(:,b,r)=squeeze(rew);
            Weights_sync(:,:,:,b,r)=W;
            Switcher(:,b,r)=squeeze(S);
            if LFC(2,1)==1
                module(b,r)=1;
            else
                module(b,r)=2;
            end;
        end;
end;

%% Analyses
%compute mean accuracy
mean_accuracy_conn=squeeze(mean(Accuracy_conn,3))*100; %over replications
std_accuracy_conn=squeeze(std(Accuracy_conn.*100,0,3));
CI_accuracy_conn=2*(std_accuracy_conn./sqrt(Rep));

mean_ACC_conn=squeeze(mean(mean_accuracy_conn,1)); %over trials
CI_ACC_conn=(2*squeeze(std(mean(Accuracy_conn,1),0,3))./sqrt(Rep)).*100;

mean_accuracy_sync=squeeze(mean(Accuracy_sync,3))*100; %over replications
std_accuracy_sync=squeeze(std(Accuracy_sync.*100,0,3));
CI_accuracy_sync=2*(std_accuracy_sync./sqrt(Rep));

mean_ACC_sync=squeeze(mean(mean_accuracy_sync,1)); %over trials
CI_ACC_sync=(2*squeeze(std(mean(Accuracy_sync,1),0,3))./sqrt(Rep)).*100;

%determine critical moments
start=61:80;          %first 5 trials
Change_one=81:100;   %first 5 trials after switch 1
Change_two=161:180;   %first 5 trials after switch 2

%compute mean accuracy for these moments
A=squeeze(mean(Accuracy_conn(start,:,:),1));
B=squeeze(mean(Accuracy_conn(Change_one,:,:),1));
C=squeeze(mean(Accuracy_conn(Change_two,:,:),1));

sync_A=squeeze(mean(Accuracy_sync(start,:,:),1));
sync_B=squeeze(mean(Accuracy_sync(Change_one,:,:),1));
sync_C=squeeze(mean(Accuracy_sync(Change_two,:,:),1));

plasticity_sync=sync_B;
plasticity_conn=B;
stability_sync=sync_C-sync_A;
stability_conn=C-A;

mean_plas_sync=mean(plasticity_sync,2)*100;
std_plas_sync=std(plasticity_sync,0,2);
CI_plas_sync=2*std_plas_sync./sqrt(Rep)*100;
mean_stab_sync=mean(stability_sync,2)*100;
std_stab_sync=std(stability_sync,0,2);
CI_stab_sync=2*std_stab_sync./sqrt(Rep)*100;

mean_plas_conn=mean(plasticity_conn,2)*100;
std_plas_conn=std(plasticity_conn,0,2);
CI_plas_conn=2*std_plas_conn./sqrt(Rep)*100;
mean_stab_conn=mean(stability_conn,2)*100;
std_stab_conn=std(stability_conn,0,2);
CI_stab_conn=2*std_stab_conn./sqrt(Rep)*100;

%% synchronization
%compute means     
sync_rule1=zeros(2,2,Tr,betas,Rep);
sync_rule2=zeros(2,2,Tr,betas,Rep);
weights_rule1_sync=zeros(2,2,Tr+1,betas,Rep);
weights_rule2_sync=zeros(2,2,Tr+1,betas,Rep);
for b=1:betas
    for r=1:Rep
        if module(b,r)==1
            sync_rule1(:,:,:,b,r)=Synchronization(1:2,3:4,:,b,r);
            sync_rule2(:,:,:,b,r)=Synchronization(1:2,5:6,:,b,r);
            weights_rule1_sync(:,:,:,b,r)=Weights_sync(1:2,3:4,:,b,r);
            weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:2,5:6,:,b,r);
        else
            sync_rule1(:,:,:,b,r)=Synchronization(1:2,5:6,:,b,r);
            sync_rule2(:,:,:,b,r)=Synchronization(1:2,3:4,:,b,r);
            weights_rule1_sync(:,:,:,b,r)=Weights_sync(1:2,5:6,:,b,r);
            weights_rule2_sync(:,:,:,b,r)=Weights_sync(1:2,3:4,:,b,r);
        end;
    end;
end;
sync_rule1=squeeze(mean(mean(sync_rule1,1),2));
sync_rule2=squeeze(mean(mean(sync_rule2,1),2));
weights_rule1_sync=squeeze(mean(mean(weights_rule1_sync,1),2));
weights_rule2_sync=squeeze(mean(mean(weights_rule2_sync,1),2));

mean_sync_rule1=squeeze(mean(sync_rule1,3));
mean_sync_rule2=squeeze(mean(sync_rule2,3));
mean_weights_rule1_sync=squeeze(mean(weights_rule1_sync,3));
mean_weights_rule2_sync=squeeze(mean(weights_rule2_sync,3));

mean_weights_conn=squeeze(mean(Weights_conn,5));
weights_rule1_conn=squeeze((mean_weights_conn(1,3,:,:)+mean_weights_conn(2,4,:,:))./2);
weights_rule2_conn=squeeze((mean_weights_conn(2,3,:,:)+mean_weights_conn(1,4,:,:))./2);

%compute standard deviations
std_sync_rule1=std(sync_rule1,0,3);
std_sync_rule2=std(sync_rule2,0,3);
std_weights_rule1_sync=std(weights_rule1_sync,0,3);
std_weights_rule2_sync=std(weights_rule2_sync,0,3);

std_weights_conn=std(Weights_conn,0,5);

%compute 95% confidence interval
CI_sync_rule1=2*(std_sync_rule1./sqrt(Rep));
CI_sync_rule2=2*(std_sync_rule2./sqrt(Rep));
CI_weights_rule1_sync=2*(std_weights_rule1_sync./sqrt(Rep));
CI_weights_rule2_sync=2*(std_weights_rule2_sync./sqrt(Rep));

CI_weights_conn=2*(std_weights_conn./sqrt(Rep));
CI_weights_rule1_conn=squeeze((CI_weights_conn(1,3,:,:)+CI_weights_conn(2,4,:,:))./2);
CI_weights_rule2_conn=squeeze((CI_weights_conn(2,3,:,:)+CI_weights_conn(1,4,:,:))./2);

%extract gamma-amplitude
relevant_Gamma=zeros(500,Tr,betas,Rep);
%extract theta-phase
Theta_Phase=zeros(500,Tr,betas,Rep);

%actual pac measure (dpac(Van driel et al., 2015))
dpac=zeros(Tr,betas,Rep);

for b=1:betas
    for r=1:Rep
        for tr=1:Tr
            relevant_Gamma(:,tr,b,r)=sum(abs(Gamma(:,1,:,tr,b,r)),1)./6;
            Theta_Phase(:,tr,b,r)=angle(hilbert(Theta(1,:,tr,b,r)));
            dpac(tr,b,r)=abs(mean((exp(1i*Theta_Phase(:,tr,b,r))-mean(exp(1i*Theta_Phase(:,tr,b,r)))).*relevant_Gamma(:,tr,b,r)));
        end;
    end;
end;

% compute mean, std and 95% CI
mean_pac=squeeze(mean(dpac,3));
std_pac=std(dpac,0,3);
CI_pac=2*(std_pac./sqrt(Rep));

%% Time-frequency and ERP
srate=500;
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

freq_err=squeeze(mean(tf_dat_err(:,:,:,1),1));
freq_corr=squeeze(mean(tf_dat_corr(:,:,:,1),1));
freq_diff=freq_err-freq_corr;
