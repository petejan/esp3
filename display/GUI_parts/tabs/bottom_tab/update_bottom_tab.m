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

set(bottom_tab_comp.r_min_sl,'value',nanmax(algo.r_min,layer.Transceivers(idx_freq).Data.Range(1)));
set(bottom_tab_comp.r_min_ed,'string',num2str(get(bottom_tab_comp.r_min_sl,'Value'),'%.1f'));


set(bottom_tab_comp.r_max_sl,'max',layer.Transceivers(idx_freq).Data.Range(end));
set(bottom_tab_comp.r_max_sl,'value',nanmin(algo.r_max,layer.Transceivers(idx_freq).Data.Range(end)));
set(bottom_tab_comp.r_max_ed,'string',num2str(get(bottom_tab_comp.r_max_sl,'Value'),'%.1f'));

set(bottom_tab_comp.Thr_backstep_sl,'value',algo.thr_backstep);
set(bottom_tab_comp.Thr_backstep_ed,'string',num2str(get(bottom_tab_comp.Thr_backstep_sl,'Value'),'%.0f'));

set(bottom_tab_comp.Shift_bot_sl,'value',algo.shift_bot);
set(bottom_tab_comp.Shift_bot_ed,'string',num2str(get(bottom_tab_comp.Shift_bot_sl,'Value'),'%.0f'));

set(bottom_tab_comp.denoised,'value',algo.denoised);

end
