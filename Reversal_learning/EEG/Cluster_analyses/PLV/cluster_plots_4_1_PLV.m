Homefolder          ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
Datafolder          ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/PLV_data/';
figfolder           = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Figures/';

load([Homefolder 'chanloc.mat'])
chanlocations=chanlocations(1:64);

Data_actual_Positive=readtable('OverviewClustersFeedbackCutoff0.9915625Positive.txt');
Data_actual_Positive=table2array(Data_actual_Positive);

Data_actual_Negative=readtable('OverviewClustersFeedbackCutoff0.9915625Negative.txt');
Data_actual_Negative=table2array(Data_actual_Negative);

cluster1_actual_positive=Data_actual_Positive(:,2)==1;
cluster2_actual_positive=Data_actual_Positive(:,2)==2;

cluster3_actual_positive=Data_actual_Positive(:,2)==3;
cluster4_actual_positive=Data_actual_Positive(:,2)==4;

cluster1_actual_negative=Data_actual_Negative(:,2)==1;
cluster2_actual_negative=Data_actual_Negative(:,2)==2;

cluster1_pos=Data_actual_Positive(cluster1_actual_positive,:);
cluster2_pos=Data_actual_Positive(cluster2_actual_positive,:);
cluster3_pos=Data_actual_Positive(cluster3_actual_positive,:);
cluster4_pos=Data_actual_Positive(cluster4_actual_positive,:);
cluster1_neg=Data_actual_Negative(cluster1_actual_negative,:);
cluster2_neg=Data_actual_Negative(cluster2_actual_negative,:);

srate=512;
downsample_rate=5;
time_feedback=-500:1000/(srate/downsample_rate):1500; 
frex=logspace(log10(2), log10(48), 25);               %frequency vector for data
n_channels=64;                                        %number of channels
n_trials=480;                                         %number of trials

cluster_data=NaN(length(frex),n_channels,length(time_feedback),6);
for i=1:size(cluster1_neg,1)
    cluster_data(cluster1_neg(i,3),cluster1_neg(i,4),cluster1_neg(i,5),1)=cluster1_neg(i,6);
end;
delta_contra_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,1),2)));
delta_contra_channels=nansum(nansum(cluster_data(:,:,:,1),3),1)~=0;

for i=1:size(cluster2_neg,1)
    cluster_data(cluster2_neg(i,3),cluster2_neg(i,4),cluster2_neg(i,5),2)=cluster2_neg(i,6);
end;
delta_ipsi_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,2),2)));
delta_ipsi_channels=nansum(nansum(cluster_data(:,:,:,2),3),1)~=0;

for i=1:size(cluster1_pos,1)
    cluster_data(cluster1_pos(i,3),cluster1_pos(i,4),cluster1_pos(i,5),3)=cluster1_pos(i,6);
end;
theta_contra_contour1=isnan(squeeze(nanmean(cluster_data(:,:,:,3),2)));
theta_contra_channels1=nansum(nansum(cluster_data(:,:,:,3),3),1)~=0;

for i=1:size(cluster2_pos,1)
    cluster_data(cluster2_pos(i,3),cluster2_pos(i,4),cluster2_pos(i,5),4)=cluster2_pos(i,6);
end;
theta_ipsi_contour1=isnan(squeeze(nanmean(cluster_data(:,:,:,4),2)));
theta_ipsi_channels1=nansum(nansum(cluster_data(:,:,:,4),3),1)~=0;

for i=1:size(cluster3_pos,1)
    cluster_data(cluster3_pos(i,3),cluster3_pos(i,4),cluster3_pos(i,5),5)=cluster3_pos(i,6);
end;
theta_ipsi_contour2=isnan(squeeze(nanmean(cluster_data(:,:,:,5),2)));
theta_ipsi_channels2=nansum(nansum(cluster_data(:,:,:,5),3),1)~=0;

for i=1:size(cluster4_pos,1)
    cluster_data(cluster4_pos(i,3),cluster4_pos(i,4),cluster4_pos(i,5),6)=cluster4_pos(i,6);
end;
theta_contra_contour2=isnan(squeeze(nanmean(cluster_data(:,:,:,6),2)));
theta_contra_channels2=nansum(nansum(cluster_data(:,:,:,6),3),1)~=0;

cluster_data_all=squeeze(nansum(cluster_data,4));

