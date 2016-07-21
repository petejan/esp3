function update_denoise_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
denoise_tab_comp=getappdata(main_figure,'Denoise_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
% f_s_sig=round(1/(layer.Transceivers(idx_freq).Params.SampleInterval(1)));
% c=(layer.EnvData.SoundSpeed);


[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');
if found==0
     return
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo_denoise_var=algo_obj.Varargin;

range=layer.Transceivers(idx_freq).Data.get_range();
pings=layer.Transceivers(idx_freq).Data.get_numbers();

set(denoise_tab_comp.HorzFilt_sl,'max',length(pings));
set(denoise_tab_comp.HorzFilt_sl,'value',nanmin(algo_denoise_var.HorzFilt,length(pings)));
set(denoise_tab_comp.HorzFilt_ed,'string',num2str(get(denoise_tab_comp.HorzFilt_sl,'Value'),'%.0f'));

set(denoise_tab_comp.VertFilt_sl,'max',range(end));
set(denoise_tab_comp.VertFilt_sl,'value',nanmin(algo_denoise_var.VertFilt,range(end)));
set(denoise_tab_comp.VertFilt_ed,'string',num2str(get(denoise_tab_comp.VertFilt_sl,'Value'),'%.1f'));

set(denoise_tab_comp.NoiseThr_sl,'value',algo_denoise_var.NoiseThr);
set(denoise_tab_comp.NoiseThr_ed,'string',num2str(get(denoise_tab_comp.NoiseThr_sl,'Value'),'%.0f'));

set(denoise_tab_comp.SNRThr_sl,'value',algo_denoise_var.SNRThr);
set(denoise_tab_comp.SNRThr_ed,'string',num2str(get(denoise_tab_comp.SNRThr_sl,'Value'),'%.0f'));

set(findall(denoise_tab_comp.denoise_tab, '-property', 'Enable'), 'Enable', 'on');
end

