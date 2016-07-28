function update_single_target_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
single_target_tab_comp=getappdata(main_figure,'Single_target_tab');


idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'SingleTarget');
if found==0
     return
end
algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(single_target_tab_comp.TS_threshold_sl,'value',algo.TS_threshold);
set(single_target_tab_comp.TS_threshold_ed,'string',num2str(get(single_target_tab_comp.TS_threshold_sl,'Value'),'%.0f'));

set(single_target_tab_comp.PLDL_sl,'value',algo.PLDL);
set(single_target_tab_comp.PLDL_ed,'string',num2str(get(single_target_tab_comp.PLDL_sl,'Value'),'%.0f'));

set(single_target_tab_comp.MinNormPL_sl,'value',algo.MinNormPL);
set(single_target_tab_comp.MinNormPL_ed,'string',num2str(get(single_target_tab_comp.MinNormPL_sl,'Value'),'%.1f'));

set(single_target_tab_comp.MaxNormPL_sl,'value',algo.MaxNormPL);
set(single_target_tab_comp.MaxNormPL_ed,'string',num2str(get(single_target_tab_comp.MaxNormPL_sl,'Value'),'%.1f'));

set(single_target_tab_comp.MaxBeamComp_sl,'value',algo.MaxBeamComp);
set(single_target_tab_comp.MaxBeamComp_ed,'string',num2str(get(single_target_tab_comp.MaxBeamComp_sl,'Value'),'%.0f'));

set(single_target_tab_comp.MaxStdMinAxisAngle_sl,'value',algo.MaxStdMinAxisAngle);
set(single_target_tab_comp.MaxStdMinAxisAngle_ed,'string',num2str(get(single_target_tab_comp.MaxStdMinAxisAngle_sl,'Value'),'%.1f'));

set(single_target_tab_comp.MaxStdMajAxisAngle_sl,'value',algo.MaxStdMajAxisAngle);
set(single_target_tab_comp.MaxStdMajAxisAngle_ed,'string',num2str(get(single_target_tab_comp.MaxStdMajAxisAngle_sl,'Value'),'%.1f'));


set(findall(single_target_tab_comp.single_target_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Single_target_tab',single_target_tab_comp);
end
