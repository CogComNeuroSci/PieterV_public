% Define subjects and folders
subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);   

indicesfolder         = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

load([indicesfolder 'Indices'])

% We eliminate some datapoints for clustering: further downsampling and
% cutting edges of data.
srate=512;
downsample_rate=10;
time_feedback=-1000:1000/srate:2500;                           
time_stimulus=-2000:1000/srate:1500;                            
index_feedback=((time_feedback>=-500)+(time_feedback<=2000))==2;
index_stimulus=time_stimulus>=-1000;
% Get new sampling rate and times
new_srate=srate/downsample_rate;                                
new_feedback_time=-500:1000/new_srate:2000;                 
new_stimulus_time=-1000:1000/new_srate:1500;

n_trials=480;                                         %number of trials

clear srate time_feedback time_stimulus new_srate frex n_channels 

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/TF_data/';

% In case you are interested in stimulus locked activity
% Power_tocluster=NaN(length(frex),n_channels,length(new_stimulus_time),n_trials*num_subjects);
% for s=1:num_subjects
%     subject         = subject_list{s};
% 
%     %% load stimulus data
%     fprintf('\n *** Loading stimulus-locked data ***\n')
%     % load power data
%     load(['power_Slock', subject],'baselined_power');
% 
%     fprintf('\n *** converting ***\n')
%     baselined_power=baselined_power(:,:,index_stimulus,:);
%     baselined_power=baselined_power(:,:,1:downsample_rate:end,:);
%     
%     baselined_power(:,:,:,lateRT_indices(:,s))=NaN(size(baselined_power,1),size(baselined_power,2),size(baselined_power,3),sum(lateRT_indices(s,:)));
% 
%     m=nanmean(baselined_power,4);
%     std=nanstd(baselined_power,0,4);
% 
%     baselined_power=(baselined_power-m)./std;
% 
%     Power_tocluster(:,:,:,((s-1)*n_trials)+1:s*n_trials)=baselined_power;
%     clear baselined_power
% 
% end;
% fprintf('\n *** Saving stimulus-locked data ***\n')
% save('Stim_cluster_raw', 'Power_tocluster','-v7.3')
% clear Power_tocluster

Power_tocluster=NaN(length(frex),n_channels,length(new_feedback_time),n_trials*num_subjects);

for s=1:num_subjects
    subject         = subject_list{s};

    %% load feedback data
    fprintf('\n *** Loading feedback-locked data ***\n')
    % load power data
    load(['power_FBlock', subject],'baselined_power');

    fprintf('\n *** converting ***\n')
    baselined_power=baselined_power(:,:,index_feedback,:);
    baselined_power=baselined_power(:,:,1:downsample_rate:end,:);
    
    %Remove trials with too late responses for analyses
    baselined_power(:,:,:,lateRT_indices(:,s))=NaN(size(baselined_power,1),size(baselined_power,2),size(baselined_power,3),sum(lateRT_indices(s,:)));

    m=nanmean(baselined_power,4);
    std=nanstd(baselined_power,0,4);

    baselined_power=(baselined_power-m)./std;
    
    %make one matrix ignoring subject dimension
    Power_tocluster(:,:,:,((s-1)*n_trials)+1:s*n_trials)=baselined_power;
    
    clear baselined_power
end;
fprintf('\n *** Saving feedback-locked data ***\n')
cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';
save('FB_cluster_raw', 'Power_tocluster','-v7.3')
