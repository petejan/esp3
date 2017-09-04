function save_tt_to_xls(trans_obj,file)

if exist(file,'file')>0
    delete(file);
end

st=trans_obj.ST;
if isempty(st)
    return;
end
st = rmfield(st,'nb_valid_targets');
tracks=trans_obj.Tracks;

algo_obj=get_algo_per_name(trans_obj,'SingleTarget');
algo_tt_obj=get_algo_per_name(trans_obj,'TrackTarget');

algo_sheet=[fieldnames(algo_obj.Varargin) struct2cell(algo_obj.Varargin)];
algo_tt_sheet=[fieldnames(algo_tt_obj.Varargin) struct2cell(algo_tt_obj.Varargin)];

st_tracks=init_st_struct();


st_tracks = rmfield(st_tracks,'nb_valid_targets');
fields_st=fieldnames(st_tracks);
st_tracks.Track_ID=[];

for k=1:length(tracks.target_id)
    idx_targets=tracks.target_id{k};
    st_tracks.Track_ID=[st_tracks.Track_ID k*ones(1,numel(idx_targets))];
    for ifi=1:numel(fields_st)       
        st_tracks.(fields_st{ifi})=[st_tracks.(fields_st{ifi}) st.(fields_st{ifi})(idx_targets)];
    end  
end

st_sheet=struct_to_sheet(st_tracks);

xlswrite(file,algo_sheet,1);
xlswrite(file,algo_tt_sheet,2);
xlswrite(file,st_sheet',3);