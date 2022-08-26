% Define folders and variables
Homefolder='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
Datafolder='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);               %number of subjects

srate=512;
downsample_rate=10;
time_feedback=-1000:1000/srate:2500; 
index_feedback=((time_feedback>=-500)+(time_feedback<=2000))==2;
new_srate=srate/downsample_rate;
new_feedback_time=-500:1000/new_srate:2000;
frex=logspace(log10(2), log10(48), 25);               %frequency vector for data
n_channels=64;                                        %number of channels
n_trials=480;                                         %number of trials

%load channel locations
load([Homefolder 'chanloc.mat'])
chanlocations=chanlocations(1:n_channels);

Data_actual_Positive=readtable([Datafolder 'OverviewClustersFeedbackCutoff0.99Positive.txt']);
Data_actual_Positive=table2array(Data_actual_Positive);

Data_actual_Negative=readtable([Datafolder 'OverviewClustersFeedbackCutoff0.99Negative.txt']);
Data_actual_Negative=table2array(Data_actual_Negative);

cluster_actual_positive=Data_actual_Positive(:,2)==1;

cluster1_actual_negative=Data_actual_Negative(:,2)==1;
cluster2_actual_negative=Data_actual_Negative(:,2)==2;

cluster_theta=Data_actual_Positive(cluster_actual_positive,:);
cluster_delta=Data_actual_Negative(cluster1_actual_negative,:);
cluster_alpha=Data_actual_Negative(cluster2_actual_negative,:);

theta_cluster_power=zeros(num_subjects,n_trials);
delta_cluster_power=zeros(num_subjects,n_trials);
alpha_cluster_power=zeros(num_subjects,n_trials);

for s=1:num_subjects
    subject         = subject_list{s};
    %% load data
    fprintf('\n *** Loading stimulus-locked data ***\n')
    % load power data
    load(['power_FBlock', subject],'baselined_power');
    
    fprintf('\n *** converting ***\n')
    baselined_power=baselined_power(:,:,index_feedback,:);
    baselined_power=baselined_power(:,:,1:downsample_rate:end,:);
    
    Theta=NaN(length(frex), n_channels, length(new_feedback_time), n_trials);
    for i=1:size(cluster_theta,1)
        Theta(cluster_theta(i,3), cluster_theta(i,5), cluster_theta(i,4),:)=baselined_power(cluster_theta(i,3), cluster_theta(i,5), cluster_theta(i,4),:);
    end;
    
    Delta=NaN(length(frex), n_channels, length(new_feedback_time), n_trials);
    for i=1:size(cluster_delta,1)
        Delta(cluster_delta(i,3), cluster_delta(i,5), cluster_delta(i,4),:)=baselined_power(cluster_delta(i,3), cluster_delta(i,5), cluster_delta(i,4),:);
    end;
    
    Alpha=NaN(length(frex), n_channels, length(new_feedback_time), n_trials);
    for i=1:size(cluster_alpha,1)
        Alpha(cluster_alpha(i,3), cluster_alpha(i,5), cluster_alpha(i,4),:)=baselined_power(cluster_alpha(i,3), cluster_alpha(i,5), cluster_alpha(i,4),:);
    end;
    
    theta_cluster_power(subject,:)=nanmean(nanmean(nanmean(Theta,3),2),1);
    delta_cluster_power(subject,:)=nanmean(nanmean(nanmean(Delta,3),2),1);
    alpha_cluster_power(subject,:)=nanmean(nanmean(nanmean(Alpha,3),2),1);
    
end;
save([Datafolder 'cluster_power'],'theta_cluster_power', 'delta_cluster_power', 'alpha_cluster_power','-v7.3');
