Time = 'both'; %'Rea' , 'both'
Dim = 'Where'; %'Where', 'both'

folder = ['/Volumes/backupdisc/Adaptive_control/' Time '_' Dim];

cd(folder)

Tr=600;
T=1250;
ITI=250;
Rep=30;
srate=500;

Con_id=NaN(Rep,Tr);
Accuracy=NaN(Rep,Tr);
RT=NaN(Rep,Tr);
Stim=NaN(Rep,Tr);
Response=NaN(Rep,Tr);

Sync_Relevant_Trial=NaN(Rep,Tr);
Sync_Irrelevant_Trial=NaN(Rep,Tr);
Sync_Relevant_ITI=NaN(Rep,Tr);
Sync_Irrelevant_ITI=NaN(Rep,Tr);
Power_Output=NaN(Rep,Tr);
Power_MFC_Trial=NaN(Rep,Tr);
Power_MFC_ITI=NaN(Rep,Tr);
MFC_all=NaN(Rep, T+1, Tr);

for i = 1:Rep
    load(['Stroop_' num2str(i)]);
    
    Relevant_act=squeeze(Phase(1:4,1,:,:));
    Irrelevant_act=squeeze(Phase(5:8,1,:,:));
    Output_act=squeeze(Phase(9:12,1,:,:));
    MFC_act=squeeze(MFC(1,:,:));
    MFC_all(i,:,:)=MFC_act;
    
    for trial=1:Tr
        Sync_Relevant_Trial(i,trial)=mean(mean(corr(squeeze(Relevant_act(:,ITI:ITI+Data(trial,6)/(1000/srate),trial))', squeeze(Output_act(:,ITI:ITI+Data(trial,6)/(1000/srate),trial))')));
        Sync_Irrelevant_Trial(i,trial)=mean(mean(corr(squeeze(Irrelevant_act(:,ITI:ITI+Data(trial,6)/(1000/srate),trial))', squeeze(Output_act(:,ITI:ITI+Data(trial,6)/(1000/srate),trial))')));
        Sync_Relevant_ITI(i,trial)=mean(mean(corr(squeeze(Relevant_act(:,1:ITI,trial))', squeeze(Output_act(:,1:ITI,trial))')));
        Sync_Irrelevant_ITI(i,trial)=mean(mean(corr(squeeze(Relevant_act(:,1:ITI,trial))', squeeze(Output_act(:,1:ITI,trial))')));
        Power_MFC_Trial(i,trial)=mean(abs(squeeze(MFC_act(ITI:ITI+Data(trial,6)/(1000/srate),trial))).^2);
        Power_MFC_ITI(i,trial)=mean(abs(squeeze(MFC_act(1:ITI,trial))).^2);
    end;
        
    Con_id(i,:)=Data(:,3);
    Accuracy(i,:)=Data(:,5);
    RT(i,:)=Data(:,6);
    Stim(i,:)=Data(:,2);
    Response(i,:)=Data(:,4);
end;

