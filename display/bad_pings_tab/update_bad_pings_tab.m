function update_bad_pings_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bad_ping_tab_comp=getappdata(main_figure,'Bad_ping_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'BadPings');
if found==0
     return
end



algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(bad_ping_tab_comp.Thr_bottom_sl,'value',algo.thr_bottom);
set(bad_ping_tab_comp.Thr_bottom_ed,'string',num2str(get(bad_ping_tab_comp.Thr_bottom_sl,'Value'),'%.0f'));

set(bad_ping_tab_comp.r_min_sl,'value',algo.r_min);
set(bad_ping_tab_comp.r_min_ed,'string',num2str(get(bad_ping_tab_comp.r_min_sl,'Value'),'%.1f'));

set(bad_ping_tab_comp.r_max_sl,'value',algo.r_max);
set(bad_ping_tab_comp.r_max_ed,'string',num2str(get(bad_ping_tab_comp.r_max_sl,'Value'),'%.1f'));

set(bad_ping_tab_comp.Thr_echo_sl,'value',algo.thr_echo);
set(bad_ping_tab_comp.Thr_echo_ed,'string',num2str(get(bad_ping_tab_comp.Thr_echo_sl,'Value'),'%.0f'));

set(bad_ping_tab_comp.Above,'value',algo.Above);

set(bad_ping_tab_comp.thr_spikes_Above_sl,'value',algo.thr_spikes_Above);
set(bad_ping_tab_comp.thr_spikes_Above_ed,'string',num2str(get(bad_ping_tab_comp.thr_spikes_Above_sl,'Value'),'%.0f'));

set(bad_ping_tab_comp.Below,'value',algo.Below);

set(bad_ping_tab_comp.thr_spikes_Below_sl,'value',algo.thr_spikes_Below);
set(bad_ping_tab_comp.thr_spikes_Below_ed,'string',num2str(get(bad_ping_tab_comp.thr_spikes_Below_sl,'Value'),'%.0f'));

set(bad_ping_tab_comp.BS_std_sl,'value',algo.BS_std);
set(bad_ping_tab_comp.BS_std_ed,'string',num2str(get(bad_ping_tab_comp.BS_std_sl,'Value'),'%.0f'));


end
