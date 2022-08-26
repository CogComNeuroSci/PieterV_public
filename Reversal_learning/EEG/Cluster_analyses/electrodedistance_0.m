% Define subjects and folders
homefolder      ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
Datafolder     ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';

n_channels=64;
load([homefolder 'chanloc'])
locations=chanlocations(1:n_channels);

epmap   = zeros(n_channels);
rownm   = cell(n_channels,1);
colnm   = cell(1,n_channels);

for i = 1:n_channels
    rownm(i) = {chanlocations(i).labels};
    
    for k = i+1:n_channels
        
        a = [chanlocations(i).X; chanlocations(i).Y; chanlocations(i).Z];
        b = [chanlocations(k).X; chanlocations(k).Y; chanlocations(k).Z];
        
        aa = sum(a.*a,1);
        bb = sum(b.*b,1);
        ab = a'*b;
        epmap(i,k)  = sqrt(abs(  repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab   ));
        epmap(k,i)  = epmap(i,k);
        
        if i == 1, colnm(k) = {chanlocations(k).labels}; end
    end
end

%% export results
cd(Datafolder)

save('ElectrodeDistance', 'epmap')

save('ElectrodeNames', 'rownm')