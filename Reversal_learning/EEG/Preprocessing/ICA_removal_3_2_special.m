% EEGLAB history file generated on the 05-Apr-2019
% ------------------------------------------------
% one participant had to many interpolated electrodes, therefore we had to adjust the ICA for not full ranked matrices
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','Prob_reversal_filteredforICApp21.set','filepath','/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Filtered_files/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
[EEG ALLEEG CURRENTSET] = eeg_retrieve(ALLEEG,1);
EEG = pop_runica(EEG, 'extended',1,'interupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
