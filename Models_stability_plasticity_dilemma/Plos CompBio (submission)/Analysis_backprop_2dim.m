
Rep=10;
betas=11;
Tr=3600;

Accuracy_conn=zeros(Tr,betas,Rep);
ERR_conn=zeros(Tr,betas,Rep);

Accuracy_sync=zeros(Tr,betas,Rep);
reward=zeros(Tr,betas,Rep);
ERR_sync=zeros(Tr,betas,Rep);
relevant_Gamma=zeros(500,Tr,betas,Rep);        %gamma waves for pac measure (4000 is just approximation of timesteps until response)
Theta= zeros(2,500,Tr,betas,Rep);          %theta waves for pac measure
synchronization_IM1=zeros(9,6,Tr,betas,Rep);
synchronization_IM2=zeros(9,6,Tr,betas,Rep);
synchronization_IM3=zeros(9,6,Tr,betas,Rep);
module=zeros(2,betas,Rep);
Switcher=zeros(Tr+1,betas,Rep);

gam_wav=zeros(30,500,Tr);

for b=1:betas
    for r=1:Rep
        
        load(['backprop_nosync_Beta',num2str(b),'Rep',num2str(r)])
        Accuracy_conn(:,b,r)=squeeze(rew)*100;
        ERR_conn(:,b,r)=squeeze(mean(Errorscore,1));
        
        load(['backprop_sync_Beta',num2str(b),'Rep',num2str(r)])
        
        gam_wav(1:9,:,:)=Phase_Input(:,1,1:500,:);
        gam_wav(10:15,:,:)=Phase_M1(:,1,1:500,:);
        gam_wav(16:21,:,:)=Phase_M2(:,1,1:500,:);
        gam_wav(22:27,:,:)=Phase_M3(:,1,1:500,:); 
        gam_wav(28:30,:,:)=Phase_Out(:,1,1:500,:); 
        relevant_Gamma(:,:,b,r)=squeeze(mean(abs(gam_wav(:,:,:)),1));%extract gamma
               
        Theta(:,:,:,b,r)=ACC(:,1:500,:);              %extract theta
        Accuracy_sync(:,b,r)=squeeze(rew)*100;
        reward(:,b,r)=squeeze(rew(1,:));
        ERR_sync(:,b,r)=squeeze(mean(Errorscore,1));
        Switcher(:,b,r)=squeeze(S);
        synchronization_IM1(:,:,:,b,r)=sync_IM1;
        synchronization_IM2(:,:,:,b,r)=sync_IM2;
        synchronization_IM3(:,:,:,b,r)=sync_IM3;

        if LFC(2,1)==1
            module(1,b,r)=1;
        elseif LFC(3,1)==1
            module(1,b,r)=2;
        else
            module(1,b,r)=3; 
        end;
        if LFC(2,800)==1
            module(2,b,r)=1;
        elseif LFC(3,800)==1
            module(2,b,r)=2;
        else
            module(2,b,r)=3; 
        end;
    end;
end;

