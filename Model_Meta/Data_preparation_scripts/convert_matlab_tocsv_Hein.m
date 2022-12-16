cd ~/Desktop/ModelRecoveryExplore/Raw_data/Hein

control_group = [1:19, 22, 37];

end_file_header = {'','trial','Rule', 'Stimulus','Response', 'CorResp', 'FBcon', 'Reward', 'Expected_value', 'PE_estimate_low', 'PE_estimate_high', 'Response_likelihood', 'Module'};

commaHeader = [end_file_header;repmat({','},1,numel(end_file_header))];
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader(1:end-1));

x = 0;

for s = control_group
    load(['tanx_' num2str(s) '.mat'])
    
    numeric_data = [participant_data.experiment_data_block1', participant_data.experiment_data_block2']';
    string_data = participant_data.experiment_data_codings;
    
    data = zeros(size(numeric_data,1), size(end_file_header,2));
    
    data(:,3) = numeric_data(:,4)/10;
    data(:,2) = 0:size(numeric_data,1)-1;
    
    numeric_data(numeric_data(:,8)==0,8) = 2;
    data(:,5) = double(numeric_data(:,7)==numeric_data(:,8));
    data(:,6) = double(numeric_data(:,4)>= 50);
    Accuracy = double(data(:,5) == data(:,6));
    fprintf(['\nMean accuracy of subject ' num2str(s) ' is: ' num2str(mean(Accuracy))])
    data(:,8)= numeric_data(:,11);
    data(:,9)= double(Accuracy(:) == data(:,8));
    
    if mean(Accuracy)>.6
        x = x+1;
        filename = strcat('Data_subject_',num2str(x),'.csv');
        fid = fopen(filename, 'a');
        fprintf(fid,'%s\n',textHeader);
    
        for trial = 1:size(numeric_data,1)
            fprintf(fid,'%d,',data(trial,:));
            fprintf(fid, '\n');
        end;
        fclose(fid);
    else
        fprintf(['\nIgnored subject ' num2str(s)])
    end;

end;

