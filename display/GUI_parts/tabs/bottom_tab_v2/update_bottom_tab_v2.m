function update_bottom_tab_v2(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_v2_comp=getappdata(main_figure,'Bottom_tab_v2');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetectionV2');
if found==0
    return
end

range=layer.Transceivers(idx_freq).get_transceiver_range();

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(bottom_tab_v2_comp.Thr_bottom_sl,'value',algo.thr_bottom);
set(bottom_tab_v2_comp.Thr_bottom_ed,'string',num2str(get(bottom_tab_v2_comp.Thr_bottom_sl,'Value'),'%.0f'));

set(bottom_tab_v2_comp.r_min_sl,'max',layer.Transceivers(idx_freq).Data.Range(end));
set(bottom_tab_v2_comp.r_min_sl,'value',nanmax(algo.r_min,range(1)));
set(bottom_tab_v2_comp.r_min_ed,'string',num2str(get(bottom_tab_v2_comp.r_min_sl,'Value'),'%.1f'));

set(bottom_tab_v2_comp.r_max_sl,'max',layer.Transceivers(idx_freq).Data.Range(end));
set(bottom_tab_v2_comp.r_max_sl,'value',nanmin(algo.r_max,range(end)));
set(bottom_tab_v2_comp.r_max_ed,'string',num2str(get(bottom_tab_v2_comp.r_max_sl,'Value'),'%.1f'));

set(bottom_tab_v2_comp.thr_echo_sl,'value',algo.thr_echo);
set(bottom_tab_v2_comp.thr_echo_ed,'string',num2str(get(bottom_tab_v2_comp.thr_echo_sl,'Value'),'%.0f'));

set(bottom_tab_v2_comp.thr_cum_sl,'value',algo.thr_cum);
set(bottom_tab_v2_comp.thr_cum_ed,'string',num2str(get(bottom_tab_v2_comp.thr_cum_sl,'Value'),'%.2f'));


set(bottom_tab_v2_comp.Thr_backstep_sl,'value',algo.thr_backstep);
set(bottom_tab_v2_comp.Thr_backstep_ed,'string',num2str(get(bottom_tab_v2_comp.Thr_backstep_sl,'Value'),'%.0f'));

set(bottom_tab_v2_comp.Shift_bot_sl,'value',algo.shift_bot);
set(bottom_tab_v2_comp.Shift_bot_ed,'string',num2str(get(bottom_tab_v2_comp.Shift_bot_sl,'Value'),'%.2f'));

set(bottom_tab_v2_comp.denoised,'value',algo.denoised);
set(findall(bottom_tab_v2_comp.bottom_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Bottom_tab_v2',bottom_tab_v2_comp);

end
