function load_calibration_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Calibration_tab')
    calibration_tab_comp=getappdata(main_figure,'Calibration_tab');
    delete(calibration_tab_comp.calibration_tab);
    rmappdata(main_figure,'Calibration_tab');
end

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
calibration_tab_comp.calibration_tab=uitab(option_tab_panel,'Title','Calibration');

if ~strcmp(layer.Filetype,'CREST')
    if strcmp(layer.Transceivers(idx_freq).Mode,'CW')
        cal_cw=get_cal(layer.Transceivers(idx_freq));
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String',sprintf('Current Frequency: %.0fkHz',curr_disp.Freq/1e3),'units','normalized','Position',[0.1 0.85 0.3 0.1]);
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Gain (dB)','units','normalized','Position',[0.1 0.7 0.2 0.1]);
        calibration_tab_comp.G0=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.7 0.1 0.1],'string',num2str(cal_cw.G0,'%.2f'),'callback',{@apply_calibration,main_figure});
        
        uicontrol(calibration_tab_comp.calibration_tab,'Style','Text','String','Sa Corr (dB)','units','normalized','Position',[0.1 0.55 0.2 0.1]);
        calibration_tab_comp.SACORRECT=uicontrol(calibration_tab_comp.calibration_tab,'style','edit','unit','normalized','position',[0.3 0.55 0.1 0.1],'string',num2str(cal_cw.SACORRECT,'%.2f'),'callback',{@apply_calibration,main_figure});
        
        
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Save','callback',{@save_CW_calibration,main_figure},'unit','normalized','position',[0.8 0.1 0.15 0.2]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Reprocess','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0.55 0.1 0.15 0.2]);
    else
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Display Calibration Curves','callback',{@display_cal,main_figure},'unit','normalized','position',[0.1 0.7 0.2 0.2]);
         
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process TS Cal','callback',{@reprocess_TS_calibration,main_figure},'unit','normalized','position',[0.80 0.1 0.15 0.2]);
        uicontrol(calibration_tab_comp.calibration_tab,'style','PushButton','String','Process EBA Cal','callback',{@reprocess_EBA_calibration,main_figure},'unit','normalized','position',[0.55 0.1 0.15 0.2]);
        
    end
end


setappdata(main_figure,'Calibration_tab',calibration_tab_comp);
end


function reprocess_TS_calibration(~,~,main_figure)
reset_mode([],[],main_figure)
set(main_figure,'WindowButtonDownFcn',{@TS_calibration_curves,main_figure});
end

function reprocess_EBA_calibration(~,~,main_figure)
reset_mode([],[],main_figure)
set(main_figure,'WindowButtonDownFcn',{@beamwidth_calibration_curves,main_figure});
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
update_display(main_figure,0);

end

function save_CW_calibration(~,~,main_figure)
apply_calibration([],[],main_figure);
layer=getappdata(main_figure,'Layer');

[~,cal_path,~]=fileparts(layer.Filename{1});

fid=fopen(fullfile(cal_path,'cal_echo.csv'),'w+');
fprintf(fid,'%s,%s,%s\n', 'F', 'G0', 'SACORRECT');
for i=1:length(layer.Transceivers)
    cal_cw=get_cal(layer.Transceivers(i));
    fprintf(fid,'%.0f,%.2f,%.2f\n',layer.Frequencies(i),cal_cw.G0,cal_cw.SACORRECT);
end
fclose(fid);

end