binned_accuracy_conn=zeros(120,betas,Rep);
binned_errorscore_conn=zeros(120,betas,Rep);
bin_edges=(1:Tr/120:Tr+1)-1;
for i =1:length(bin_edges)-1
    binned_accuracy_conn(i,:,:)=mean(Accuracy_conn(bin_edges(i)+1:bin_edges(i+1),:,:),1);
    binned_errorscore_conn(i,:,:)=mean(ERR_conn(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

mean_ACC_conn=squeeze(mean(Accuracy_conn,3));
mean_ERR_conn=squeeze(mean(ERR_conn,3));
CI_ACC_conn=squeeze(2*std(Accuracy_conn,0,3)./sqrt(Rep));
CI_ERR_conn=squeeze(2*std(ERR_conn,0,3)./sqrt(Rep));
overall_ACC_conn=mean(mean_ACC_conn,1);
CI_all_acc_conn=(2*squeeze(std(mean(Accuracy_conn,1),0,3))./sqrt(Rep));

binned_accuracy_sync=zeros(120,betas,Rep);
binned_errorscore_sync=zeros(120,betas,Rep);
for i =1:length(bin_edges)-1
    binned_accuracy_sync(i,:,:)=mean(Accuracy_sync(bin_edges(i)+1:bin_edges(i+1),:,:),1);
    binned_errorscore_sync(i,:,:)=mean(ERR_sync(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

mean_ACC_sync=squeeze(mean(Accuracy_sync,3));
mean_ERR_sync=squeeze(mean(ERR_sync,3));
CI_ACC_sync=squeeze(2*std(Accuracy_sync,0,3)./sqrt(Rep));
CI_ERR_sync=squeeze(2*std(ERR_sync,0,3)./sqrt(Rep));
overall_ACC_sync=mean(mean_ACC_sync,1);
CI_all_acc_sync=(2*squeeze(std(mean(Accuracy_sync,1),0,3))./sqrt(Rep));

%determine critical moments
stability_R1_1=15:20;
stability_R1_2=61:65;
stability_R2_1=35:40;
stability_R2_2=81:85;
stability_R3_1=55:60;
stability_R3_2=101:105;
plasticity_1=1:5;
plasticity_2=21:25;
plasticity_3=41:60;

%Compute stability and plasticity for both models
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

mean_plas_sync=mean(Plasticity_sync,3);
std_plas_sync=std(Plasticity_sync,0,3);
CI_plas_sync=2*std_plas_sync./sqrt(Rep);
mean_stab_sync=mean(Stability_sync,3);
std_stab_sync=std(Stability_sync,0,3);
CI_stab_sync=2*std_stab_sync./sqrt(Rep);

mean_plas_conn=mean(Plasticity_conn,3);
std_plas_conn=std(Plasticity_conn,0,3);
CI_plas_conn=2*std_plas_conn./sqrt(Rep);
mean_stab_conn=mean(Stability_conn,3);
std_stab_conn=std(Stability_conn,0,3);
CI_stab_conn=2*std_stab_conn./sqrt(Rep);

Plas_sync_for_paper(1,:)=mean(mean_plas_sync(2:3,:),1);
Plas_sync_for_paper(2,:)=mean(CI_plas_sync(2:3,:),1);
Stab_sync_for_paper(1,:)=mean(mean_stab_sync,1);
Stab_sync_for_paper(2,:)=mean(CI_stab_sync,1);

Plas_conn_for_paper(1,:)=mean(mean_plas_conn(2:3,:),1);
Plas_conn_for_paper(2,:)=mean(CI_plas_conn(2:3,:),1);
Stab_conn_for_paper(1,:)=mean(mean_stab_conn,1);
Stab_conn_for_paper(2,:)=mean(CI_stab_conn,1);


%% empirical stuff
%compute means     
sync_rule1=zeros(9,6,Tr,betas,Rep);
sync_rule2=zeros(9,6,Tr,betas,Rep);
sync_rule3=zeros(9,6,Tr,betas,Rep);

for b=1:betas
    for r=1:Rep
        if module(1,b,r)==1
            sync_rule1(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
            if module(2,b,r)==2
                sync_rule2(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM3(:,:,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=synchronization_IM3(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
            end;
        elseif module(1,b,r)==2
            sync_rule1(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
            if module(2,b,r)==1
                sync_rule2(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM3(:,:,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=synchronization_IM3(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
            end;
        else
            sync_rule1(:,:,:,b,r)=synchronization_IM3(:,:,:,b,r);
            if module(2,b,r)==1
                sync_rule2(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
            else
                sync_rule2(:,:,:,b,r)=synchronization_IM2(:,:,:,b,r);
                sync_rule3(:,:,:,b,r)=synchronization_IM1(:,:,:,b,r);
            end;
        end;
    end;
end;

%% begin
sync_rule1=squeeze(mean(mean(sync_rule1,1),2));
sync_rule2=squeeze(mean(mean(sync_rule2,1),2));
sync_rule3=squeeze(mean(mean(sync_rule3,1),2));

mean_sync_rule1=squeeze(mean(sync_rule1,3));
mean_sync_rule2=squeeze(mean(sync_rule2,3));
mean_sync_rule3=squeeze(mean(sync_rule3,3));

%compute standard deviations
std_sync_rule1=std(sync_rule1,0,3);
std_sync_rule2=std(sync_rule2,0,3);
std_sync_rule3=std(sync_rule3,0,3);

%compute 95% confidence interval
CI_sync_rule1=2*(std_sync_rule1./sqrt(Rep));
CI_sync_rule2=2*(std_sync_rule2./sqrt(Rep));
CI_sync_rule3=2*(std_sync_rule3./sqrt(Rep));

%% begin
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

%% begin
% compute mean, std and 95% CI
mean_pac=squeeze(mean(dpac,3));
std_pac=std(dpac,0,3);
CI_pac=2*(std_pac./sqrt(Rep));

%relation between synchronization and RT
relevant_sync(1:600,:,:)=squeeze(sync_rule1(1:600,:,:));
relevant_sync(601:1200,:,:)=squeeze(sync_rule2(601:1200,:,:));
relevant_sync(1201:1800,:,:)=squeeze(sync_rule1(1201:1800,:,:));

%% ERN
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

%%
ERN_dat=zeros(750,Tr*betas*Rep);
corr_dat=zeros(750,Tr*betas*Rep);
ERN_sim=zeros(750,betas,Rep);

prev_err=1;
err=0;
corr=0;
%%
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

%%
ERN_dat=ERN_dat(:,1:err);
corr_dat=corr_dat(:,1:corr);
ERN_all=mean(ERN_dat,2);

tf_dat_err=zeros(round(size(ERN_dat,2)/2),10,750-1);
tf_dat_err2=zeros(size(ERN_dat,2)-round(size(ERN_dat,2)/2),10,750-1);

for i=1:size(ERN_dat,2)
     data=fft(ERN_dat(:,i)',nConv);
     
     for fi=1:10
        
        % second and third steps of convolution
        as = ifft( cmwX(fi,:).*data ,nConv );
        
        % cut wavelet back to size of data
        as = as(round(halfwav)+1:end-round(halfwav));
        
       % extract power and phase
        if i<round(size(ERN_dat,2)/2)+1
            tf_dat_err(i,fi,:) = abs(as).^2;
        else
            tf_dat_err2(i-round(size(ERN_dat,2)/2),fi,:) = abs(as).^2;
        end;
        
    end % end frequency loop
end;

%%
tf_dat_corr=zeros(round(size(corr_dat,2)/2),10,750-1);
tf_dat_corr2=zeros(size(corr_dat,2)-round(size(corr_dat,2)/2),10,750-1);

for i=1:size(corr_dat,2)
    
     data=fft(corr_dat(:,i)',nConv);
     
     for fi=1:10
        
        % second and third steps of convolution
        as = ifft( cmwX(fi,:).*data ,nConv );
        
        % cut wavelet back to size of data
        as = as(round(halfwav)+1:end-round(halfwav));
        
        % extract power and phase
        if i<round(size(corr_dat,2)/2)+1
            tf_dat_corr(i,fi,:) = abs(as).^2;
        else
            tf_dat_corr2(i-round(size(corr_dat,2)/2),fi,:) = abs(as).^2;
        end;
        %tf_dat_corr(i,fi,:,2) = angle(as);
        %tf_dat_corr(i,fi,:,3) = real(as);
        
    end % end frequency loop
end;


freq_corr=squeeze((mean(tf_dat_corr,1)* round(size(corr_dat,2)/2) + mean(tf_dat_corr2,1)* (size(corr_dat,2) - round(size(corr_dat,2)/2)))./size(corr_dat,2));
freq_err=squeeze((mean(tf_dat_err,1)* round(size(ERN_dat,2)/2) + mean(tf_dat_err2,1)* (size(ERN_dat,2) - round(size(ERN_dat,2)/2)))./size(ERN_dat,2));
freq_diff=freq_err-freq_corr;
%%
save('backprop_data_2','CI_ACC_conn','CI_ACC_sync','CI_all_acc_conn','CI_all_acc_sync','CI_pac','CI_plas_conn','CI_plas_sync','CI_stab_conn','CI_stab_sync','CI_sync_rule1','CI_sync_rule2','CI_sync_rule3','ERN_all','ERN_sim','freq_corr','freq_err','freq_diff','mean_ACC_conn','mean_ACC_sync','mean_pac','mean_plas_conn','mean_plas_sync','mean_stab_conn','mean_stab_sync','mean_sync_rule1','mean_sync_rule2','mean_sync_rule3','overall_ACC_conn','overall_ACC_sync','Switcher','binned_accuracy_sync', 'binned_accuracy_conn')
