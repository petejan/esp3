function load_info_panel(main_figure)

info_panel_comp=getappdata(main_figure,'Info_panel');

if isappdata(main_figure,'Info_panel')
    info_panel_comp=getappdata(main_figure,'Info_panel');
    delete(info_panel_comp.info_panel);
    rmappdata(main_figure,'Info_panel');
end

if ~isempty(info_panel_comp)
    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');
    
    
    if iscell(layer.Filename)
        summary_str=(sprintf('%s: %s. Mode: %s Freq: %.0fkHz',curr_disp.Fieldname,layer.Filename{1},layer.Transceivers(idx_freq).Mode,curr_disp.Freq/1000));
    else
        summary_str=(sprintf('%s: %s. Mode: %s Freq: %.0fkHz',curr_disp.Fieldname,layer.Filename,layer.Transceivers(idx_freq).Mode,curr_disp.Freq/1000));
    end
    
    info_panel_comp.summary=uicontrol(info_panel_comp.info_panel,'Style','Text','String',summary_str,'units','normalized','Position',[0.7 0 0.3 1],'BackgroundColor',[1 1 1]);
    info_panel_comp.xy_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0 0 0.1 1],'BackgroundColor',[1 1 1]);
    info_panel_comp.pos_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.1 0 0.2 1],'BackgroundColor',[1 1 1]);
    info_panel_comp.time_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.1 1],'BackgroundColor',[1 1 1]);
    info_panel_comp.value=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.4 0 0.2 1],'BackgroundColor',[1 1 1]   );
    
    setappdata(main_figure,'Info_panel',info_panel_comp);
end
end

