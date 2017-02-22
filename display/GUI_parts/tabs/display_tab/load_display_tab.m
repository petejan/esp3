function load_display_tab(main_figure,option_tab_panel)


display_tab_comp.display_tab=uitab(option_tab_panel,'Title','Display Option');

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Frequency','units','normalized','Position',[0 0.8 0.2 0.1]);
display_tab_comp.tog_freq=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.2 0.8 0.12 0.1],...
    'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Data','units','normalized','Position',[0 0.6 0.2 0.1]);
display_tab_comp.tog_type=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.2 0.6 0.12 0.1],...
    'Callback',{@choose_field,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','X Axes:','units','normalized','Position',[0.35 0.8 0.1 0.1]);
display_tab_comp.tog_axes=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.45 0.8 0.2 0.1],...
    'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Grid:','units','normalized','Position',[0.35 0.6 0.05 0.1]);
display_tab_comp.grid_x=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.4 0.6 0.05 0.1],'string',num2str(0,'%.0f'));
display_tab_comp.grid_x_unit=uicontrol(display_tab_comp.display_tab,'Style','Text','unit','normalized','position',[0.45 0.6 0.04 0.1],'string','');
uicontrol(display_tab_comp.display_tab,'Style','Text','String','X','units','normalized','Position',[0.49 0.6 0.02 0.1]);
display_tab_comp.grid_y=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.51 0.6 0.05 0.1],'string',num2str(0,'%.0f'));
display_tab_comp.grid_y_unit=uicontrol(display_tab_comp.display_tab,'Style','Text','unit','normalized','position',[0.56 0.6 0.04 0.1],'string','(m)');
set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})

cax=[0 1];

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Max','units','normalized','Position',[0.7 0.8 0.15 0.1]);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Min','units','normalized','Position',[0.7 0.6 0.15 0.1]);

display_tab_comp.caxis_up=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.85 0.8 0.05 0.1],'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.85 0.6 0.05 0.1],'string',cax(1));
set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Att.','units','normalized','pos',[0.8725 0.25 0.1 0.15],'callback',{@display_attitude_cback,main_figure});
uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Nav.','units','normalized','pos',[0.8725 0.1 0.1 0.15],'callback',{@display_navigation_callback,main_figure});

set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Display_tab',display_tab_comp);


end
