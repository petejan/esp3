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

[trans_obj,idx_freq]=layer.get_trans(curr_disp);


calibration_tab_comp.calibration_txt=uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String',sprintf('Current Frequency: %.0fkHz',curr_disp.Freq/1e3),'units','normalized','Position',[0.05 0.85 0.4 0.1],'BackgroundColor','White');


curr_sal=layer.EnvData.Salinity;
curr_temp=layer.EnvData.Temperature;
curr_ss=layer.EnvData.SoundSpeed;
curr_abs=trans_obj.Params.Absorption(1);

if ~ismember(layer.Filetype,{'CREST','ASL'})
    if strcmp(trans_obj.Mode,'CW')
        cal_cw=get_cal(trans_obj);
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Gain (dB)','units','normalized','Position',[0.1 0.7 0.2 0.1],'BackgroundColor','White');
        calibration_tab_comp.G0=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.7 0.1 0.1],'string',num2str(cal_cw.G0,'%.2f'),'callback',{@apply_calibration,main_figure});
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Sa Corr (dB)','units','normalized','Position',[0.1 0.55 0.2 0.1],'BackgroundColor','White');
        calibration_tab_comp.SACORRECT=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.55 0.1 0.1],'string',num2str(cal_cw.SACORRECT,'%.2f'),'callback',{@apply_calibration,main_figure});
        %
        %         uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','ES Corr (dB)','units','normalized','Position',[0.1 0.4 0.2 0.1]);
        %         calibration_tab_comp.EsOffset=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.4 0.1 0.1],'string',num2str(trans_obj.Config.EsOffset,'%.2f'),'callback',{@apply_triangle_wave_corr_cback,main_figure});
        %
        %         if trans_obj.need_escorr()==0
        %             set(calibration_tab_comp.EsOffset,'Enable','off');
        %         end
        
        
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Save','callback',{@save_CW_calibration,main_figure},'unit','normalized','position',[0 0 0.15 0.15]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Reprocess','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0 0.15 0.15 0.15]);
        
    else
        
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Disp. Cal. Curves','callback',{@display_cal,main_figure},'unit','normalized','position',[0 0 0.15 0.15]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process TS Cal','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0 0.15 0.15 0.15]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process EBA Cal','callback',{@reprocess_EBA_calibration,main_figure},'unit','normalized','position',[0 0.3 0.15 0.15]);
        
    end
end
calibration_tab_comp.sphere=uicontrol(calibration_tab_comp.calibration_tab,'Style','popup','string',list_spheres(),'unit','normalized','position',[0.2 0.4 0.2 0.1]);

env_group=uibuttongroup(calibration_tab_comp.calibration_tab,'units','normalized','Position',[0.5 0.0 0.5 1],'title','Environment');

calibration_tab_comp.att_model=uicontrol(env_group,'Style','popup','string',{'Doonan et al (2003)' 'Francois & Garrison (1982)'},'unit',...
    'normalized','position',[0.0 0.85 0.35 0.1],'callback',{@update_values,main_figure});

uicontrol(env_group,'Style','Text','String','Depth (m)','units','normalized','Position',[0.35 0.45 0.4 0.1]);
calibration_tab_comp.depth=uicontrol(env_group,'style','edit','unit','normalized','position',[0.75 0.45 0.15 0.1],'string',num2str(5,'%.0f'),'callback',{@update_values,main_figure});

uicontrol(env_group,'Style','Text','String','Soundspeed(m/s)','units','normalized','Position',[0.35 0.55 0.4 0.1]);
calibration_tab_comp.soundspeed=uicontrol(env_group,'style','edit','unit','normalized','position',[0.75 0.55 0.15 0.1],'string',num2str(curr_ss,'%.0f'),'callback',{@update_values,main_figure});
calibration_tab_comp.soundspeed_over=uicontrol(env_group,'style','checkbox','unit','normalized','position',[0.92 0.55 0.05 0.1],'callback',{@update_values,main_figure});

uicontrol(env_group,'Style','Text','String','Att (dB/km)','units','normalized','Position',[0.35 0.65 0.4 0.1]);
calibration_tab_comp.att=uicontrol(env_group,'style','edit','unit','normalized','position',[0.75 0.65 0.15 0.1],'string',num2str(curr_abs*1e3,'%.1f'),'callback',{@update_values,main_figure});
calibration_tab_comp.att_over=uicontrol(env_group,'style','checkbox','unit','normalized','position',[0.92 0.65 0.05 0.1],'callback',{@update_values,main_figure});

uicontrol(env_group,'Style','Text','String','Temp. (degC)','units','normalized','Position',[0.35 0.75 0.4 0.1]);
calibration_tab_comp.temp=uicontrol(env_group,'style','edit','unit','normalized','position',[0.75 0.75 0.15 0.1],'string',num2str(curr_temp,'%.1f'),'callback',{@update_values,main_figure});

uicontrol(env_group,'Style','Text','String','Salinity. (PSU)','units','normalized','Position',[0.35 0.85 0.4 0.1]);
calibration_tab_comp.sal=uicontrol(env_group,'style','edit','unit','normalized','position',[0.75 0.85 0.15 0.1],'string',num2str(curr_sal,'%.0f'),'callback',{@update_values,main_figure});

