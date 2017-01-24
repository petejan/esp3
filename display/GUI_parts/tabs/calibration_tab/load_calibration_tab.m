function load_calibration_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Calibration_tab')
    calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
    delete(get(calibration_tab_comp.calibration_tab,'children'));
else
   calibration_tab_comp.calibration_tab=uitab(option_tab_panel,'Title','Calibration'); 
  
end

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
     setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
    return;
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);

calibration_tab_comp.calibration_txt=uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String',sprintf('Current Frequency: %.0fkHz SoundSpeed(m/s):',curr_disp.Freq/1e3),'units','normalized','Position',[0.1 0.85 0.5 0.1]);

  calibration_tab_comp.soundspeed=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.55 0.85 0.1 0.1],'string',num2str(layer.EnvData.SoundSpeed,'%.0f'),'callback',{@change_soundspeed_cback,main_figure});
       

if ~strcmp(layer.Filetype,'CREST')
    if strcmp(layer.Transceivers(idx_freq).Mode,'CW')
        cal_cw=get_cal(layer.Transceivers(idx_freq));
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Gain (dB)','units','normalized','Position',[0.1 0.7 0.2 0.1]);
        calibration_tab_comp.G0=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.7 0.1 0.1],'string',num2str(cal_cw.G0,'%.2f'),'callback',{@apply_calibration,main_figure});
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Sa Corr (dB)','units','normalized','Position',[0.1 0.55 0.2 0.1]);
        calibration_tab_comp.SACORRECT=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.55 0.1 0.1],'string',num2str(cal_cw.SACORRECT,'%.2f'),'callback',{@apply_calibration,main_figure});
        
        
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Save','callback',{@save_CW_calibration,main_figure},'unit','normalized','position',[0.8 0.1 0.15 0.2]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Reprocess','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0.55 0.1 0.15 0.2]);
    else
       
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Disp. Cal. Curves','callback',{@display_cal,main_figure},'unit','normalized','position',[0.8 0.6 0.15 0.2]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process TS Cal','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0.80 0.1 0.15 0.2]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process EBA Cal','callback',{@reprocess_EBA_calibration,main_figure},'unit','normalized','position',[0.55 0.1 0.15 0.2]);
        
    end
    
     calibration_tab_comp.sphere=uicontrol(calibration_tab_comp.calibration_tab,'Style','popup','string',list_spheres(),'unit','normalized','position',[0.5 0.6 0.2 0.1]);
  
    uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Att (dB/km)','units','normalized','Position',[0.1 0.4 0.2 0.1]);
    calibration_tab_comp.att=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.4 0.1 0.1],'string',num2str(layer.Transceivers(idx_freq).Params.Absorption(1)*1e3,'%.1f'),'callback',{@apply_absorption,main_figure});
    
    uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Temp. (degC)','units','normalized','Position',[0.1 0.25 0.2 0.1]);
    calibration_tab_comp.temp=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.25 0.1 0.1],'string',num2str(layer.EnvData.Temperature,'%.1f'),'callback',{@save_envdata_callback,main_figure});
    
     uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Salinity. (PSU)','units','normalized','Position',[0.1 0.1 0.2 0.1]);
    calibration_tab_comp.sal=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.1 0.1 0.1],'string',num2str(layer.EnvData.Salinity,'%.1f'),'callback',{@save_envdata_callback,main_figure});
   
    
    
end
format_color_gui(main_figure,[]);

setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
end



function reprocess_TS_calibration(~,~,main_figure)
TS_calibration_curves_func(main_figure);
loadEcho(main_figure);
end

function reprocess_EBA_calibration(~,~,main_figure)
beamwidth_calibration_curves_func(main_figure);
loadEcho(main_figure);
end

function apply_absorption(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

new_abs=str2double(get(calibration_tab_comp.att,'string'));
if~isnan(new_abs)&&new_abs>0&&new_abs<200
    layer.Transceivers(idx_freq).apply_absorption(new_abs/1e3)
end
set(calibration_tab_comp.att,'string',num2str(layer.Transceivers(idx_freq).Params.Absorption(1)*1e3,'%.2f'));

loadEcho(main_figure);
end

function change_soundspeed_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');

c = str2double(get(calibration_tab_comp.soundspeed,'string'));

if~(~isnan(c)&&c>=1000&&c<=2000)
    c=layer.EnvData.SoundSpeed;
end

set(calibration_tab_comp.soundspeed,'string',num2str(c,'%.0f'));

layer.apply_soundspeed(c);

update_axis_panel(main_figure,0);
update_calibration_tab(main_figure);
display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_regions(main_figure,'both');
display_survdata_lines(main_figure);
set_alpha_map(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);

setappdata(main_figure,'Layer',layer);

end

function save_envdata_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');


new_sal=str2double(get(calibration_tab_comp.sal,'string'));
if~isnan(new_sal)&&new_sal>=0&&new_sal<=50
    layer.EnvData.Salinity=new_sal;
else
    new_sal=layer.EnvData.Salinity;
end
set(calibration_tab_comp.sal,'string',num2str(new_sal,'%.1f'));

new_temp=str2double(get(calibration_tab_comp.temp,'string'));
if~isnan(new_temp)&&new_temp>=-5&&new_temp<=90
    layer.EnvData.Temperature=new_temp;
else
    new_temp=layer.EnvData.Temperature;
end
set(calibration_tab_comp.temp,'string',num2str(new_temp,'%.1f'));
    
c = sw_svel(layer.EnvData.Salinity,layer.EnvData.Temperature,5);

layer.apply_soundspeed(c);
update_axis_panel(main_figure,0);
update_calibration_tab(main_figure);
display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_regions(main_figure,'both');
display_survdata_lines(main_figure);
set_alpha_map(main_figure);
order_axes(main_figure);
order_stacks_fig(main_figure);

setappdata(main_figure,'Layer',layer);


end


function apply_calibration(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);


if strcmp(layer.Transceivers(idx_freq).Mode,'CW')
    
    new_cal.G0=str2double(get(calibration_tab_comp.G0,'string'));
    new_cal.SACORRECT=str2double(get(calibration_tab_comp.SACORRECT,'string'));
    
    layer.Transceivers(idx_freq).apply_cw_cal(new_cal);
end

setappdata(main_figure,'Layer',layer);
loadEcho(main_figure);

end

function save_CW_calibration(~,~,main_figure)
apply_calibration([],[],main_figure);
layer=getappdata(main_figure,'Layer');

[cal_path,~,~]=fileparts(layer.Filename{1});

fid=fopen(fullfile(cal_path,'cal_echo.csv'),'w+');
fprintf(fid,'%s,%s,%s\n', 'F', 'G0', 'SACORRECT');
for i=1:length(layer.Transceivers)
    cal_cw=get_cal(layer.Transceivers(i));
    fprintf(fid,'%.0f,%.2f,%.2f\n',layer.Frequencies(i),cal_cw.G0,cal_cw.SACORRECT);
end
fclose(fid);

end
