cd ~/Desktop/ModelRecoveryExplore/Raw_data/Liu

load('1_behavioural_data.mat')
numeric_data = data;
string_data = titleName(2:end,:);
column_names = titleName(1,:);

for t = 1:size(string_data,1)
    string_data{t,3} = string_data{t,3}(1:end-5);
end;

to_fill = find(isnan(data(1,:)));
factors = cell(2,size(to_fill,2)); 

x = 0;
for i = to_fill
    x = x+1;
    factors(:,x) = unique(string_data(:,i));
    for t = 1:size(string_data,1)
        numeric_data(t,i) = double(string_data{t,i}(1) == factors{2,x}(1));
    end;
end;

column_names(1,15)= {'Choice'};
numeric_data(:,15) = double(numeric_data(:,9)==numeric_data(:,11));

column_names(1,16) = {'Reward'};
numeric_data(:,16) = double(numeric_data(:,15)==numeric_data(:,4));

column_names(1,17)= {'Rule'};
s1 = [zeros(1,80), ones(1,20), zeros(1,20), ones(1,20), zeros(1,20), ones(1,80), zeros(1,20), ones(1,20), zeros(1,20), ones(1,20)];
s2 = [zeros(1,20), ones(1,20), zeros(1,20), ones(1,20), zeros(1,80), ones(1,20), zeros(1,20), ones(1,20), zeros(1,20), ones(1,80)];
s3 = [ones(1,80), zeros(1,20), ones(1,20), zeros(1,20), ones(1,20), zeros(1,80), ones(1,20), zeros(1,20), ones(1,20), zeros(1,20)];
s4 = [ones(1,20), zeros(1,20), ones(1,20), zeros(1,20), ones(1,80), zeros(1,20), ones(1,20), zeros(1,20), ones(1,20), zeros(1,80)];

column_names(1,18)= {'Block'};
b1 = [zeros(1,80), ones(1,80), zeros(1,80), ones(1,80)];
b2 = [ones(1,80), zeros(1,80), ones(1,80), zeros(1,80)]; 

subjects = unique(numeric_data(:,1));
trials = size(numeric_data,1)/size(subjects,1);

commaHeader = [column_names;repmat({','},1,numel(column_names))];
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader(1:end-1));

for s = subjects'
    data = numeric_data(numeric_data(:,1) == s, :);
    
    if data(1,2)==1
        data(:,17) = s1;
        data(:,18) = b1;
    elseif data(1,2) ==2
        data(:,17) = s2;
        data(:,18) = b2;
    elseif data(1,2) ==3
        data(:,17) = s3;
        data(:,18) = b1;
    else
        data(:,17) = s4;
        data(:,18) = b2;
    end;
    
    filename = strcat('Chen_data_',num2str(s),'.csv');
    fid = fopen(filename, 'a');
    fprintf(fid,'%s\n',textHeader);
    
    for trial = 1:trials
        fprintf(fid,'%d,',data(trial,:));
        fprintf(fid, '\n');
    end;
    fclose(fid);
end;
