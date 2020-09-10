%{
    script for the analyses of the RBM model on the three dimensional task
%}

%% Define variables

%Amounts of everything
Rep=10;             %simulations
betas=11;           %learning rates
bins=120;           %trial bins for analyses
Tr=3600;            %trials

%Initialize all data matrices
%For the classic (synaptic) models
Accuracy_conn=zeros(Tr,betas,Rep); 
ERR_conn=zeros(Tr,betas,Rep);
%For the Sync model
Accuracy_sync=zeros(Tr,betas,Rep);
ERR_sync=zeros(Tr,betas,Rep);
synchronization_IM1=zeros(12,6,Tr,betas,Rep);
synchronization_IM2=zeros(12,6,Tr,betas,Rep);
synchronization_IM3=zeros(12,6,Tr,betas,Rep);
module=zeros(2,betas,Rep);
Switcher=zeros(Tr+1,betas,Rep);

%% load data and store in data matrices

for b=1:betas
for rep=1:Rep
    
    load(['RBM_nosync_Beta',num2str(b),'Rep',num2str(rep)])
    Accuracy_conn(:,b,rep)=squeeze(rew)*100;
    ERR_conn(:,b,rep)=squeeze(mean(Errorscore,1));

    load(['RBM_sync_Beta',num2str(b),'Rep',num2str(rep)])
    Accuracy_sync(:,b,rep)=squeeze(rew)*100;
    ERR_sync(:,b,rep)=squeeze(mean(Errorscore,1));
    Switcher(:,b,rep)=squeeze(S);
    synchronization_IM1(:,:,:,b,rep)=sync_IM1;
    synchronization_IM2(:,:,:,b,rep)=sync_IM2;
    synchronization_IM3(:,:,:,b,rep)=sync_IM3;

    %derive which module was used first, second and third
    if LFC(2,1)==1
        module(1,b,rep)=1;
    elseif LFC(3,1)==1
        module(1,b,rep)=2;
    else
        module(1,b,rep)=3; 
    end;
    if LFC(2,800)==1
        module(2,b,rep)=1;
    elseif LFC(3,800)==1
        module(2,b,rep)=2;
    else
        module(2,b,rep)=3; 
    end;
end;
end;

%% General performance of the synaptic model

%compute binned accuracy: divide 3600 trials in 120 bins
binned_accuracy_conn=zeros(120,betas,Rep);
binned_errorscore_conn=zeros(120,betas,Rep);
bin_edges=(1:Tr/120:Tr+1)-1;
for i =1:length(bin_edges)-1
    binned_accuracy_conn(i,:,:)=mean(Accuracy_conn(bin_edges(i)+1:bin_edges(i+1),:,:),1);
    binned_errorscore_conn(i,:,:)=mean(ERR_conn(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

%compute means and confidence intervals (accuracy and errorscore)
mean_ACC_conn=squeeze(mean(Accuracy_conn,3));
mean_ERR_conn=squeeze(mean(ERR_conn,3));
CI_ACC_conn=squeeze(2*std(Accuracy_conn,0,3)./sqrt(Rep));
CI_ERR_conn=squeeze(2*std(ERR_conn,0,3)./sqrt(Rep));
overall_ACC_conn=mean(mean_ACC_conn,1);
CI_all_acc_conn=(2*squeeze(std(mean(Accuracy_conn,1),0,3))./sqrt(Rep));

%% General performance of the full model

%compute binned accuracy: divide 3600 trials in 120 bins
binned_accuracy_sync=zeros(120,betas,Rep);
binned_errorscore_sync=zeros(120,betas,Rep);
for i =1:length(bin_edges)-1
    binned_accuracy_sync(i,:,:)=mean(Accuracy_sync(bin_edges(i)+1:bin_edges(i+1),:,:),1);
    binned_errorscore_sync(i,:,:)=mean(ERR_sync(bin_edges(i)+1:bin_edges(i+1),:,:),1);
end;

%compute means and confidence intervals (accuracy and errorscore)
mean_ACC_sync=squeeze(mean(Accuracy_sync,3));
mean_ERR_sync=squeeze(mean(ERR_sync,3));
CI_ACC_sync=squeeze(2*std(Accuracy_sync,0,3)./sqrt(Rep));
CI_ERR_sync=squeeze(2*std(ERR_sync,0,3)./sqrt(Rep));
overall_ACC_sync=mean(mean_ACC_sync,1);
CI_all_acc_sync=(2*squeeze(std(mean(Accuracy_sync,1),0,3))./sqrt(Rep));

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

% The full model
Stability_sync(1,:,:)=mean(binned_accuracy_sync(stability_R1_2,:,:),1)-mean(binned_accuracy_sync(stability_R1_1,:,:),1);
Stability_sync(2,:,:)=mean(binned_accuracy_sync(stability_R2_2,:,:),1)-mean(binned_accuracy_sync(stability_R2_1,:,:),1);
Stability_sync(3,:,:)=mean(binned_accuracy_sync(stability_R3_2,:,:),1)-mean(binned_accuracy_sync(stability_R3_1,:,:),1);

Plasticity_sync(1,:,:)=mean(binned_accuracy_sync(plasticity_1,:,:),1);
Plasticity_sync(2,:,:)=mean(binned_accuracy_sync(plasticity_2,:,:),1);
Plasticity_sync(3,:,:)=mean(binned_accuracy_sync(plasticity_3,:,:),1);

% Average and confidence intervals
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

%% Synchronization of task modules

%compute means     
sync_rule1=zeros(12,6,Tr,betas,Rep);
sync_rule2=zeros(12,6,Tr,betas,Rep);
sync_rule3=zeros(12,6,Tr,betas,Rep);

% check according to the chosen module for every task rule
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

% average and confidence intervals
sync_rule1=squeeze(mean(mean(sync_rule1,1),2));
sync_rule2=squeeze(mean(mean(sync_rule2,1),2));
sync_rule3=squeeze(mean(mean(sync_rule3,1),2));

mean_sync_rule1=squeeze(mean(sync_rule1,3));
mean_sync_rule2=squeeze(mean(sync_rule2,3));
mean_sync_rule3=squeeze(mean(sync_rule3,3));

std_sync_rule1=std(sync_rule1,0,3);
std_sync_rule2=std(sync_rule2,0,3);
std_sync_rule3=std(sync_rule3,0,3);

CI_sync_rule1=2*(std_sync_rule1./sqrt(Rep));
CI_sync_rule2=2*(std_sync_rule2./sqrt(Rep));
CI_sync_rule3=2*(std_sync_rule3./sqrt(Rep));

%% save
save('RBM_data_','CI_ACC_conn','CI_ACC_sync','CI_all_acc_conn','CI_all_acc_sync','CI_plas_conn','CI_plas_sync','CI_stab_conn','CI_stab_sync','CI_sync_rule1','CI_sync_rule2','CI_sync_rule3','mean_ACC_conn','mean_ACC_sync','mean_plas_conn','mean_plas_sync','mean_stab_conn','mean_stab_sync','mean_sync_rule1','mean_sync_rule2','mean_sync_rule3','overall_ACC_conn','overall_ACC_sync','Switcher','binned_accuracy_sync', 'binned_accuracy_conn')
