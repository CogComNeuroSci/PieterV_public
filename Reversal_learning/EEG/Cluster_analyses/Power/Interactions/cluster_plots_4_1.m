Homefolder          ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
Datafolder          ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';
figfolder           = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Figures/Power_Cluster/';
indicesfolder   = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

load([Homefolder 'chanloc.mat'])
chanlocations=chanlocations(1:64);

load([indicesfolder 'PE_data'])
histogram(PE,'Normalization','probability')
[f,xi] = ksdensity(PE);
hold on
plot(xi,f)

Data_actual_Negative=readtable([Datafolder 'OverviewClustersFeedbackCutoff0.99Negative_PE.txt']);
Data_actual_Negative=table2array(Data_actual_Negative);

Data_actual_Positive=readtable([Datafolder 'OverviewClustersFeedbackCutoff0.99Positive_PE.txt']);
Data_actual_Positive=table2array(Data_actual_Positive);

cluster1_actual_negative=Data_actual_Negative(:,2)==1;

cluster1_actual_positive=Data_actual_Positive(:,2)==1;

cluster1_pos=Data_actual_Positive(cluster1_actual_positive,:);

cluster1_neg=Data_actual_Negative(cluster1_actual_negative,:);

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

cluster_data=NaN(length(frex),n_channels,length(new_feedback_time),2);
for i=1:size(cluster1_neg,1)
    cluster_data(cluster1_neg(i,3),cluster1_neg(i,4),cluster1_neg(i,5),1)=cluster1_neg(i,6);
end;
alpha_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,1),2)));
alpha_channels=nansum(nansum(cluster_data(:,:,:,1),3),1)~=0;

for i=1:size(cluster1_pos,1)
    cluster_data(cluster1_pos(i,3),cluster1_pos(i,4),cluster1_pos(i,5),2)=cluster1_pos(i,6);
end;
delta_contour=isnan(squeeze(nanmean(cluster_data(:,:,:,2),2)));
delta_channels=nansum(nansum(cluster_data(:,:,:,2),3),1)~=0;

cluster_data=squeeze(nansum(cluster_data,4));

th= tabulate(cluster1_neg(:,4));
del= tabulate(cluster1_pos(:,4));

[~, theta_peakchannels]=sort(th(:,2),'descend');
[~, delta_peakchannels]=sort(del(:,2),'descend');

th=th(theta_peakchannels,1);
del=del(delta_peakchannels,1);

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
caxis([-0.2,0.2])
title(['Significant clusters at a peak channel of theta cluster:' chanlocations(th(6)).labels])
subplot(1,2,2)
contourf(new_feedback_time, frex, squeeze(cluster_data(:,del(1),:)),100 ,'LineStyle','none')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.2,0.2])
c=colorbar;
c.Label.String = 'Statistic';
title(['Significant clusters at a peak channel of alpha and delta cluster:' chanlocations(del(2)).labels])
set(gcf, 'color', 'w')
savefig([figfolder 'cluster_tf_peakchannels_PE'])

%load([Datafolder 'FB_cluster_statistic_PE'])
load([Datafolder 'cluster_statistic_interaction'])
statistic=statistic_all;
mean_statistic_data=squeeze(nanmean(statistic_all,2));

figure(2)
clf
contourf(new_feedback_time, frex, mean_statistic_data, 100  ,'LineStyle','none')
hold on
contour(new_feedback_time, frex, alpha_contour, [1,1], 'LineWidth', 2, 'color', 'k')
contour(new_feedback_time, frex, delta_contour, [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000, 1500])
yticks([2, 5, 10, 20, 40])
xlabel('time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.1,0.1])
c=colorbar;
c.Label.String = 'Statistic';
title('Significant clusters averaged over channels')
set(gcf, 'color', 'w')
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 12,4])
set(gca, 'FontSize',10, 'Fontname', 'Times')
savefig([figfolder 'cluster_tf_average_PE'])
print([figfolder 'cluster_tf_average_PE.png'],'-dpng','-r600')

addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b/')
eeglab

for c=1:64
data=squeeze(statistic(:,c,:));
topo1(c)=mean(data(alpha_contour==0));
topo2(c)=mean(data(delta_contour==0));
end;

ch=1:64;

figure(6)
clf;
subplot(2,1,1)
topoplot(topo1,chanlocations, 'electrodes', 'off','emarker2', {ch(alpha_channels), 'x','k',5,3})
title('Theta cluster');
colormap jet
caxis([-0.1,0])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(2,1,2)
topoplot(topo2,chanlocations,'electrodes', 'off', 'emarker2', {ch(delta_channels), 'x','k',5,3})
title('Delta cluster');
colormap jet
caxis([0,0.1])
c=colorbar;
c.Label.String = 'Statistic';
set(gca, 'FontSize',8, 'Fontname', 'Times')
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 7,21])
savefig([figfolder 'topo_clusters_PE'])
print([figfolder 'topo_clusters_PE.png'],'-dpng','-r600')

figure(10)
clf
subplot(2,2,1)
area(xi,f, 'LineStyle', 'none', 'FaceColor', 'b')
box off
xlim([-1,1])
xticks([-1, -.5, 0, .5, 1])
yticks([])
xlabel('PE estimate')
ylabel('Density')
title('A: PE distribution')
subplot(2,2,2)
contourf(new_feedback_time(1:104), frex, mean_statistic_data(:,1:104), 100  ,'LineStyle','none')
hold on
contour(new_feedback_time(1:104), frex, alpha_contour(:,1:104), [1,1], 'LineWidth', 2, 'color', 'k')
contour(new_feedback_time(1:104), frex, delta_contour(:,1:104), [1,1], 'LineWidth', 2,'color', 'k')
colormap jet
set(gca, 'YScale', 'log')
xticks([-500,0,500,1000])
yticks([2, 5, 10, 20, 40])
xlabel('Time (ms)')
ylabel('Frequency (Hz)')
caxis([-0.1,0.1])
c=colorbar;
b=c.Position;
%set(c,'Position',[b(1), b(2), 0.02, b(4)])
c.Label.String = 'Interaction contrast';
title('B: Time-Frequency')
%set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(2,2,3)
topoplot(topo1,chanlocations, 'electrodes', 'off','emarker2', {ch(alpha_channels), 'x','k',3,1})
title('C: Alpha cluster');
colormap jet
caxis([-0.15,0.15])
c=colorbar;
c.Label.String = 'Interaction contrast';
b=c.Position;
set(c,'Position',[b(1)+0.04, b(2), 0.02, b(4)])
%set(gca, 'FontSize',8, 'Fontname', 'Times')
subplot(2,2,4)
topoplot(topo2,chanlocations,'electrodes', 'off', 'emarker2', {ch(delta_channels), 'x','k',3,1})
title('D: Theta-Delta cluster');
colormap jet
caxis([-0.15,0.15])
c=colorbar;
c.Label.String = 'Interaction contrast';
b=c.Position;
set(c,'Position',[b(1)+0.04, b(2), 0.02, b(4)])
%set(gca, 'FontSize',8, 'Fontname', 'Times')
set(gcf, 'color', 'w');
set(gcf, 'PaperUnits', 'centimeters', 'PaperPosition', [0,0, 12, 8])
set(findall(gcf,'-property','FontSize'),'FontSize',8)
set(findall(gcf,'-property','Fontname'),'Fontname','Times')
savefig([figfolder 'Interaction_TF'])
print([figfolder 'Interaction_TF.tiff'],'-dtiff','-r300')
print(['/Users/pieter/Desktop/Interaction_TF.png'],'-dpng','-r300')