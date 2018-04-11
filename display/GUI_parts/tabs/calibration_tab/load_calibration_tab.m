function load_calibration_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Calibration_tab')
    calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
    delete(get(calibration_tab_comp.calibration_tab,'children'));
else
    calibration_tab_comp.calibration_tab=uitab(option_tab_panel,'Title','Calibration');
end

curr_disp=getappdata(main_figure,'Curr_disp');

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(6,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);
p_button=pos{5,1}{1};
p_button(3)=gui_fmt.button_w*7/4;

envdata=env_data_cl();

curr_sal=envdata.Salinity;
curr_temp=envdata.Temperature;
curr_ss=envdata.SoundSpeed;
curr_abs=10/1e3;
calibration_tab_comp.cal_group=uipanel(calibration_tab_comp.calibration_tab,'Position',[0 0.0 0.5 1],'title','Calibration','units','norm','BackgroundColor','white');

calibration_tab_comp.calibration_txt=uicontrol(calibration_tab_comp.cal_group,gui_fmt.txtTitleStyle,...
    'String',sprintf('Current Channel: %.0f kHz',curr_disp.Freq/1e3),'Position',pos{1,1}{1}+[0 0 gui_fmt.txt_w 0]);

uicontrol(calibration_tab_comp.cal_group,gui_fmt.txtStyle,'String','Gain (dB)','Position',pos{2,1}{1});
calibration_tab_comp.G0=uicontrol(calibration_tab_comp.cal_group,gui_fmt.edtStyle,'position',pos{2,1}{2},'string','25.00','callback',{@apply_calibration,main_figure},'enable','off');

uicontrol(calibration_tab_comp.cal_group,gui_fmt.txtStyle,'String','Sa Corr (dB)','Position',pos{3,1}{1});
calibration_tab_comp.SACORRECT=uicontrol(calibration_tab_comp.cal_group,gui_fmt.edtStyle,'position',pos{3,1}{2},'string','0.00','callback',{@apply_calibration,main_figure},'enable','off');

%         uicontrol(calibration_tab_comp.cal_group,gui_fmt.txtStyle,'String','ES Corr (dB)','Position',pos{4,1}{1});
%         calibration_tab_comp.EsOffset=uicontrol(calibration_tab_comp.cal_group,gui_fmt.edtStyle,'position',pos{4,1}{2},'string',num2str(trans_obj.Config.EsOffset,'%.2f'),'callback',{@apply_triangle_wave_corr_cback,main_figure});
%
%         if trans_obj.need_escorr()==0
%             set(calibration_tab_comp.EsOffset,'Enable','off');
%         end

uicontrol(calibration_tab_comp.cal_group,gui_fmt.pushbtnStyle,'String','Process TS Cal','callback',{@reprocess_TS_calibration,main_figure},'position',p_button);
calibration_tab_comp.fm_proc(2)=uicontrol(calibration_tab_comp.cal_group,gui_fmt.pushbtnStyle,'String','Process EBA Cal','callback',{@reprocess_EBA_calibration,main_figure},'position',p_button+[p_button(3) 0 0 0]);
calibration_tab_comp.cw_proc(1)=uicontrol(calibration_tab_comp.cal_group,gui_fmt.pushbtnStyle,'String','Save CW  Cal','callback',{@save_CW_calibration,main_figure},'position',p_button+[0 -gui_fmt.box_h 0 0]);
calibration_tab_comp.fm_proc(1)=uicontrol(calibration_tab_comp.cal_group,gui_fmt.pushbtnStyle,'String','Disp. FM Cal.','callback',{@display_cal,main_figure},'position',p_button+[p_button(3) -gui_fmt.box_h 0 0]);

calibration_tab_comp.sphere=uicontrol(calibration_tab_comp.cal_group,gui_fmt.txtStyle,'string','Sphere:','position',pos{4,1}{1});
calibration_tab_comp.sphere=uicontrol(calibration_tab_comp.cal_group,gui_fmt.popumenuStyle,'string',list_spheres(),'position',pos{4,1}{2}+[0 0 gui_fmt.txt_w 0]);

