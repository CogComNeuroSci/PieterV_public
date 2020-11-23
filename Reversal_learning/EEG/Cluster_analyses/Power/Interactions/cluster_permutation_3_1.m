%% Produce the random cluster statistics for the cluster analysis

homefolder      ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/';
Datafolder      ='/Volumes/Harde ploate/EEG_reversal_learning/EEG_data/Cluster_data/';
indicesfolder   = '/Volumes/Harde ploate/EEG_reversal_learning/Behavioral_data/Indices/';

num_trials=480;
num_subjects=27;
num_channels=64;
%% Loading some data     
load([homefolder,'ElectrodeDistance']);              % epmap         electrode * electrode
    
load([indicesfolder 'Interaction_regressor'])

cd (Datafolder)
load('FB_cluster_raw');

%% Prepare neighbours
neighbours  = zeros(num_channels,num_channels);
for elec = 1:num_channels
	neighbours(elec,:)      = epmap(elec,:)<40;
	neighbours(elec,elec)   = 0;
end
clear epmap

%% Set variables
nrandom         = 1000;
num_freq           = size(Power_tocluster,1);                 % 18 frequenties
num_time           = size(Power_tocluster,3);                 % 31 tijdspunten
indices         = 1:(num_freq*num_time);
indicesElec     = 1:num_channels;
pvoxels         = 990;
filenameneg     = strcat('ClusterStatisticFeedback_neg_',num2str(pvoxels),'_PE.txt');
filenamepos     = strcat('ClusterStatisticFeedback_pos_',num2str(pvoxels),'_PE.txt');

%% Start randomisation loop
allNegativeStatistics = NaN(nrandom,3);
allPositiveStatistics = NaN(nrandom,3);
   
