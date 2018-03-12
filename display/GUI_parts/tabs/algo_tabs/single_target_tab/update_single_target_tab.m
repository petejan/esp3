function update_single_target_tab(main_figure,new)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
single_target_tab_comp=getappdata(main_figure,'Single_target_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[idx_algo,found]=find_algo_idx(trans_obj,'SingleTarget');
if found==0
     return
end
algo_obj=trans_obj.Algo(idx_algo);
varin=algo_obj.Varargin;


set(single_target_tab_comp.TS_threshold,'string',num2str(varin.TS_threshold,'%.0f'));

set(single_target_tab_comp.PLDL,'string',num2str(varin.PLDL,'%.0f'));

set(single_target_tab_comp.MinNormPL,'string',num2str(varin.MinNormPL,'%.1f'));

set(single_target_tab_comp.MaxNormPL,'string',num2str(varin.MaxNormPL,'%.1f'));

set(single_target_tab_comp.MaxBeamComp,'string',num2str(varin.MaxBeamComp,'%.0f'));

set(single_target_tab_comp.MaxStdMinAxisAngle,'string',num2str(varin.MaxStdMinAxisAngle,'%.1f'));

set(single_target_tab_comp.MaxStdMajAxisAngle,'string',num2str(varin.MaxStdMajAxisAngle,'%.1f'));


%set(findall(single_target_tab_comp.single_target_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Single_target_tab',single_target_tab_comp);
update_st_tracks_tab(main_figure,'histo',1,'st',1);
end
