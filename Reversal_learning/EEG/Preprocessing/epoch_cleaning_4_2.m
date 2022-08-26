function epoch_cleaning
channels_to_check=[3:7,9:14,17:32,36:42,44:51,54:64]; % we do not check channels close to ear or eyes 
Ntrials=480;

addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab 

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);                                             % n
parentfolder    = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Epoched_files/';               % folder that holds all data

newfolder       = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cleaned_files/';     

load([newfolder 'Rejections'])
rejection_array_F=zeros(num_subjects,Ntrials);
rejection_array_S=zeros(num_subjects,Ntrials);

for s = 1: num_subjects
    % set subject and subjectfolder to subject s in the loop
    subject         = subject_list{s};                      % extract subject from subject array
    fprintf('\n\n\n***subject %d: %s***\n\n\n',s,subject);  % print what subject is being processed in command window
    
    %% First for feedback-locked epochs
    % load data set 
    EEG =   pop_loadset('filename', [subject '_epochedF.set'], 'filepath', parentfolder);
    
    % These are the thresholds that we apply for identifying bad epochs.
    % This is based on Makoto's preprocessing pipeline
    EEG = pop_jointprob(EEG,1,channels_to_check ,6,2,0,0,0,[],0);
    EEG = pop_eegthresh(EEG,1,channels_to_check ,-500,500,-1,2.999,2,0);
    
    % keep track of which trials were rejected
    rejection_array_F(s,:)=EEG.reject.rejthresh+EEG.reject.rejjp;
    ind=rejection_array_F(s,:)>1;
    if sum(ind)>0
        rejection_array_F(s,ind)=1;
        clear ind
    end;
    
    %Delete trials
    EEG.data(:,:,logical(rejection_array_F(s,:)))=NaN(EEG.nbchan, EEG.pnts, sum(rejection_array_F(s,:)));
    %Save data
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', ['Cleaned_' subject '_F.set'], 'filepath', newfolder);
    
    %% Now for the stimulus-locked epochs
    % load data set 
    EEG =   pop_loadset('filename', [subject '_epochedS.set'], 'filepath', parentfolder);
    
    % These are the thresholds that we apply for identifying bad epochs.
    % This is based on Makoto's preprocessing pipeline
    EEG = pop_jointprob(EEG,1,channels_to_check ,6,2,0,0,0,[],0);
    EEG = pop_eegthresh(EEG,1,channels_to_check ,-500,500,-1,2.999,2,0);
    
    % keep track of which trials were rejected
    rejection_array_S(s,:)=EEG.reject.rejthresh+EEG.reject.rejjp;
    ind=rejection_array_S(s,:)>1;
    if sum(ind)>0
        rejection_array_S(s,ind)=1;
        clear ind
    end;
    %Delete trials
    EEG.data(:,:,logical(rejection_array_S(s,:)))=NaN(EEG.nbchan, EEG.pnts, sum(rejection_array_S(s,:)));
    %Save data
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', ['Cleaned_' subject '_S.set'], 'filepath', newfolder);
            
end;
total_rejections_S=sum(rejection_array_S,2);
total_rejections_F=sum(rejection_array_F,2);

rejection_rate_S=(total_rejections_S./Ntrials)*100;
rejection_rate_F=(total_rejections_F./Ntrials)*100;

save([newfolder 'Rejections'],'rejection_array_S','rejection_array_F', 'rejection_rate_S', 'rejection_rate_F')
return
