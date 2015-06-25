function update_denoise_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
denoise_tab_comp=getappdata(main_figure,'Denoise_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
f_s_sig=round(1/(layer.Transceivers(idx_freq).Params.SampleInterval(1)));
c=(layer.EnvData.SoundSpeed);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');
algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo_denoise_var=algo_obj.Varargin;


set(denoise_tab_comp.HorzFilt_sl,'value',algo_denoise_var.HorzFilt);
set(denoise_tab_comp.HorzFilt_ed,'string',num2str(get(denoise_tab_comp.HorzFilt_sl,'Value'),'%.0f'));

set(denoise_tab_comp.VertFilt_sl,'value',algo_denoise_var.VertFilt/f_s_sig*c/2);
set(denoise_tab_comp.VertFilt_ed,'string',num2str(get(denoise_tab_comp.VertFilt_sl,'Value'),'%.1f'));

set(denoise_tab_comp.NoiseThr_sl,'value',algo_denoise_var.NoiseThr);
set(denoise_tab_comp.NoiseThr_ed,'string',num2str(get(denoise_tab_comp.NoiseThr_sl,'Value'),'%.0f'));

set(denoise_tab_comp.SNRThr_sl,'value',algo_denoise_var.SNRThr);
set(denoise_tab_comp.SNRThr_ed,'string',num2str(get(denoise_tab_comp.SNRThr_sl,'Value'),'%.0f'));


end

