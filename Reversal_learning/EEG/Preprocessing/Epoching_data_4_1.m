function Epoching_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%                   Epoching:                   %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab                                                                              % open eeglab because otherwise the script gets stuck because some functions can't be found

subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'}; % leave p6, p9 and p16 out for now
num_subjects    = length(subject_list);                                             % n
parentfolder    = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/ICA_files';
newfolder       = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Epoched_files';           % folder that will hold all original sets
eventlists      = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Event_lists';

%% Loop for all subjects
for s = 1:num_subjects
    % set subject and subjectfolder to subject s in the loop
    subject         = subject_list{s};                      % extract subject from subject array
    fprintf('\n\n\n***subject %d: %s***\n\n\n',s,subject);  % print what subject is being processed in command window
    
    %% Epoch on stimulus
    % load data set 
    EEG =   pop_loadset('filename', [subject '_ICAremoved.set'], 'filepath', parentfolder);

    % create eventlist
    EEG =   pop_creabasiceventlist(EEG, 'AlphanumericCleaning', 'on', 'Eventlist', [eventlists subject '_eventlist.txt'],...
                                        'Newboundary', {-99}, 'Stringboundary', {'boundary'}, 'Warning', 'off');
    
    % 50 and 51 are stimulus triggers
    EEG = pop_epoch( EEG, {  '50'  '51'  }, [-2  3], 'newname', 'epoched', 'epochinfo', 'yes');
    
    EEG = pop_rmbase( EEG, [-1500     -500]);
    baseline=squeeze(mean(mean(EEG.data(:,513:1537,:),3),2));
    
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', [subject '_epochedS.set'], 'filepath', newfolder); 
    %% Epoch on feedback
    % load data set 
    EEG =   pop_loadset('filename', [subject '_ICAremoved.set'], 'filepath', parentfolder);
    % 72, 73, 74, 76 and 78 are feedback triggers
    EEG = pop_epoch( EEG, {  '72'  '73' '74' '76' '78' }, [-1  3], 'newname', 'epoched', 'epochinfo', 'yes');
    
    EEG.data = EEG.data-baseline;
    % save ICA dataset
    EEG =   pop_editset(EEG, 'setname', subject);
            pop_saveset(EEG, 'filename', [subject '_epochedF.set'], 'filepath', newfolder);     
end
    
%% Finish
fprintf('\n\n\n***Finished epoching***\n\n\n');

% After removal of bad epochs the data is ready for analyses

return
