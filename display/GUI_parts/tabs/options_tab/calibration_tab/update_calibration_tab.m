function update_calibration_tab(main_figure)


calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);

set(calibration_tab_comp.calibration_txt,'String',sprintf('Current Frequency: %.0fkHz',curr_disp.Freq/1e3));

set(calibration_tab_comp.soundspeed,'String',num2str(layer.EnvData.SoundSpeed,'%.0f'));
       
if ~strcmp(layer.Filetype,'CREST')
    if strcmp(layer.Transceivers(idx_freq).Mode,'CW')
        cal_cw=get_cal(layer.Transceivers(idx_freq));
       
        set(calibration_tab_comp.G0,'string',num2str(cal_cw.G0,'%.2f'));
        set(calibration_tab_comp.SACORRECT,'string',num2str(cal_cw.SACORRECT,'%.2f'));

     end

    set(calibration_tab_comp.string_cal,'string',...
        sprintf('Currently used values:\n Soundspeed: %.1f m/s\n Absorbtion %.2f dB/km\n Salinity %.0f PSU \n Temperature %.1f deg C.\n',...
        layer.EnvData.SoundSpeed,layer.Transceivers(idx_freq).Params.Absorption(1)*1e3,layer.EnvData.Salinity,layer.EnvData.Temperature));

end


setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
end
