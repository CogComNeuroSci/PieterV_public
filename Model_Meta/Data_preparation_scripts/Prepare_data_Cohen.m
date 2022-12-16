% list subjects (in chronological order)
sublist={
    'jan8';
    'jan22b';
    'jan24';
    'jan25';
    'jan26';
    'jan28';
    'feb9';
    'feb11';
    'feb11b';
    'feb12a';
    'feb12b';
    'feb16';
    'feb17';
    'feb20';
    'feb23';
    'march9';
    'march10';
};

end_file_header = {'','trial','Rule', 'Stimulus','Response', 'CorResp', 'FBcon', 'Reward', 'Expected_value', 'PE_estimate_low', 'PE_estimate_high', 'Response_likelihood', 'Module'};

commaHeader = [end_file_header;repmat({','},1,numel(end_file_header))];
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader(1:end-1));

x = 0;

for subno=1:length(sublist)
    subid=sublist{subno};
    cd ~/Desktop/ModelRecoveryExplore/Raw_data/Cohen
    numeric_data = load([subid '_mrp.txt' ]);
    
    trials = size(numeric_data,1)
    
    data = zeros(trials, size(end_file_header,2));
    
    data(:,2) = 0:trials-1;
    data(:,3) = numeric_data(:,3)-1;
    
    data(:,5) = numeric_data(:,1)-1;
    
    for tr = 1:trials
        if numeric_data(tr,3)<3
            data(tr,6)=1;
        else
            data(tr,6)=0;
        end;
    end;
    
    Accuracy = double(data(data(:,3)~=1,5) == data(data(:,3)~=1,6));
    fprintf(['\nMean accuracy of subject ' num2str(subno) ' is: ' num2str(mean(Accuracy))])
    data(:,8)= numeric_data(:,4);
    %data(data(:,8)==-1,8)=0;
    data(data(:,3)~=1,7)= double(Accuracy(:) == data(data(:,3)~=1,8));
    
    data = data(data(:,5)>-1,:);
    data = data(data(:,5)<2,:);
    
    fintrials = size(data,1)
    
    %cd ~/Desktop/ModelRecoveryExplore/Data_to_fit/Cohen
    if mean(Accuracy)>.53
        x = x+1;
        filename = strcat('Data_subject_',num2str(x),'.csv');
        fid = fopen(filename, 'a');
        fprintf(fid,'%s\n',textHeader);
    
        for trial = 1:fintrials
            fprintf(fid,'%d,',data(trial,:));
            fprintf(fid, '\n');
        end;
        fclose(fid);
    else
        fprintf(['\nIgnored subject ' num2str(subno)])
    end;

end;