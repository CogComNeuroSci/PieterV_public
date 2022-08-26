subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);

cd '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/TF_data/';

fprintf('\n*** Ready for loop ***\n')
for s=1:num_subjects
    subject         = subject_list{s};
    
    %% stimulus-locked data
    fprintf('\n *** Loading data *** \n')
    
    %combine frontal and posterior data
    load(['tf_stimulus_',subject],'tf_dat_frontal')
    to_keep(:,1:32,:,:)=tf_dat_frontal(:,:,:,:);
    clear tf_dat_frontal;
    load(['tf_stimulus_',subject],'tf_dat_posterior')
    to_keep(:,33:64,:,:)=tf_dat_posterior(:,:,:,:);
    clear tf_dat_posterior;
    
    fprintf(['\n *** Loaded stimulus data of ' subject ' *** \n'])

    %get phase
    phase = angle(to_keep);
    fprintf('\n *** Saving stimulus-locked phase *** \n')
    save(['phase_Slock', subject], 'phase','-v7.3');
    clear phase
    
    %get power
    power=abs(to_keep).^2;
    load(['tf_baseline_', subject]);
    
    %baseline power data
    fprintf('\n *** Baselining ***\n') 
    baselined_power=zeros(size(power));
    for f=1:25
        for channel=1:64
            baselined_power(f,channel,:,:)=power(f,channel,:,:)./baseline(f,channel);
        end;
    end;
    
    fprintf('\n *** Saving stimulus-locked power *** \n')
    save(['power_Slock', subject], 'baselined_power','-v7.3');
    clear baselined_power
    
    %% feedback-locked data
    fprintf('\n *** Loading data *** \n')
    
    %combine frontal and posterior data
    load(['tf_feedback_',subject],'tf_dat_frontal')
    to_keep(:,1:32,:,:)=tf_dat_frontal(:,:,:,:);
    clear tf_dat_frontal;
    load(['tf_feedback_',subject],'tf_dat_posterior')
    to_keep(:,33:64,:,:)=tf_dat_posterior(:,:,:,:);
    clear tf_dat_posterior;
    
    fprintf(['\n *** Loaded feedback data of ' subject ' *** \n'])

    %get phase
    phase = angle(to_keep);
    fprintf('\n *** Saving feedback-locked phase *** \n')
    save(['phase_FBlock', subject], 'phase','-v7.3');
    clear phase
    
    %get power
    power=abs(to_keep).^2;
    
    %baseline power data
    fprintf('\n baselining\n') 
    baselined_power=zeros(size(power));
    for f=1:25
        for channel=1:64
            baselined_power(f,channel,:,:)=power(f,channel,:,:)./baseline(f,channel);
        end;
    end;
    clear baseline
    
    fprintf('\n *** Saving feedback-locked power *** \n')
    save(['power_FBlock', subject], 'baselined_power','-v7.3');
    clear baselined_power
end;
