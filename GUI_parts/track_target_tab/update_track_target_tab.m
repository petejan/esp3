function update_track_target_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
track_target_tab_comp=getappdata(main_figure,'Track_target_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'TrackTarget');
if found==0
     return
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;

algo_fields=fields(algo);

for i=1:length(algo_fields)
    if ~strcmp(algo_fields{i},'ST')
        set(track_target_tab_comp.(algo_fields{i}),'string',num2str(algo.(algo_fields{i})));
    end
end


end