Data=NaN(Tr*Rep, 11);
Data(:,1)=repelem(1:Rep, 1, Tr)';
Data(:,2)=repmat(1:Tr,1,Rep)';
Data(:,3)=reshape(Stim',[],1);
Data(:,4)=reshape(Response',[],1);
Data(:,5)=reshape(Con_id',[],1);
Data(:,6)=reshape(Accuracy',[],1);
Data(:,7)=reshape(RT',[],1);
Data(:,8)=reshape(Power_MFC_Trial',[],1);
Data(:,9)=reshape(Power_MFC_ITI',[],1);
Data(:,10)=reshape(Sync_Relevant_Trial',[],1);
Data(:,11)=reshape(Sync_Irrelevant_Trial',[],1);
Data(:,12)=reshape(Sync_Relevant_ITI',[],1);
Data(:,13)=reshape(Sync_Irrelevant_ITI',[],1);

fid = fopen('Data_sim.txt','wt');
for i = 1:size(Data,1)
    fprintf(fid,'%g\t',Data(i,:));
    fprintf(fid,'\n');
end
fclose(fid)

save('extra_power_sim', 'Con_id', 'MFC_all', 'RT');

% In case you want already a first plot
%
% for i=1:Rep
%     MFC=squeeze(MFC_all(i,:,:));
%     MFC(:, RT(i,:)==2000)=NaN;
%     MFC(:,1)=[];
%     CC_id=((Con_id(i,2:Tr)==1)+(Con_id(i,1:Tr-1)==1))==2;
%     CIC_id=((Con_id(i,2:Tr)==0)+(Con_id(i,1:Tr-1)==1))==2;
%     ICC_id=((Con_id(i,2:Tr)==1)+(Con_id(i,1:Tr-1)==0))==2;
%     ICIC_id=((Con_id(i,2:Tr)==0)+(Con_id(i,1:Tr-1)==0))==2;
%     cc(i,:)=nanmean(10*log10(abs(MFC(:,CC_id==1)).^2),2);
%     cic(i,:)=nanmean(10*log10(abs(MFC(:,CIC_id==1)).^2),2);
%     icc(i,:)=nanmean(10*log10(abs(MFC(:,ICC_id==1)).^2),2);
%     icic(i,:)=nanmean(10*log10(abs(MFC(:,ICIC_id==1)).^2),2);
% end;
% 
% ccci=2*std(cc,0,1)./sqrt(30);
% ccmean=mean(cc,1);
% cicci=2*std(cic,0,1)./sqrt(30);
% cicmean=mean(cic,1);
% iccci=2*std(icc,0,1)./sqrt(30);
% iccmean=mean(icc,1);
% icicci=2*std(icic,0,1)./sqrt(30);
% icicmean=mean(icic,1);
% 
% current_c=(cc+icc)./2;
% current_c_mean=mean(current_c,1);
% current_c_ci=2*std(current_c,0,1)./sqrt(30);
% 
% current_ic=(cic+icic)./2;
% current_ic_mean=mean(current_ic,1);
% current_ic_ci=2*std(current_ic,0,1)./sqrt(30);
% 
% Previous_c=(cc+cic)./2;
% Previous_c_mean=mean(Previous_c,1);
% Previous_c_ci=2*std(Previous_c,0,1)./sqrt(30);
% 
% Previous_ic=(icc+icic)./2;
% Previous_ic_mean=mean(Previous_ic,1);
% Previous_ic_ci=2*std(Previous_ic,0,1)./sqrt(30);
% 
% y=-500:2:2000;
% 
% figure
% subplot(1,2,1)
% sc=patch([y, fliplr(y)],[current_ic_mean+current_ic_ci, fliplr(current_ic_mean-current_ic_ci)], 'r', 'LineStyle', 'none');
% hold on
% plot(y,current_ic_mean, 'r', 'LineWidth', 2)
% hold on
% %line([276,276],[-10,0], 'LineWidth', 2, 'LineStyle', '--', 'color', 'b')
% hold on
% sic=patch([y, fliplr(y)],[current_c_mean+current_c_ci, fliplr(current_c_mean-current_c_ci)], 'b', 'LineStyle','none');
% hold on
% plot(y,current_c_mean, 'b', 'LineWidth', 2)
% hold on
% %line([568,568],[-10,0], 'LineWidth', 2, 'LineStyle', '--', 'color', 'r')
% ylim([-10,-4])
% xlim([-400,1000])
% ylabel('Power (a.u.)')
% xlabel('Time (ms)')
% title('Congruency N')
% alpha(sc, 0.5)
% alpha(sic, 0.5)
% subplot(1,2,2)
% sc=patch([y, fliplr(y)],[Previous_ic_mean+Previous_ic_ci, fliplr(Previous_ic_mean-Previous_ic_ci)], 'r', 'LineStyle', 'none');
% hold on
% plot(y,Previous_ic_mean, 'r', 'LineWidth', 2)
% hold on
% %line([276,276],[-10,0], 'LineWidth', 2, 'LineStyle', '--', 'color', 'b')
% hold on
% sic=patch([y, fliplr(y)],[Previous_c_mean+Previous_ic_ci, fliplr(Previous_c_mean-Previous_c_ci)], 'b', 'LineStyle','none');
% hold on
% plot(y,Previous_c_mean, 'b', 'LineWidth', 2)
% hold on
% %line([568,568],[-10,0], 'LineWidth', 2, 'LineStyle', '--', 'color', 'r')
% ylim([-10,-4])
% xlim([-400,1000])
% ylabel('Power (a.u.)')
% xlabel('Time (ms)')
% title('Congruency N-1')
% alpha(sc, 0.5)
% alpha(sic, 0.5)