%%%%%%Environnement%%%%%%
p_button=pos{6,2}{1}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0];
p_button(3)=gui_fmt.button_w*3/2;
calibration_tab_comp.env_group=uipanel(calibration_tab_comp.calibration_tab,'Position',[0.5 0.0 0.5 1],'title','Environment','units','norm','BackgroundColor','white');

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'string','Model:','position',pos{1,1}{1});

calibration_tab_comp.att_model=uicontrol(calibration_tab_comp.env_group,gui_fmt.popumenuStyle,'string',{'Doonan et al (2003)' 'Francois & Garrison (1982)'},...
    'position',pos{1,1}{1}+[0 0 gui_fmt.txt_w 0],'callback',{@update_values,main_figure});

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'String','Depth(m)','Position',pos{2,1}{1});
calibration_tab_comp.depth=uicontrol(calibration_tab_comp.env_group,gui_fmt.edtStyle,'position',pos{2,1}{2},'string',num2str(5,'%.0f'),'callback',{@update_values,main_figure});

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'String','SS(m/s)','Position',pos{5,1}{1});
calibration_tab_comp.soundspeed=uicontrol(calibration_tab_comp.env_group,gui_fmt.edtStyle,'position',pos{5,1}{2},'string',num2str(curr_ss,'%.0f'),'callback',{@update_values,main_figure});
calibration_tab_comp.soundspeed_over=uicontrol(calibration_tab_comp.env_group,gui_fmt.chckboxStyle,'position',pos{5,1}{2}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0],'callback',{@update_values,main_figure});

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'String','Att.(dB/km)','Position',pos{6,1}{1});
calibration_tab_comp.att=uicontrol(calibration_tab_comp.env_group,gui_fmt.edtStyle,'position',pos{6,1}{2},'string',num2str(curr_abs*1e3,'%.1f'),'callback',{@update_values,main_figure});
calibration_tab_comp.att_over=uicontrol(calibration_tab_comp.env_group,gui_fmt.chckboxStyle,'position',pos{6,1}{2}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0],'callback',{@update_values,main_figure});

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'String',sprintf('Temp.(%cC)',char(hex2dec('00BA'))),'Position',pos{3,1}{1});
calibration_tab_comp.temp=uicontrol(calibration_tab_comp.env_group,gui_fmt.edtStyle,'position',pos{3,1}{2},'string',num2str(curr_temp,'%.1f'),'callback',{@update_values,main_figure});

uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'String','Salinity.(PSU)','Position',pos{4,1}{1});
calibration_tab_comp.sal=uicontrol(calibration_tab_comp.env_group,gui_fmt.edtStyle,'position',pos{4,1}{2},'string',num2str(curr_sal,'%.0f'),'callback',{@update_values,main_figure});

calibration_tab_comp.string_cal=uicontrol(calibration_tab_comp.env_group,gui_fmt.txtStyle,'position',pos{2,2}{1}+[0 -3*(gui_fmt.txt_h) gui_fmt.box_w*2 3*(gui_fmt.txt_h)],...
    'string',sprintf('Currently used values:\n Soundspeed: %.1f m/s\n Absorbtion %.2f dB/km',...
    curr_ss,curr_abs*1e3),'HorizontalAlignment','left');

uicontrol(calibration_tab_comp.env_group,gui_fmt.pushbtnStyle,'String','Apply Values','callback',{@save_envdata_callback,main_figure},'position',p_button);



setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
update_values([],[],main_figure)
end


% change_soundspeed_cback
% apply_absorption
% save_envdata_callback


