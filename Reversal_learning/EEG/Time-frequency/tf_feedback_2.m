%open eeglab
addpath('/Users/pieter/Documents/MATLAB/eeglab14_1_2b')
eeglab

%% define parameters
parentfolder          = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cleaned_files/';
newfolder             = '/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/TF_data/';
subject_list    = {'pp3', 'pp5', 'pp6', 'pp7', 'pp9', 'pp10', 'pp12', 'pp14', 'pp15', 'pp16', 'pp18', 'pp19', 'pp20', 'pp21', 'pp22', 'pp23', 'pp24', 'pp25','pp26','pp27','pp28','pp29','pp30','pp31','pp32','pp33','pp34'};
num_subjects    = length(subject_list);

srate=512;                                      %sampling rate
timing_of_interest=1:2:3585;                    %downsampling and cutting of some time
frex    = logspace(log10(2),log10(48), 25);
wavtime = -2:1/srate:2-1/srate;                 %wavelet time
halfwav = (length(wavtime)-1)/2;
num_cycles = logspace(log10(3), log10(8),25);   %wavelet cycles
nData   = length(timing_of_interest);
nKern   = length(wavtime);
nConv   = nData + nKern -1;

%% create wavelets
cmwX= zeros(length(frex),nConv);
for fi=1:length(frex)
    s = num_cycles(fi)/(2*pi*frex(fi));
    % create time-domain wavelet
    cmw = exp(2*1i*pi*frex(fi).*wavtime) .* exp(-wavtime.^2./(2*s^2));
    
    % compute fourier coefficients of wavelet and normalize
    cmwX(fi,:) = fft(cmw,nConv);
    cmwX(fi,:) = cmwX(fi,:) ./ max(cmwX(fi,:));
end;    

cd (parentfolder)

for s=1:num_subjects
    subject         = subject_list{s}; 
    EEG =   pop_loadset('filename', ['Cleaned_' subject '_F.set'], 'filepath', parentfolder);
    
    fprintf('loaded dataset of %s', subject)
    
    %for memory we record frontal and posterior electrodes separately
    feedback_tf_frontal=NaN(length(frex),32,length(timing_of_interest),EEG.trials);
    feedback_tf_posterior=NaN(length(frex),32,length(timing_of_interest),EEG.trials);
    
    for t=1:EEG.trials
        %fill removed epochs with nan
        if isnan(EEG.data(1,1,t))
            feedback_tf_frontal(fi,:,:,t)=NaN(1,32,length(timing_of_interest),1);
            feedback_tf_posterior(fi,:,:,t)=NaN(1,32,length(timing_of_interest),1);
        else
            for c=1:32

                % FFT of data (doesn't change on frequency iteration)
                dataXf = fft( EEG.data(c,timing_of_interest,t) ,nConv);
                dataXp = fft( EEG.data(c+32,timing_of_interest,t) ,nConv);
                for fi=1:length(frex)
                    % second and third steps of convolution
                    as_f = ifft( cmwX(fi,:).*dataXf ,nConv );
                    as_p = ifft( cmwX(fi,:).*dataXp ,nConv );
        
                    % cut wavelet back to size of data
                    as_f = as_f(round(halfwav)+1:end-round(halfwav)+1);
                    as_p = as_p(round(halfwav)+1:end-round(halfwav)+1);
                    %as= reshape(as,length(timing_of_interest),EEG.trials);
        
                    % extract power and phase
                    feedback_tf_frontal(fi,c,:,t)=as_f;
                    feedback_tf_posterior(fi,c,:,t)=as_p;
                end;
            end;
        end;
        fprintf('\n\n done with trial %d', t)
    end;

    save([newfolder 'tf_feedback_' subject], 'feedback_tf_frontal', 'feedback_tf_posterior','-v7.3');
    fprintf('\n\n done with subject %s', subject)
end;

