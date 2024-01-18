% Define folders and variables
Homefolder          ='/Volumes/Harde ploate/catastrophic forgetting/EEG_reversal_learning/EEG_data/';
Datafolder          ='/Volumes/Harde ploate/catastrophic forgetting/EEG_reversal_learning/EEG_data/Cluster_data/';
figfolder           = '/Volumes/Harde ploate/catastrophic forgetting/EEG_reversal_learning/EEG_data/Figures/Power_Cluster';

%load channel locations
load([Homefolder 'chanloc.mat'])
chanlocations=chanlocations(1:64);

%load cluster data and extract cluster coordinates in
%time-frequency-channel space
Data_actual_Negative=readtable([Datafolder 'OverviewClustersFeedbackCutoff_bis0.99Negative.txt']);
Data_actual_Negative=table2array(Data_actual_Negative);

Data_actual_Positive=readtable([Datafolder 'OverviewClustersFeedbackCutoff_bis0.99Positive.txt']);
Data_actual_Positive=table2array(Data_actual_Positive);

cluster1_actual_negative=Data_actual_Negative(:,2)==1;
cluster2_actual_negative=Data_actual_Negative(:,2)==2;
cluster3_actual_negative=Data_actual_Negative(:,2)==3;

cluster1_actual_positive=Data_actual_Positive(:,2)==1;

cluster1_pos=Data_actual_Positive(cluster1_actual_positive,:);

cluster1_neg=Data_actual_Negative(cluster1_actual_negative,:);
cluster2_neg=Data_actual_Negative(cluster2_actual_negative,:);
cluster3_neg=Data_actual_Negative(cluster3_actual_negative,:);

%define time and frequency variables
srate=512;
downsample_rate=10;
time_feedback=-1000:1000/srate:2500; 
time_stimulus=-2000:1000/srate:1500;
index_feedback=((time_feedback>=-500)+(time_feedback<=2000))==2;
index_stimulus=time_stimulus>=-1000;
new_srate=srate/downsample_rate;
new_feedback_time=-500:1000/new_srate:2000;
new_stimulus_time=-1000:1000/new_srate:1500;
frex=logspace(log10(2), log10(48), 25);               %frequency vector for data
n_channels=64;                                        %number of channels
n_trials=480;                                         %number of trials

%get power within the cluster as well as edges in time-frequency and in
%channel domain
cluster_data=NaN(length(frex),n_channels,length(new_feedback_time),3);
for i=1:size(cluster1_pos,1)
    cluster_data(cluster1_pos(i,3),cluster1_pos(i,4),cluster1_pos(i,5),1)=cluster1_pos(i,6);
end;
theta_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,1),2)));
theta_channels=nansum(nansum(cluster_data(:,:,:,1),3),1)~=0;

for i=1:size(cluster1_neg,1)
    cluster_data(cluster1_neg(i,3),cluster1_neg(i,4),cluster1_neg(i,5),2)=cluster1_neg(i,6);
end;
delta_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,2),2)));
delta_channels=nansum(nansum(cluster_data(:,:,:,2),3),1)~=0;

for i=1:size(cluster2_neg,1)
    cluster_data(cluster2_neg(i,3),cluster2_neg(i,4),cluster2_neg(i,5),3)=cluster2_neg(i,6);
end;
alpha_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,3),2)));
alpha_channels=nansum(nansum(cluster_data(:,:,:,3),3),1)~=0;

%This makes one matrix with nans for non-clustered data and power for
%clustered data
cluster_data=squeeze(nansum(cluster_data,4));

%tabulate cluster data and extract peak channels
th= tabulate(cluster1_pos(:,4));
del= tabulate(cluster1_neg(:,4));
al= tabulate(cluster2_neg(:,4));

[~, theta_peakchannels]=sort(th(:,2),'descend');
[~, delta_peakchannels]=sort(del(:,2),'descend');
[~, alpha_peakchannels]=sort(al(:,2),'descend');

th=th(theta_peakchannels,1);
del=del(delta_peakchannels,1);
al=al(alpha_peakchannels,1);

