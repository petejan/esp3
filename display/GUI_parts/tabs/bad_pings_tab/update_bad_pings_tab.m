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


set(bad_ping_tab_comp.Above,'value',algo.Above);
set(bad_ping_tab_comp.thr_spikes_Above,'string',num2str(algo.thr_spikes_Above,'%.0f'));

set(bad_ping_tab_comp.Below,'value',algo.Below);
set(bad_ping_tab_comp.thr_spikes_Below,'string',num2str(algo.thr_spikes_Below,'%.0f'));

set(bad_ping_tab_comp.BS_std_bool,'value',algo.BS_std_bool);
set(bad_ping_tab_comp.BS_std,'string',num2str(algo.BS_std,'%.0f'));

%set(findall(bad_ping_tab_comp.bad_ping_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Bad_ping_tab',bad_ping_tab_comp);
end
