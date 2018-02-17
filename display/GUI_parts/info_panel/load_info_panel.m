function load_info_panel(main_figure)

if isappdata(main_figure,'Info_panel')
    info_panel_comp=getappdata(main_figure,'Info_panel');
    delete(get(info_panel_comp.info_panel,'children'));
else
   info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','info_panel','visible','on');
end

info_panel_comp.summary=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.7 0.0 0.3 1],'BackgroundColor',[1 1 1]);
info_panel_comp.i_str=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.45 0.5 0.25 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.xy_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0 0 0.2 1],'BackgroundColor',[1 1 1]);
info_panel_comp.pos_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.2 0 0.1 1],'BackgroundColor',[1 1 1]);
info_panel_comp.time_disp=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 1],'BackgroundColor',[1 1 1]);
info_panel_comp.value=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.3 0 0.15 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.cursor_mode=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.45 0 0.15 0.5],'BackgroundColor',[1 1 1]);
info_panel_comp.display_subsampling=uicontrol(info_panel_comp.info_panel,'Style','Text','String','','units','normalized','Position',[0.6 0 0.15 0.5],'BackgroundColor',[1 1 1]);

% info_panel.proc_axes=axes('parent',info_panel_comp.info_panel,'Units','normalized','Position',[0 0 0.05 1],'Visible','off');
% imshow(fullfile(whereisEcho(),'icons','done.png'));
setappdata(main_figure,'Info_panel',info_panel_comp);
display_info_ButtonMotionFcn([],[],main_figure,1)
end