for rand = 1:nrandom
    %% Permute data and calculate voxel level statistic
    for s = 1:num_subjects
        idy = repmat((s-1)*num_trials,1,num_trials)+(1:num_trials);
        regressor(idy) = regressor(idy(randperm(num_trials)));
    end;
    
    eliminated = 0; 
    for i = 1:length(PE)
        if isnan(Power_to_cluster(1,1,1,i))
            eliminated = eliminated +1;
        else
            statistic=statistic+Power_tocluster(:, :, :,i).*regressor(i,1);
        end;
    end;
    
    statistic=statistic./((num_subjects*num_trials)-eliminated);

    statistic = statistic./(12960-eliminated);
    
    estimates1      = sort(statistic(:));
    poscutoff       = estimates1(ceil( length(estimates1)*   (pvoxels/1000) ));
    negcutoff       = estimates1(floor(length(estimates1)*(1-(pvoxels/1000))));
    
    %% Start clustering
    % do the clustering for the negative and positive statistics
    for sign = 1:2      % negative and positive
        % initialise the matrices used to coordinate the clustering
        clusters                = zeros(num_freq, num_channels, num_time);
        nsign                   = sum(statistic(:)<=negcutoff)+sum(statistic(:)>=poscutoff);
        clusterlocations 		= zeros(nsign, 5); % voxelnumber cluster freq chan time
        clear nsign
        
        % do the clustering for all the channels
        for chan = 1:num_channels
            % determine the neighbouring channels for this channel
            neighbourElectrode 	= indicesElec(neighbours(chan,:)==1);
            chans				= [chan,neighbourElectrode];
            clear neighbourElectrode
            
            % reshape the array with all the voxel level statistics for this channel
            estimates           = squeeze(statistic(:,chan,:));
            estimates			= estimates(:);

            % select the voxel level statistics that cross the negative/positive threshold
            if sign == 1
                idx 			= indices(estimates <= negcutoff);
            else
                idx 			= indices(estimates >= poscutoff);
            end
            clear estimates
            
            % proceed with locatizing the 'significant' voxels
            if ~isempty(idx)
                % determine their location in time and frequency
                freqidx 			= mod(idx,num_freq);
                freqidx(freqidx==0) = num_freq;
                timeidx 			= ceil(idx/num_freq);
                clear idx
                
                % loop over all the 'significant' voxels
                for idxi = 1:length(timeidx)

                    % select the voxels around this 'significant' voxel
                    freqs   = freqidx(idxi) + (-1:1);
                    times	= timeidx(idxi) + (-1:1);

                    freqs   = freqs(freqs>0);
                    freqs   = freqs(freqs<=num_freq);

                    times   = times(times>0);
                    times   = times(times<=num_time);
                    
                    % are there already clustered voxels in the neighbourhood of the 'significant' voxels
                    identifiedClusters = clusters(freqs, chans, times);
                    identifiedClusters = unique(identifiedClusters(:));

                    % use this information to determine the current cluster number
                    if max(identifiedClusters)>0
                        % we are touching upon a voxel that is already clustered
                        identifiedClusters 	= identifiedClusters(identifiedClusters~=0);
                        clusternr 			= min(identifiedClusters);
                        % rename the already detected voxels for this cluster with the current cluster number
                        clusterlocations(ismember(clusterlocations(:,2), identifiedClusters), 2) = clusternr;
                        voxelnumbers        = clusterlocations(clusterlocations(:,2) == clusternr, 1);
                        for j = 1:length(voxelnumbers)
                            clusters(clusterlocations(voxelnumbers(j),3), clusterlocations(voxelnumbers(j),4), clusterlocations(voxelnumbers(j),5)) = clusternr;
                        end
                        clear voxelnumbers
                    else
                        % this is a new cluster
                        clusternr 			= max(clusterlocations(:,2)) + 1;
                    end
                    clear identifiedClusters
                    
                    % loop over the neighbouring voxels of the current 'significant' voxel
                    for row = 1:length(freqs)
                        for col = 1:length(times)
                            for chani = 1:length(chans)

                                % check whether this voxel has already been clsutered
                                rowcheck 	= clusterlocations(clusterlocations(:,3)==freqs(row) 	, 1);
                                colcheck 	= clusterlocations(clusterlocations(:,4)==times(col) 	, 1);
                                chancheck 	= clusterlocations(clusterlocations(:,5)==chans(chani)  , 1);

                                rowcheck 	= rowcheck(ismember(rowcheck,colcheck));
                                rowcheck 	= rowcheck(ismember(rowcheck,chancheck));

                                if isempty(rowcheck)
                                    % detect whether it is a 'significant' voxel
                                    if sign == 1
                                    	CO	= statistic(freqs(row), chans(chani), times(col)) <= negcutoff;
                                    else
                                        CO 	= statistic(freqs(row), chans(chani), times(col)) >= poscutoff;
                                    end
                                    % if so, store the information in clusters and clusterlocations
                                    if CO == 1
                                        clusters(freqs(row), chans(chani), times(col)) 	= clusternr;
                                        currentlocation                                 = sum(clusterlocations(:,2)~=0)+1;
                                        clusterlocations(currentlocation,1)             = max(clusterlocations(:,1))+1;
                                        clusterlocations(currentlocation,2)             = clusternr;
                                        clusterlocations(currentlocation,3)             = freqs(row);
                                        clusterlocations(currentlocation,4)             = times(col);
                                        clusterlocations(currentlocation,5)             = chans(chani);
                                    end
                                end
                                clear rowcheck colcheck chancheck CO
                            end
                        end
                    end
                    fprintf('Random %d Sign %d Channel %d \t Voxel %d\n', rand, sign, chan, idxi);
                    clear clusternr
                end
                clear freqs times
            end
        end
        clear chans freqidx timeidx
        
        % reorganize the information in clusterlocations so that
        % the largest cluster has the number 1, the second largest had the number 2 etc.
        clusterlocations 			= clusterlocations(clusterlocations(:,2)~=0,:);
        clusterlocations(:,2)       = clusterlocations(:,2) + max(clusterlocations(:,2));
        allclusters                 = unique(clusterlocations(:,2));
        frequency                   = crosstab(clusterlocations(:,2));
        [ordered, frequencyorder]   = sort(frequency,'descend');
        for freqi = 1:length(frequencyorder)
            clusterlocations(clusterlocations(:,2)==allclusters(frequencyorder(freqi)),2) = freqi;
        end
        clear allclusters frequency ordered frequencyorder
        
        % store the information of the three largest clusters
        for currentcluster = 1:3
            freqnrs = clusterlocations(clusterlocations(:,2)==currentcluster,3);
            timenrs = clusterlocations(clusterlocations(:,2)==currentcluster,4);
            channrs = clusterlocations(clusterlocations(:,2)==currentcluster,5);
            tminmax = 0;
            
            if sign == 1
                for i = 1:length(freqnrs)
                    tminmax = min(tminmax, statistic(freqnrs(i), channrs(i), timenrs(i)));
                end
                allNegativeStatistics(rand,currentcluster) = tminmax*length(freqnrs);
            else
                for i = 1:length(freqnrs)
                    tminmax = max(tminmax, statistic(freqnrs(i),channrs(i), timenrs(i)));
                end
                allPositiveStatistics(rand,currentcluster) = tminmax*length(freqnrs);
            end
            clear freqnrs timenrs channrs tminmax
        end
        clear clusters clusterlocations
        
        if sign == 1
            filePointer = fopen(filenameneg, 'a');
            fprintf(filePointer, '%d;', allNegativeStatistics(rand,:));
        else
            filePointer = fopen(filenamepos, 'a');
            fprintf(filePointer, '%d;', allPositiveStatistics(rand,:));    
        end
        fprintf(filePointer, '\n');
        fclose(filePointer);
        clear filePointer 
    end
    clear statistic estimates1 poscutoff negcutoff
end


