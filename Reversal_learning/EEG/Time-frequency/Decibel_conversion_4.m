subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);    

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/TF_data/';

for s=1:num_subjects
    subject         = subject_list{s};
    %% load stimulus data
    fprintf('\n *** Loading stimulus-locked data ***\n')
    % load power data
    load(['power_Slock', subject],'baselined_power');
    baselined_power=10.*log10(baselined_power);
    save(['power_Slock', subject],'baselined_power');
    
    % load power data
    load(['power_FBlock', subject],'baselined_power');
    baselined_power=10.*log10(baselined_power);
    save(['power_FBlock', subject],'baselined_power');
end;
