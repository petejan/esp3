function update_track_target_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
track_target_tab_comp=getappdata(main_figure,'Track_target_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[idx_algo,found]=find_algo_idx(trans_obj,'TrackTarget');
if found==0
     return
end

algo_obj=trans_obj.Algo(idx_algo);
algo=algo_obj.Varargin;

algo_fields=fields(algo);

for i=1:length(algo_fields)
    if ~any(strcmp(algo_fields{i},{'ST','idx_r','idx_pings','reg_obj'}))
        set(track_target_tab_comp.(algo_fields{i}),'string',num2str(algo.(algo_fields{i})));
    end
end

%set(findall(track_target_tab_comp.track_target_tab, '-property', 'Enable'), 'Enable', 'on');
setappdata(main_figure,'Track_target_tab',track_target_tab_comp);

update_map_tab(main_figure,'map',0,'histo',1);
end
