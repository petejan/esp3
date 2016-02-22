

function [idx_files,idx_loaded,idx_missing]=find_survey_data(files_layer,survey_data_struct)

idx_files=[];
for u=1:length(files_layer)
    idx_files=union(idx_files,find(strcmpi(files_layer{u},survey_data_struct.Filename)));
end

to_load=[];

snap=survey_data_struct.Snapshot;
strat=survey_data_struct.Stratum;
trans=survey_data_struct.Transect;

idx_nan=(snap==0)|strcmp(strat,' ')|trans==0;
snap(idx_nan)=nan;
trans(idx_nan)=nan;


i_trans=0;
idx_loaded={};
idx_s_tot=[];
idx_missing={};

for ii=1:length(idx_files)
    if nansum(idx_files(ii)==idx_s_tot)>0
        continue;
    end
    i_trans=i_trans+1;
    sn=survey_data_struct.Snapshot(idx_files(ii));
    st=survey_data_struct.Stratum{idx_files(ii)};
    tr=survey_data_struct.Transect(idx_files(ii));
    if isnumeric(st)
        idx=find(sn==snap&tr==trans&cellfun(@(x) x==st,strat));
    else
        idx=find(sn==snap&tr==trans&cellfun(@(x) strcmp(x,st),strat));
    end
    idx_missing{i_trans}=setdiff(idx,idx_files);
    idx_loaded{i_trans}=intersect(idx,idx_files);
    
    idx_s_tot=[idx_s_tot; idx_loaded{i_trans}];
end

for i=1:length(idx_missing)
    if ~isempty(idx_missing{i})
        snap_miss=snap(idx_missing{i}(1));
        trans_miss=trans(idx_missing{i}(1));
        strat_miss=strat{idx_missing{i}(1)};
        if isnumeric(strat_miss)
            strat_miss=num2str(strat_miss,'%.0f');
        end
        
        fprintf('Layer seem to be containing incomplete transects... You should load the other files as well...\n');
        fprintf('Incomplete : Snap %.0f Strat %s Trans %.0f \n',snap_miss,strat_miss,trans_miss);
        fprintf('Files loaded :\n')
        fprintf('%s \n', survey_data_struct.Filename{idx_loaded{i}});
        fprintf('Files to load :\n')
        fprintf('%s \n', survey_data_struct.Filename{idx_missing{i}});
    end
end

if length(idx_loaded)>1
    fprintf('Layer seem to be containing more than one transect!\n'); 
    fprintf('Containing : \n');
    for i=1:length(idx_loaded)
        if ~isempty(idx_loaded{i})
            snap_loaded=snap(idx_loaded{i}(1));
            trans_loaded=trans(idx_loaded{i}(1));
            strat_loaded=strat{idx_loaded{i}(1)};
            if isnumeric(strat_loaded)
                strat_loaded=num2str(strat_loaded,'%.0f');
            end           
            fprintf('Snap %.0f Strat %s Trans %.0f \n',snap_loaded,strat_loaded,trans_loaded);
            
        end
    end
end

end