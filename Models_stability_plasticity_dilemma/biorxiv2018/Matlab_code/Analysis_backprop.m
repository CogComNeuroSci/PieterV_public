%{
    Script for analyses of backpropagation data
%}

%% define variables
Rep=10;
betas=11;
Tr=2400;

Accuracy_conn=zeros(60,betas,Rep);
ERR_conn=zeros(60,betas,Rep);

Accuracy_sync=zeros(60,betas,Rep);
reward=zeros(Tr,betas,Rep);
ERR_sync=zeros(60,betas,Rep);
relevant_Gamma=zeros(500,Tr,betas,Rep);        %gamma waves for pac measure (4000 is just approximation of timesteps until response)
Theta= zeros(2,500,Tr,betas,Rep);          %theta waves for pac measure
synchronization_IM1=zeros(6,4,2400,betas,Rep);
synchronization_IM2=zeros(6,4,2400,betas,Rep);
module=zeros(betas,Rep);
Switcher=zeros(Tr+1,betas,Rep);

gam_wav=zeros(16,500,Tr);

%% load data
for b=1:betas
    for r=1:Rep
        
        load(['backprop_nosync_Beta',num2str(b),'Rep',num2str(r)],'binned_accuracy','binned_Errorscore')
        Accuracy_conn(:,b,r)=squeeze(binned_accuracy)*100;
        ERR_conn(:,b,r)=squeeze(binned_Errorscore);
        
        load(['backprop_sync_Beta',num2str(b),'Rep',num2str(r)],'binned_accuracy','binned_Errorscore','sync_IM1','sync_IM2','S','LFC','Phase_Input','Phase_M1','Phase_M2','Phase_Out','ACC','rew')
        
        gam_wav(1:6,:,:)=Phase_Input(:,1,1:500,:);
        gam_wav(7:10,:,:)=Phase_M1(:,1,1:500,:);
        gam_wav(11:14,:,:)=Phase_M2(:,1,1:500,:);
        gam_wav(15:16,:,:)=Phase_Out(:,1,1:500,:); 
        relevant_Gamma(:,:,b,r)=squeeze(mean(abs(gam_wav(:,:,:)),1));%extract gamma
        
       
        Theta(:,:,:,b,r)=ACC(:,1:500,:);              %extract theta
        Accuracy_sync(:,b,r)=squeeze(binned_accuracy)*100;
        reward(:,b,r)=squeeze(rew(1,:));
        ERR_sync(:,b,r)=squeeze(binned_Errorscore);
        Switcher(:,b,r)=squeeze(S);
        synchronization_IM1(:,:,:,b,r)=sync_IM1;
        synchronization_IM2(:,:,:,b,r)=sync_IM2;
        if LFC(1,1)==1
            module(b,r)=1;
        else
            module(b,r)=2;
        end;
    end;
end;

%% analyses
%accuracy
mean_ACC_conn=squeeze(mean(Accuracy_conn,3));
mean_ERR_conn=squeeze(mean(ERR_conn,3));
CI_ACC_conn=squeeze(2*std(Accuracy_conn,0,3)./sqrt(Rep));
CI_ERR_conn=squeeze(2*std(ERR_conn,0,3)./sqrt(Rep));
overall_ACC_conn=mean(mean_ACC_conn,1);
CI_all_acc_conn=(2*squeeze(std(mean(Accuracy_conn,1),0,3))./sqrt(Rep));

mean_ACC_sync=squeeze(mean(Accuracy_sync,3));
mean_ERR_sync=squeeze(mean(ERR_sync,3));
CI_ACC_sync=squeeze(2*std(Accuracy_sync,0,3)./sqrt(Rep));
CI_ERR_sync=squeeze(2*std(ERR_sync,0,3)./sqrt(Rep));
overall_ACC_sync=mean(mean_ACC_sync,1);
CI_all_acc_sync=(2*squeeze(std(mean(Accuracy_sync,1),0,3))./sqrt(Rep));

%% stability-plasticity measures
%determine critical moments
start=1:5;          %first 5 trials
end_one=15:19;      %last 5 trials before switch 1
Change_one=21:25;   %first 5 trials after switch 1
end_two=35:39;      %last 5 trials before switch 2
Change_two=41:45;   %first 5 trials after switch 2
final=56:60;        %last 5 trials

