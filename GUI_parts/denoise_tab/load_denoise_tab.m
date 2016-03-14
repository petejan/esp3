function load_denoise_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'Denoise_tab')
    denoise_tab_comp=getappdata(main_figure,'Denoise_tab');
    delete(denoise_tab_comp.denoise_tab);
    rmappdata(main_figure,'Denoise_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.get_range();
nb_samples=length(range);
nb_pings=length(layer.Transceivers(idx_freq).Data.Time);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');

f_s_sig=round(1/(layer.Transceivers(idx_freq).Params.SampleInterval(1)));
c=(layer.EnvData.SoundSpeed);
if ~found
    return;
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo_denoise_var=algo_obj.Varargin;

denoise_tab_comp.denoise_tab=uitab(algo_tab_panel,'Title','Denoise');

pos=create_pos_algo();

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Horizontal Filter (nb pings)','units','normalized','Position',pos{1,1});
denoise_tab_comp.HorzFilt_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',1,'Max',ceil(nb_pings/2),'Value',nanmin(algo_denoise_var.HorzFilt,nb_pings/2),'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
denoise_tab_comp.HorzFilt_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(denoise_tab_comp.HorzFilt_sl,'Value'),'%.0f'));
set(denoise_tab_comp.HorzFilt_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.HorzFilt_ed,'%.0f'});
set(denoise_tab_comp.HorzFilt_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.HorzFilt_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Vertical Filter (m)','units','normalized','Position',pos{2,1});
denoise_tab_comp.VertFilt_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',nanmean(diff(range)),'Max',range(end)/2,'Value',nanmin(algo_denoise_var.VertFilt,range(end)/2),'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
denoise_tab_comp.VertFilt_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(denoise_tab_comp.VertFilt_sl,'Value'),'%.1f'));
set(denoise_tab_comp.VertFilt_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.VertFilt_ed,'%.0f'});
set(denoise_tab_comp.VertFilt_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.VertFilt_sl,'%.0f'});


uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Noise Level Thr (db)','units','normalized','Position',pos{3,1});
denoise_tab_comp.NoiseThr_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',-180,'Max',-80,'Value',algo_denoise_var.NoiseThr,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
denoise_tab_comp.NoiseThr_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(denoise_tab_comp.NoiseThr_sl,'Value'),'%.0f'));
set(denoise_tab_comp.NoiseThr_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.NoiseThr_ed,'%.0f'});
set(denoise_tab_comp.NoiseThr_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.NoiseThr_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','SNR Thr','units','normalized','Position',pos{4,1});
denoise_tab_comp.SNRThr_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',0,'Max',30,'Value',algo_denoise_var.SNRThr,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
denoise_tab_comp.SNRThr_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(denoise_tab_comp.SNRThr_sl,'Value'),'%.0f'));
set(denoise_tab_comp.SNRThr_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.SNRThr_ed,'%.0f'});
set(denoise_tab_comp.SNRThr_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.SNRThr_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.1 0.1 0.15],'callback',{@validate,main_figure});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.7 0.1 0.1 0.15],'callback',{@copy_across_algo,main_figure,'Denoise'});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.6 0.1 0.1 0.15],'callback',{@save_algos,main_figure});



setappdata(main_figure,'Denoise_tab',denoise_tab_comp);

end



function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
denoise_tab_comp=getappdata(main_figure,'Denoise_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

idx_algo=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');


Transceiver=layer.Transceivers(idx_freq);

f_s_sig=round(1/(Transceiver.Params.SampleInterval(1)));
c=(layer.EnvData.SoundSpeed);
FreqStart=(Transceiver.Params.FrequencyStart(1));
FreqEnd=(Transceiver.Params.FrequencyEnd(1));
Freq=(Transceiver.Config.Frequency);
ptx=(Transceiver.Params.TransmitPower(1));
pulse_length=double(Transceiver.Params.PulseLength(1));
gains=Transceiver.Config.Gain;
pulse_lengths=Transceiver.Config.PulseLength;
eq_beam_angle=Transceiver.Config.EquivalentBeamAngle;
[~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
gain=gains(idx_pulse);
FreqCenter=(FreqStart+FreqEnd)/2;
lambda=c/FreqCenter;
eq_beam_angle_curr=eq_beam_angle+20*log10(Freq/(FreqCenter));
alpha=double(Transceiver.Params.Absorbtion);
sacorr=2*Transceiver.Config.SaCorrection(idx_pulse);


if strcmp(Transceiver.Mode,'FM')
    [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));
    pulse_auto_corr=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
    t_eff=nansum(abs(pulse_auto_corr).^2)/(nanmax(abs(pulse_auto_corr).^2)*f_s_sig);
else
    t_eff=pulse_length;
end
power=layer.Transceivers(idx_freq).Data.get_datamat('Power');

if isempty(power)
   disp('Cannot find power. Cannot denoise those data');   
end

[power_unoised,Sv_unoised,Sp_unoised,SNR]=feval(layer.Transceivers(idx_freq).Algo(idx_algo).Function,...
    power,...
    layer.Transceivers(idx_freq).Data.get_range(),...
    c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle_curr,sacorr,...
    'HorzFilt',round(get(denoise_tab_comp.HorzFilt_sl,'Value')),...
    'SNRThr',round(get(denoise_tab_comp.SNRThr_sl,'Value')),...
    'VertFilt',round(get(denoise_tab_comp.VertFilt_sl,'Value')),...
    'NoiseThr',round(get(denoise_tab_comp.NoiseThr_sl,'Value')));


layer.Transceivers(idx_freq).Data.add_sub_data('powerdenoised',power_unoised);
layer.Transceivers(idx_freq).Data.add_sub_data('spdenoised',Sp_unoised);
layer.Transceivers(idx_freq).Data.add_sub_data('svdenoised',Sv_unoised);
layer.Transceivers(idx_freq).Data.add_sub_data('snr',SNR);
curr_disp.setField('svdenoised');

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,0);

end
