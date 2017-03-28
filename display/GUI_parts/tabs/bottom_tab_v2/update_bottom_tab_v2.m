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
algo_varin=algo_obj.Varargin;


set(bottom_tab_v2_comp.thr_bottom,'string',num2str(algo_varin.thr_bottom,'%.0f'));
set(bottom_tab_v2_comp.r_min,'string',num2str(algo_varin.r_min,'%.2f'),'callback',{@check_fmt_box,range(1),range(end),algo_varin.r_min,'%.2f'});
set(bottom_tab_v2_comp.r_max,'string',num2str(algo_varin.r_max,'%.2f'),'callback',{@check_fmt_box,range(1),range(end),algo_varin.r_max,'%.2f'});
set(bottom_tab_v2_comp.thr_backstep,'string',num2str(algo_varin.thr_backstep,'%.0f'))
set(bottom_tab_v2_comp.thr_echo,'string',num2str(algo_varin.thr_echo,'%.0f'));
set(bottom_tab_v2_comp.thr_cum,'string',num2str(algo_varin.thr_cum,'%g'));
set(bottom_tab_v2_comp.shift_bot,'string',num2str(algo_varin.shift_bot,'%.2f'));


set(bottom_tab_v2_comp.denoised,'value',algo_varin.denoised);



setappdata(main_figure,'Bottom_tab_v2',bottom_tab_v2_comp);

end
