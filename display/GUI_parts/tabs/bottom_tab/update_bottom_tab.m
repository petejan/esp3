function update_bottom_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_comp=getappdata(main_figure,'Bottom_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');
if found==0
    return
end


dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;

range=layer.Transceivers(idx_freq).Data.get_range();

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(bottom_tab_comp.Thr_bottom_sl,'value',algo.thr_bottom);
set(bottom_tab_comp.Thr_bottom_ed,'string',num2str(get(bottom_tab_comp.Thr_bottom_sl,'Value'),'%.0f'));

set(bottom_tab_comp.r_min_sl,'max',layer.Transceivers(idx_freq).Data.Range(end));
set(bottom_tab_comp.r_min_sl,'value',nanmax(algo.r_min,range(1)));
set(bottom_tab_comp.r_min_ed,'string',num2str(get(bottom_tab_comp.r_min_sl,'Value'),'%.1f'));

set(bottom_tab_comp.r_max_sl,'max',layer.Transceivers(idx_freq).Data.Range(end));
set(bottom_tab_comp.r_max_sl,'value',nanmin(algo.r_max,range(end)));
set(bottom_tab_comp.r_max_ed,'string',num2str(get(bottom_tab_comp.r_max_sl,'Value'),'%.1f'));


set(bottom_tab_comp.horz_filt_sl,'max',dist(end)/4);
set(bottom_tab_comp.horz_filt_sl,'min',0);
set(bottom_tab_comp.horz_filt_sl,'value',nanmin(algo.horz_filt,(dist(end)-dist(1))/10));
set(bottom_tab_comp.horz_filt_ed,'string',num2str(get(bottom_tab_comp.horz_filt_sl,'Value'),'%.1f'));

set(bottom_tab_comp.vert_filt_sl,'max',layer.Transceivers(idx_freq).Data.Range(end)/4);
set(bottom_tab_comp.vert_filt_sl,'value',nanmin(algo.vert_filt,range(end)/10));
set(bottom_tab_comp.vert_filt_ed,'string',num2str(get(bottom_tab_comp.vert_filt_sl,'Value'),'%.1f'));

set(bottom_tab_comp.Thr_backstep_sl,'value',algo.thr_backstep);
set(bottom_tab_comp.Thr_backstep_ed,'string',num2str(get(bottom_tab_comp.Thr_backstep_sl,'Value'),'%.0f'));

set(bottom_tab_comp.Shift_bot_sl,'value',algo.shift_bot);
set(bottom_tab_comp.Shift_bot_ed,'string',num2str(get(bottom_tab_comp.Shift_bot_sl,'Value'),'%.0f'));

set(bottom_tab_comp.denoised,'value',algo.denoised);
set(findall(bottom_tab_comp.bottom_tab, '-property', 'Enable'), 'Enable', 'on');

if isempty(dist)
    set([bottom_tab_comp.horz_filt_sl bottom_tab_comp.horz_filt_ed], 'Enable', 'off');
end
setappdata(main_figure,'Bottom_tab',bottom_tab_comp);

end
