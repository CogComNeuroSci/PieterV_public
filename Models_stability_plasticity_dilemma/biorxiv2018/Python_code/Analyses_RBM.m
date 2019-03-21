Rep=10;
betas=11;
bins=60;
Tr=2400;

ACC_conn=zeros(60,betas,Rep);
ERR_conn=zeros(60,betas,Rep);
ACC_sync=zeros(60,betas,Rep);
ERR_sync=zeros(60,betas,Rep);
synchronization_IM1=zeros(6,4,2400,betas,Rep);
synchronization_IM2=zeros(6,4,2400,betas,Rep);
module=zeros(betas,Rep);
Switcher=zeros(2401,betas,Rep);

for b=1:betas
for rep=1:Rep
    
    load(['RBM_nosync_Beta',num2str(b),'Rep',num2str(rep)],'binned_accuracy_min','binned_Errorscore_min')
    ACC_conn(:,b,rep)=squeeze(binned_accuracy_min)*100;
    ERR_conn(:,b,rep)=squeeze(binned_Errorscore_min);

    load(['RBM_sync_Beta',num2str(b),'Rep',num2str(rep)],'binned_accuracy_min','binned_Errorscore_min','sync_IM1','sync_IM2','S','LFC')
    ACC_sync(:,b,rep)=squeeze(binned_accuracy_min)*100;
    ERR_sync(:,b,rep)=squeeze(binned_Errorscore_min);
    Switcher(:,b,rep)=squeeze(S);
    synchronization_IM1(:,:,:,b,rep)=sync_IM1;
    synchronization_IM2(:,:,:,b,rep)=sync_IM2;
    if LFC(1,1)==1
        module(b,rep)=1;
    else
        module(b,rep)=2;
    end;

end;
end;

mean_ACC_conn=mean(ACC_conn,3);
mean_ERR_conn=mean(ERR_conn,3);
CI_ACC_conn=2*std(ACC_conn,0,3)./sqrt(rep);
CI_ERR_conn=2*std(ERR_conn,0,3)./sqrt(rep);
overall_ACC_conn=mean(mean_ACC_conn,1);
CI_all_acc_conn=(2*squeeze(std(mean(ACC_conn,1),0,3))./sqrt(Rep));

mean_ACC_sync=mean(ACC_sync,3);
mean_ERR_sync=mean(ERR_sync,3);
CI_ACC_sync=2*std(ACC_sync,0,3)./sqrt(rep);
CI_ERR_sync=2*std(ERR_sync,0,3)./sqrt(rep);
overall_ACC_sync=mean(mean_ACC_sync,1);
CI_all_acc_sync=(2*squeeze(std(mean(ACC_sync,1),0,3))./sqrt(Rep));

%determine critical moments
start=1:5;          %first 5 trials
end_one=15:19;      %last 5 trials before switch 1
Change_one=21:25;   %first 5 trials after switch 1
end_two=35:39;      %last 5 trials before switch 2
Change_two=41:45;   %first 5 trials after switch 2
final=56:60;        %last 5 trials

%compute mean accuracy for these moments
A=squeeze(mean(ACC_conn(end_one,:,:),1));
%A_2=squeeze(mean(avg_accuracy(end_one,:,:),1));
B=squeeze(mean(ACC_conn(Change_one,:,:),1));
%B_2=squeeze(mean(avg_accuracy(end_two,:,:),1));
C=squeeze(mean(ACC_conn(Change_two,:,:),1));
%C_2=squeeze(mean(avg_accuracy(final,:,:),1));

sync_A=squeeze(mean(ACC_sync(end_one,:,:),1));
sync_B=squeeze(mean(ACC_sync(Change_one,:,:),1));
sync_C=squeeze(mean(ACC_sync(Change_two,:,:),1));

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