%compute mean accuracy for these moments
A=squeeze(mean(Accuracy_conn(end_one,:,:),1));
%A_2=squeeze(mean(avg_accuracy(end_one,:,:),1));
B=squeeze(mean(Accuracy_conn(Change_one,:,:),1));
%B_2=squeeze(mean(avg_accuracy(end_two,:,:),1));
C=squeeze(mean(Accuracy_conn(Change_two,:,:),1));
%C_2=squeeze(mean(avg_accuracy(final,:,:),1));

sync_A=squeeze(mean(Accuracy_sync(end_one,:,:),1));
sync_B=squeeze(mean(Accuracy_sync(Change_one,:,:),1));
sync_C=squeeze(mean(Accuracy_sync(Change_two,:,:),1));

plasticity_sync=sync_B;
plasticity_conn=B;
stability_sync=sync_C-sync_A;
stability_conn=C-A;

mean_plas_sync=mean(plasticity_sync,2);
std_plas_sync=std(plasticity_sync,0,2);
CI_plas_sync=2*std_plas_sync./sqrt(Rep);
mean_stab_sync=mean(stability_sync,2);
std_stab_sync=std(stability_sync,0,2);
CI_stab_sync=2*std_stab_sync./sqrt(Rep);

mean_plas_conn=mean(plasticity_conn,2);
std_plas_conn=std(plasticity_conn,0,2);
CI_plas_conn=2*std_plas_conn./sqrt(Rep);
mean_stab_conn=mean(stability_conn,2);
std_stab_conn=std(stability_conn,0,2);
CI_stab_conn=2*std_stab_conn./sqrt(Rep);


%% Synchronization
%compute means     
sync_rule1=zeros(6,4,Tr,betas,Rep);
sync_rule2=zeros(6,4,Tr,betas,Rep);

for b=1:betas
    for r=1:Rep
        if module(b,r)==1
            sync_rule1(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
            sync_rule2(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);

        else
            sync_rule1(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
            sync_rule2(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);

        end;
    end;
end;

sync_rule1=squeeze(mean(mean(sync_rule1,1),2));
sync_rule2=squeeze(mean(mean(sync_rule2,1),2));

mean_sync_rule1=squeeze(mean(sync_rule1,3));
mean_sync_rule2=squeeze(mean(sync_rule2,3));

%compute standard deviations
std_sync_rule1=std(sync_rule1,0,3);
std_sync_rule2=std(sync_rule2,0,3);

%compute 95% confidence interval
CI_sync_rule1=2*(std_sync_rule1./sqrt(Rep));
CI_sync_rule2=2*(std_sync_rule2./sqrt(Rep));

%extract theta-phase
Theta_Phase=zeros(500,Tr,betas,Rep);
%actual pac measure (dpac(Van driel et al., 2015))
dpac=zeros(Tr,betas,Rep);

for b=1:betas
    for r=1:Rep
        for tr=1:Tr
            Theta_Phase(:,tr,b,r)=angle(hilbert(Theta(1,:,tr,b,r)));
            dpac(tr,b,r)=abs(mean((exp(1i*Theta_Phase(:,tr,b,r))-mean(exp(1i*Theta_Phase(:,tr,b,r)))).*relevant_Gamma(:,tr,b,r)));
        end;
    end;
end;

% compute mean, std and 95% CI
mean_pac=squeeze(mean(dpac,3));
std_pac=std(dpac,0,3);
CI_pac=2*(std_pac./sqrt(Rep));

%% Time frequency and ERP
srate=500;
frex    = linspace(1,10,10);
wavtime = -2:1/srate:2-1/srate;
nData   = 750;%ITI
nKern   = length(wavtime);
nConv   = nData + nKern -1;
halfwav = (length(wavtime)-1)/2;

%% create wavelets
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
            if reward(tr-1,b,r)==1
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


freq_corr=squeeze(mean(tf_dat_corr(:,:,:,1),1));
freq_err=squeeze(mean(tf_dat_err(:,:,:,1),1));
freq_diff=freq_err-freq_corr;
              
%% save
save('backprop_data_180914','CI_ACC_conn','CI_ACC_sync','CI_all_acc_conn','CI_all_acc_sync','CI_pac','CI_plas_conn','CI_plas_sync','CI_stab_conn','CI_stab_sync','CI_sync_rule1','CI_sync_rule2','ERN_all','ERN_sim','freq_corr','freq_err','freq_diff','mean_ACC_conn','mean_ACC_sync','mean_pac','mean_plas_conn','mean_plas_sync','mean_stab_conn','mean_stab_sync','mean_sync_rule1','mean_sync_rule2','overall_ACC_conn','overall_ACC_sync','Switcher','A','B','C','sync_A','sync_B','sync_C')