%make figures
figure(1)
clf
subplot(1,2,1)
contourf(new_feedback_time, frex, squeeze(cluster_data(:,th(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.4,0.4])
title(['Significant clusters at a peak channel of theta cluster:' chanlocations(th(6)).labels])
subplot(1,2,2)
contourf(new_feedback_time, frex, squeeze(cluster_data(:,al(2),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.4,0.4])
c=colorbar;
c.Label.String = 'Statistic';
title(['Significant clusters at a peak channel of alpha and delta cluster:' chanlocations(al(2)).labels])
set(gcf, 'color', 'w')
savefig([figfolder 'cluster_tf_peakchannels'])

load([Datafolder 'FB_cluster_statistic'])
mean_statistic_data=squeeze(nanmean(statistic,2));

figure(2)
clf
contourf(new_feedback_time, frex, mean_statistic_data, 100  ,'LineStyle','none')
hold on
contour(new_feedback_time, frex, theta_contour, [1,1], 'LineWidth', 2, 'color', 'k')
contour(new_feedback_time, frex, delta_contour, [1,1], 'LineWidth', 2,'color', 'k')
contour(new_feedback_time, frex, alpha_contour, [1,1], 'LineWidth', 2, 'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000, 1500])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.25,0.25])
c=colorbar;
c.Label.String = 'Statistic';
title('Significant clusters averaged over channels')
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 12,4])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'cluster_tf_average'])
print([figfolder 'cluster_tf_average.png'],'-dpng','-r600')

addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b/')
eeglab

for c=1:64
data=squeeze(statistic(:,c,:));
topo1(c)=mean(data(theta_contour==0));
topo2(c)=mean(data(delta_contour==0));
topo3(c)=mean(data(alpha_contour==0));
end;

ch=1:64;

figure(6)
clf;
subplot(3,1,1)
topoplot(topo1,chanlocations, 'electrodes', 'off','emarker2', {ch(theta_channels), 'x','k',5,3})
title('Theta cluster');
colormap jet
caxis([0.1,0.5])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(3,1,2)
topoplot(topo3,chanlocations,'electrodes', 'off', 'emarker2', {ch(alpha_channels), 'x','k',5,3})
title('Alpha cluster');
colormap jet
caxis([-0.2,0])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(3,1,3)
topoplot(topo2,chanlocations,'electrodes', 'off', 'emarker2', {ch(delta_channels), 'x','k',5,3})
title('Delta cluster');
colormap jet
caxis([-0.3,-0.1])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',8, 'Fontname', 'Times')
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 7,21])
savefig([figfolder 'topo_clusters'])
print([figfolder 'topo_clusters.png'],'-dpng','-r600')

figure(10)
subplot(2,6,[7:9])
contourf(new_feedback_time(1:104), frex, mean_statistic_data(:,1:104), 100  ,'LineStyle','none')
hold on
contour(new_feedback_time(1:104), frex, theta_contour(:,1:104), [1,1], 'LineWidth', 2, 'color', 'k')
contour(new_feedback_time(1:104), frex, delta_contour(:,1:104), [1,1], 'LineWidth', 2,'color', 'k')
contour(new_feedback_time(1:104), frex, alpha_contour(:,1:104), [1,1], 'LineWidth', 2, 'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('Time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.3,0.3])
c=colorbar;
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
c.Label.String = 'Statistic';
title('B: Data (Neg. - Pos. Feedback)')
%set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(3,6,4:6)
topoplot(topo3,chanlocations,'electrodes', 'off', 'emarker2', {ch(alpha_channels), 'x','k',3,1})
title('C: Alpha cluster');
colormap jet
caxis([-0.3,0.3])
c=colorbar;
c.Label.String = 'Statistic';
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
%set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(3,6,10:12)
topoplot(topo1,chanlocations, 'electrodes', 'off','emarker2', {ch(theta_channels), 'x','k',3,1})
title('D: Theta cluster');
colormap jet
caxis([-0.5,0.5])
c=colorbar;
c.Label.String = 'Statistic';
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
%set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(3,6,16:18)
topoplot(topo2,chanlocations,'electrodes', 'off', 'emarker2', {ch(delta_channels), 'x','k',3,1})
title('E: Delta cluster');
colormap jet
caxis([-0.3,0.3])
c=colorbar;
c.Label.String = 'Statistic';
b=c.Position;
set(c,'Position',[b(1)+0.075, b(2), 0.025, b(4)])
%set(gca, 'FontSize',8, 'Fontname', 'Times')
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 12, 8])
set(findall(gcf,'-property','FontSize'),'FontSize',8)
set(findall(gcf,'-property','Fontname'),'Fontname','Times')
savefig([figfolder 'paper_contrast'])
print([figfolder 'paper_contrast.tiff'],'-dtiff','-r300')