th_contra= tabulate(cluster2_pos(:,4));
del_ipsi= tabulate(cluster1_neg(:,4));
th_ipsi= tabulate(cluster1_pos(:,4));
del_contra= tabulate(cluster2_neg(:,4));
th_contra2= tabulate(cluster3_pos(:,4));
th_ipsi2= tabulate(cluster4_pos(:,4));

[~, theta_contra_peakchannels]=sort(th_contra(:,2),'descend');
[~, theta_ipsi_peakchannels]=sort(th_ipsi(:,2),'descend');
[~, delta_ipsi_peakchannels]=sort(del_ipsi(:,2),'descend');
[~, delta_contra_peakchannels]=sort(del_contra(:,2),'descend');
[~, theta_contra_peakchannels2]=sort(th_contra2(:,2),'descend');
[~, theta_ipsi_peakchannels2]=sort(th_ipsi2(:,2),'descend');

th_ipsi=th_ipsi(theta_ipsi_peakchannels,1);
del_ipsi=del_ipsi(delta_ipsi_peakchannels,1);
th_contra=th_contra(theta_contra_peakchannels,1);
del_contra=del_contra(delta_contra_peakchannels,1);
th_ipsi2=th_ipsi2(theta_ipsi_peakchannels2,1);
th_contra2=th_contra2(theta_contra_peakchannels2,1);

figure(1)
clf
subplot(2,3,1)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,th_ipsi(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
title(['Significant clusters at a peak channel of ipsi theta cluster: ' chanlocations(th_ipsi(4)).labels])
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,3,4)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,th_contra(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
title(['Significant clusters at a peak channel of contra theta cluster: ' chanlocations(th_contra(4)).labels])
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,3,2)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,del_ipsi(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
title(['Significant clusters at a peak channel of ipsi delta cluster:' chanlocations(del_ipsi(2)).labels])
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,3,5)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,del_contra(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
title(['Significant clusters at a peak channel of contra delta cluster:' chanlocations(del_contra(1)).labels])
subplot(2,3,3)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,th_ipsi2(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
c=colorbar;
c.Label.String = 'Statistic';
title(['Significant clusters at a peak channel of ipsi theta cluster:' chanlocations(del_ipsi(2)).labels])
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,3,6)
contourf(time_feedback, frex, squeeze(cluster_data_all(:,th_contra2(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.05,0.05])
title(['Significant clusters at a peak channel of contra theta cluster:' chanlocations(del_contra(1)).labels])
c=colorbar;
c.Label.String = 'Statistic';
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 21,14])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'cluster_PLV_peakchannels'])
print([figfolder 'Cluster_PLV_peakchannels.png'],'-dpng','-r600')

load([Datafolder 'PLV_statistic'])

load([Homefolder 'chanloc'])
chanlocations=chanlocations(1:64);
[~, sortid_pf]=sort([chanlocations(:).X]);
right_channels=[chanlocations(:).Y]<-1;
left_channels=[chanlocations(:).Y]>1;
center_channels=(([chanlocations(:).Y]<1)+([chanlocations(:).Y]>-1))==2;

mean_statistic_ipsi=squeeze(nanmean(statistic(:,left_channels,:),2));
mean_statistic_contra=squeeze(nanmean(statistic(:,right_channels,:),2));

figure(2)
clf
subplot(2,1,1)
contourf(time_feedback, frex, mean_statistic_ipsi, 100  ,'LineStyle','none')
hold on
contour(time_feedback, frex, theta_ipsi_contour1, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, theta_ipsi_contour2, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, delta_ipsi_contour, [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000, 1500])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.075,0.075])
c=colorbar;
c.Label.String = 'Statistic';
title('Significant clusters averaged over ipsi-lateral channels')
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,1,2)
contourf(time_feedback, frex, mean_statistic_contra, 100  ,'LineStyle','none')
hold on
contour(time_feedback, frex, theta_contra_contour1, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, theta_contra_contour2, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, delta_contra_contour, [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000, 1500])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.075,0.075])
c=colorbar;
c.Label.String = 'Statistic';
title('Significant clusters averaged over contra-lateral channels')
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 21,14])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'cluster_PLV_average'])
print([figfolder 'cluster_PLV_average.png'],'-dpng','-r600')

addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b/')
eeglab

ch=1:64;

for c=1:64
data=squeeze(statistic(:,c,:));
topo1(c)=mean(data(theta_ipsi_contour1==0));
topo2(c)=mean(data(delta_ipsi_contour==0));
topo3(c)=mean(data(theta_contra_contour1==0));
topo4(c)=mean(data(delta_contra_contour==0));
topo5(c)=mean(data(theta_ipsi_contour2==0));
topo6(c)=mean(data(theta_contra_contour2==0));
end;

