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

range=layer.Transceivers(idx_freq).get_transceiver_range();

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);

algo_varin=algo_obj.Varargin;


set(bottom_tab_comp.thr_bottom,'string',num2str(algo_varin.thr_bottom,'%.0f'));
set(bottom_tab_comp.r_min,'string',num2str(algo_varin.r_min,'%.2f'),'callback',{@check_fmt_box,range(1),range(end),algo_varin.r_min,'%.2f'});
set(bottom_tab_comp.r_max,'string',num2str(algo_varin.r_max,'%.2f'),'callback',{@check_fmt_box,range(1),range(end),algo_varin.r_max,'%.2f'});
if ~isempty(dist)
    set(bottom_tab_comp.horz_filt,'string',num2str(algo_varin.horz_filt,'%.1f'),'callback',{@check_fmt_box,dist(1),dist(end),algo_varin.horz_filt,'%.2f'});
end
set(bottom_tab_comp.vert_filt,'string',num2str(algo_varin.vert_filt,'%.1f'),'callback',{@check_fmt_box,range(1),range(end),algo_varin.vert_filt,'%.2f'});
set(bottom_tab_comp.thr_backstep,'string',num2str(algo_varin.thr_backstep,'%.0f'));
set(bottom_tab_comp.shift_bot,'string',num2str(algo_varin.shift_bot,'%.2f'    ));

set(bottom_tab_comp.denoised,'value',algo_varin.denoised);

if isempty(dist)
    set([bottom_tab_comp.horz_filt bottom_tab_comp.horz_filt], 'Enable', 'off');
end

setappdata(main_figure,'Bottom_tab',bottom_tab_comp);

end
