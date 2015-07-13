function update_bottom_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_comp=getappdata(main_figure,'Bottom_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');
if found==0
     return
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(bottom_tab_comp.Thr_bottom_sl,'value',algo.thr_bottom);
set(bottom_tab_comp.Thr_bottom_ed,'string',num2str(get(bottom_tab_comp.Thr_bottom_sl,'Value'),'%.0f'));

set(bottom_tab_comp.r_min_sl,'value',algo.r_min);
set(bottom_tab_comp.r_min_ed,'string',num2str(get(bottom_tab_comp.r_min_sl,'Value'),'%.1f'));

set(bottom_tab_comp.r_max_sl,'value',algo.r_max);
set(bottom_tab_comp.r_max_ed,'string',num2str(get(bottom_tab_comp.r_max_sl,'Value'),'%.1f'));

set(bottom_tab_comp.Thr_echo_sl,'value',algo.thr_echo);
set(bottom_tab_comp.Thr_echo_ed,'string',num2str(get(bottom_tab_comp.Thr_echo_sl,'Value'),'%.0f'));

set(bottom_tab_comp.denoised,'value',algo.denoised);

end