topo1(topo1==0)=NaN;
topo2(topo2==0)=NaN;
topo3(topo3==0)=NaN;
topo4(topo4==0)=NaN;
topo5(topo5==0)=NaN;
topo6(topo6==0)=NaN;

figure(6)
clf;
subplot(2,1,2)
topoplot((topo2+topo4)./2,chanlocations, 'electrodes', 'off','emarker2', {ch(delta_ipsi_channels), 'x','k',5,3})
hold on
topoplot((topo2+topo4)./2,chanlocations, 'electrodes', 'off','emarker2', {ch(delta_contra_channels), 'o','k',5,1})
title('Delta cluster');
colormap jet
caxis([-0.1,0.1])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(2,1,1)
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_ipsi_channels1), 'x','k',5,3})
hold on
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_contra_channels1), 'o','k',5,1})
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_contra_channels2), 'o','w',5,1})
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_ipsi_channels2), 'x','w',5,3})
title('Theta cluster');
colormap jet
caxis([-0.1,0.1])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',10, 'Fontname', 'Times')
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 14,14])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'topo_PLV_clusters'])
print([figfolder 'topo_PLV_clusters.png'],'-dpng','-r600')

figure(10)
clf
subplot(2,6,1:3)
contourf(time_feedback, frex, mean_statistic_ipsi, 100  ,'LineStyle','none')
hold on
contour(time_feedback, frex, theta_ipsi_contour1, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, theta_ipsi_contour2, [1,1], 'LineWidth', 2, 'color', 'w')
contour(time_feedback, frex, delta_ipsi_contour, [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('Time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.075,0.075])
c=colorbar;
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
c.Label.String = 'Statistic';
title('A: Ipsi-lateral (Neg - Pos feedback)')
subplot(2,6,7:9)
contourf(time_feedback, frex, mean_statistic_contra, 100  ,'LineStyle','none')
hold on
contour(time_feedback, frex, theta_contra_contour1, [1,1], 'LineWidth', 2, 'color', 'k')
contour(time_feedback, frex, theta_contra_contour2, [1,1], 'LineWidth', 2, 'color', 'w')
contour(time_feedback, frex, delta_contra_contour, [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000, 1500])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.075,0.075])
c=colorbar;
c.Label.String = 'Statistic';
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
title('B: Contra-lateral (Neg - Pos feedback)')
subplot(3,6,4:6)
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_ipsi_channels1), 'x','k',3,1})
hold on
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_contra_channels1), 'o','k',2,1})
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_contra_channels2), 'o','w',2,1})
topoplot((topo1+topo3+topo5+topo6)./4,chanlocations,'electrodes', 'off', 'emarker2', {ch(theta_ipsi_channels2), 'x','w',3,1})
title('C: Theta cluster');
colormap jet
caxis([-0.1,0.1])
c=colorbar;
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
c.Label.String = 'Statistic';
set(gca, 'FontSize',10, 'Fontname', 'Times')
subplot(3,6,10:12)
topoplot((topo2+topo4)./2,chanlocations, 'electrodes', 'off','emarker2', {ch(delta_ipsi_channels), 'x','k',3,1})
hold on
topoplot((topo2+topo4)./2,chanlocations, 'electrodes', 'off','emarker2', {ch(delta_contra_channels), 'o','k',2,1})
title('D: Delta cluster');
colormap jet
caxis([-0.1,0.1])
c=colorbar;
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
c.Label.String = 'Statistic';
load([Datafolder, 'paperdat'])
subplot(3,6,17:18)
bar([mean_plv_neg, mean_plv_pos],'r')
hold on
errorbar([mean_plv_neg, mean_plv_pos], [ci_plv_neg, ci_plv_pos],'color','k', 'LineWidth',2, 'LineStyle', 'none')
xlim([0.5,3])
ylim([0,0.6])
xticklabels({'Neg.', 'Pos.'})
xlabel('Feedback')
ylabel('PLV')
set(gca, 'YAxisLocation','right')
title('E: Model data');
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 11.6,8])
set(findall(gcf,'-property','FontSize'),'FontSize',8)
set(findall(gcf,'-property','Fontname'),'Fontname','Times')
savefig([figfolder 'paper_contrast_PLV'])
print([figfolder 'paper_contrast_PLV.tiff'],'-dtiff','-r300')
