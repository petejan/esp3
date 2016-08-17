function load_info_panel(main_figure)

info_panel_comp=getappdata(main_figure,'Info_panel');

if isappdata(main_figure,'Info_panel')
    info_panel_comp=getappdata(main_figure,'Info_panel');
    delete(info_panel_comp.info_panel);
    rmappdata(main_figure,'Info_panel');
end

if isempty(info_panel_comp)
    info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');
end


layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');

if ~isempty(layer.get_survey_data())
    i_str=layer.get_survey_data().print_survey_data();
else
    i_str='';
end

[~,file_curr,~]=fileparts(layer.Filename{1});

summary_str=sprintf('%s. Mode: %s Freq: %.0fkHz \nPower: %.0fW Pulse: %.3fms',file_curr,layer.Transceivers(idx_freq).Mode,curr_disp.Freq/1000,layer.Transceivers(idx_freq).Params.TransmitPower(1),layer.Transceivers(idx_freq).Params.PulseLength(1)*1e3);

cur_str=sprintf('Cursor mode: %s',curr_disp.CursorMode);


info_panel_comp.summary=uicontrol(info_panel_comp.info_panel,'Style','Text','String',summary_str,'units','normalized','Position',[0.7 0.0 0.3 1],'BackgroundColor',[1 1 1]);
info_panel_comp.i_str=uicontrol(info_panel_comp.info_panel,'Style','Text','String',i_str,'units','normalized','Position',[0.45 0.5 0.25 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.xy_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0 0 0.2 1],'BackgroundColor',[1 1 1]);
info_panel_comp.pos_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.2 0 0.1 1],'BackgroundColor',[1 1 1]);
info_panel_comp.time_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 1],'BackgroundColor',[1 1 1]);
info_panel_comp.value=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.cursor_mode=uicontrol(info_panel_comp.info_panel,'Style','Text','String',cur_str,'units','normalized','Position',[0.45 0 0.15 0.5],'BackgroundColor',[1 1 1]);

% info_panel.proc_axes=axes('parent',info_panel_comp.info_panel,'Units','normalized','Position',[0 0 0.05 1],'Visible','off');
% imshow(fullfile(whereisEcho(),'icons','done.png'));


setappdata(main_figure,'Info_panel',info_panel_comp);
end