calibration_tab_comp.string_cal=uicontrol(env_group,'Style','text','unit','normalized','position',[0.0 0 0.6 0.45],'HorizontalAlignment','left',...
    'string',sprintf('Currently used values:\n Soundspeed: %.1f m/s\n Absorbtion %.2f dB/km\n Salinity %.0f PSU \n Temperature %.1f deg C.\n',...
    curr_ss,curr_abs*1e3,curr_sal,curr_temp));

uicontrol(env_group,'style','PushButton','String','Apply Values','callback',{@save_envdata_callback,main_figure},'unit','normalized','position',[0.6 0.05 0.3 0.15]);




setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
update_values([],[],main_figure)
end


% change_soundspeed_cback
% apply_absorption
% save_envdata_callback


function update_values(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
new_sal=str2double(get(calibration_tab_comp.sal,'string'));
if isnan(new_sal)||new_sal<0||new_sal>60
    new_sal=layer.EnvData.Salinity;
end
set(calibration_tab_comp.sal,'string',num2str(new_sal,'%.0f'));

new_temp=str2double(get(calibration_tab_comp.temp,'string'));
if isnan(new_temp)||new_temp<-5||new_temp>90
    new_temp=layer.EnvData.Temperature;
end

set(calibration_tab_comp.temp,'string',num2str(new_temp,'%.1f'));

new_d=str2double(get(calibration_tab_comp.depth,'string'));
if isnan(new_d)||new_temp<0||new_temp>1e5
    new_d=5;
end

if get(calibration_tab_comp.soundspeed_over,'value')==0
    c = seawater_svel_un95(new_sal,new_temp,new_d);
else
    c = str2double(get(calibration_tab_comp.soundspeed,'string'));
    if~(~isnan(c)&&c>=1000&&c<=2000)
        c=layer.EnvData.SoundSpeed;
    end
end
set(calibration_tab_comp.soundspeed,'string',num2str(c,'%.0f'));


if get(calibration_tab_comp.att_over,'value')==0
    att_list=get(calibration_tab_comp.att_model,'String');
    att_model=att_list{get(calibration_tab_comp.att_model,'value')};
    
    if curr_disp.Freq>120000&&strcmp(att_model,'Doonan et al (2003)')
        att_model='Francois & Garrison (1982)';
        set(calibration_tab_comp.att_model,'value',1);
    end
    
    switch att_model
        case 'Doonan et al (2003)'
            alpha = seawater_absorption(curr_disp.Freq/1e3, new_sal, new_temp, new_d,'doonan');
        case 'Francois & Garrison (1982)'
            alpha = seawater_absorption(curr_disp.Freq/1e3, new_sal, new_temp, new_d,'fandg');
    end
else
    alpha=str2double(get(calibration_tab_comp.att,'string'));
    if isnan(alpha)||alpha<0||alpha>200
        alpha=trans_obj.Params.Absorption(1);
    end
    
end

set(calibration_tab_comp.att,'string',num2str(alpha,'%.2f'));

end


function reprocess_TS_calibration(~,~,main_figure)
TS_calibration_curves_func(main_figure);
loadEcho(main_figure);
end

function reprocess_EBA_calibration(~,~,main_figure)
beamwidth_calibration_curves_func(main_figure);
loadEcho(main_figure);
end


function save_envdata_callback(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');

new_sal=str2double(get(calibration_tab_comp.sal,'string'));

layer.EnvData.Salinity=new_sal;

new_temp=str2double(get(calibration_tab_comp.temp,'string'));

layer.EnvData.Temperature=new_temp;

new_ss =str2double(get(calibration_tab_comp.soundspeed,'string'));

layer.apply_soundspeed(new_ss);

new_abs=str2double(get(calibration_tab_comp.att,'string'));

trans_obj.apply_absorption(new_abs/1e3);

set(calibration_tab_comp.string_cal,'string',sprintf('Currently used values:\n Soundspeed: %.1f m/s\n Absorbtion %.2f dB/km\n Salinity %.0f PSU \n Temperature %.1f deg C.\n',...
    new_ss,new_abs,new_sal,new_temp));

update_axis_panel(main_figure,0);
update_calibration_tab(main_figure);
display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_regions(main_figure,'both');
display_survdata_lines(main_figure);
set_alpha_map(main_figure);
order_stacks_fig(main_figure);

setappdata(main_figure,'Layer',layer);
end




function apply_calibration(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
calibration_tab_comp=getappdata(main_figure,'Calibration_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);


if strcmp(trans_obj.Mode,'CW')
    old_cal=trans_obj.get_cal();
    
    if ~isnan(str2double(get(calibration_tab_comp.G0,'string')))
        new_cal.G0=str2double(get(calibration_tab_comp.G0,'string'));
    else
        new_cal.G0=old_cal.G0;
    end
    
    if ~isnan(str2double(get(calibration_tab_comp.SACORRECT,'string')))
        new_cal.SACORRECT=str2double(get(calibration_tab_comp.SACORRECT,'string'));
    else
        new_cal.SACORRECT=old_cal.SACORRECT;
    end
    
    
    trans_obj.apply_cw_cal(new_cal);
    update_calibration_tab(main_figure);
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
