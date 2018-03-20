function export_gps_data_to_csv(layers,def,Unique_ID)

if ~iscell(Unique_ID)
    Unique_ID={Unique_ID};
end

if isempty(Unique_ID{1})
    idx=1:length(layers);
else
    idx=[];
    for id=1:length(Unique_ID)
        [idx_temp,found]=find_layer_idx(layers,Unique_ID{id});
    if found==0
        continue;
    end
    idx=union(idx,idx_temp);
    end
end

layers_to_export=layers(idx);


for ilay=1:length(layers_to_export)
    layer=layers_to_export(ilay);
    trans_obj=layer.Transceivers(1);
    gps_obj=trans_obj.GPSDataPing;
    filenames=layer.Filename;
    
    
    for i=1:length(filenames)
        
        [path_f,fileN_ori,~]=fileparts(filenames{i});
        if def==1
            fileN=fullfile(path_f,[fileN_ori,'_gps.csv']);
        else
            fileN=fullfile(path_f,[fileN_ori,'_gps_data.csv']);
        end
        idx_f=find(trans_obj.Data.FileId==i);
        gps_obj.save_gps_to_file(fileN,idx_f);
        
        fprintf('Position for file %s saved\n',fileN);
        
        [stat,~]=system(['start notepad++ ' fileN]);
        
        if stat~=0
            disp('You should install Notepad++...');
            system(['start ' fileN]);
        end
        
    end
end