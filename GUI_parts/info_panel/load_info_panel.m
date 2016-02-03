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
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');
types=layer.Transceivers(idx_freq).Data.Type;
type=types{get(display_tab_comp.tog_type,'value')};

if ~isempty(layer.SurveyData)
    i_str=layer.SurveyData.print_survey_data();
else
    i_str='';
end


summary_str=sprintf('%s. Mode: %s Freq: %.0fkHz \nPower: %.0fW Pulse: %.3fms',layer.Filename{1},layer.Transceivers(idx_freq).Mode,curr_disp.Freq/1000,layer.Transceivers(idx_freq).Params.TransmitPower,layer.Transceivers(idx_freq).Params.PulseLength*1e3);
cur_str=sprintf('Cursor mode: %s',curr_disp.CursorMode);



info_panel_comp.summary=uicontrol(info_panel_comp.info_panel,'Style','Text','String',summary_str,'units','normalized','Position',[0.7 0.0 0.3 1],'BackgroundColor',[1 1 1]);
info_panel_comp.i_str=uicontrol(info_panel_comp.info_panel,'Style','Text','String',i_str,'units','normalized','Position',[0.45 0.5 0.25 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.xy_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0 0 0.2 1],'BackgroundColor',[1 1 1]);
info_panel_comp.pos_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.2 0 0.1 1],'BackgroundColor',[1 1 1]);
info_panel_comp.time_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 1],'BackgroundColor',[1 1 1]);
info_panel_comp.value=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.cursor_mode=uicontrol(info_panel_comp.info_panel,'Style','Text','String',cur_str,'units','normalized','Position',[0.45 0 0.1 0.5],'BackgroundColor',[1 1 1]);

setappdata(main_figure,'Info_panel',info_panel_comp);

end

