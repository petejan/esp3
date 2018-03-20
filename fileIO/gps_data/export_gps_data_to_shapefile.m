function export_gps_data_to_shapefile(layers,shapeFn,Unique_ID)

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

layer_to_export=layers(idx);

for ilay=1:length(layer_to_export)
    layer=layer_to_export(ilay);
    trans_obj=layer.Transceivers(1);
    gps_obj=trans_obj.GPSDataPing;            
    filenames=layer.Filename;
   
    for ifile=1:length(filenames)
        idx_f=find(trans_obj.Data.FileId==ifile);
        [~,file_tmp,ext_tmp]=fileparts(filenames{ifile});
        field=genvarname(file_tmp);
        Lines.(field)=gps_obj.gps_to_geostruct(idx_f);
        Lines.(field).Filename=[file_tmp ext_tmp];        
    end
end


LineIDs = fieldnames(Lines);


i = 1;

for LineIndex = 1:numel(LineIDs)
    
    LineID = LineIDs{LineIndex};
    Line = Lines.(LineID);
    
    if i==1
        LinesArray = repmat(Line, numel(LineIDs), 1 );
    else
        LinesArray(i) = Line;
    end
    i = i + 1;
end

shapewrite(LinesArray,shapeFn);