function update_values(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if ~isempty(layer)
    [trans_obj,~]=layer.get_trans(curr_disp);
    envdata=layer.EnvData;
else
    envdata=env_data_cl();
    trans_obj=[];
end

calibration_tab_comp=getappdata(main_figure,'Calibration_tab');

new_sal=str2double(get(calibration_tab_comp.sal,'string'));
if isnan(new_sal)||new_sal<0||new_sal>60
    new_sal=envdata.Salinity;
end
set(calibration_tab_comp.sal,'string',num2str(new_sal,'%.0f'));

new_temp=str2double(get(calibration_tab_comp.temp,'string'));
if isnan(new_temp)||new_temp<-5||new_temp>90
    new_temp=envdata.Temperature;
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
        c=envdata.SoundSpeed;
    end
end
set(calibration_tab_comp.soundspeed,'string',num2str(c,'%.0f'));


if get(calibration_tab_comp.att_over,'value')==0||isempty(trans_obj)
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
layer=getappdata(main_figure,'Layer');
if ~isempty(layer)
    TS_calibration_curves_func(main_figure);
end
end

function reprocess_EBA_calibration(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if ~isempty(layer)
    beamwidth_calibration_curves_func(main_figure);
end
end


function save_envdata_callback(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if ~isempty(layer)
    [trans_obj,~]=layer.get_trans(curr_disp);
    calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
    
    new_sal=str2double(get(calibration_tab_comp.sal,'string'));
    
    layer.EnvData.Salinity=new_sal;
    
    new_temp=str2double(get(calibration_tab_comp.temp,'string'));
    
    layer.EnvData.Temperature=new_temp;
    
    new_ss =str2double(get(calibration_tab_comp.soundspeed,'string'));
    if new_ss~=layer.EnvData.SoundSpeed
        fprintf('   Old Soundspeed value: %.0f m/s\n',layer.EnvData.SoundSpeed);
        layer.apply_soundspeed(new_ss);
    end
    
    new_abs=str2double(get(calibration_tab_comp.att,'string'));
    
    trans_obj.apply_absorption(new_abs/1e3);
    
    set(calibration_tab_comp.string_cal,'string',sprintf('Currently used values:\n Soundspeed: %.1f m/s\n Absorbtion %.2f dB/km\n',...
        new_ss,new_abs));
    
    update_axis_panel(main_figure,0);
    update_secondary_freq_win(main_figure);
    update_mini_ax(main_figure,0);
    % update_calibration_tab(main_figure);
    % display_bottom(main_figure);
    % display_tracks(main_figure);
    % display_file_lines(main_figure);
    % display_regions(main_figure,'both');
    % display_survdata_lines(main_figure);
    set_alpha_map(main_figure);
    order_stacks_fig(main_figure);
    
    setappdata(main_figure,'Layer',layer);
end
end




function apply_calibration(~,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if ~isempty(layer)
    calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
    
    [trans_obj,~]=layer.get_trans(curr_disp);
    
    
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
    
    update_axis_panel(main_figure,0);
    update_secondary_freq_win(main_figure);
    update_mini_ax(main_figure,0);
    % update_calibration_tab(main_figure);
    % display_bottom(main_figure);
    % display_tracks(main_figure);
    % display_file_lines(main_figure);
    % display_regions(main_figure,'both');
    % display_survdata_lines(main_figure);
    set_alpha_map(main_figure);
    order_stacks_fig(main_figure);
end
end



function save_CW_calibration(~,~,main_figure)
apply_calibration([],[],main_figure);
layer=getappdata(main_figure,'Layer');
if ~isempty(layer)
    [cal_path,~,~]=fileparts(layer.Filename{1});
    
    fid=fopen(fullfile(cal_path,'cal_echo.csv'),'w');
    fprintf(fid,'%s,%s,%s,%s\n', 'F', 'G0', 'SACORRECT','alpha');
    for i=1:length(layer.Transceivers)
        cal_cw=get_cal(layer.Transceivers(i));
        fprintf(fid,'%.0f,%.2f,%.2f,%.2f\n',layer.Frequencies(i),cal_cw.G0,cal_cw.SACORRECT,layer.Transceivers(i).Params.Absorption(1)*1e3);
    end
    fclose(fid);
end
end
