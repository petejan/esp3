function initialize_display(main_figure)
create_menu(main_figure);

axes_panel_comp.axes_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0.05 1 .65],'BackgroundColor',[1 1 1],'tag','axes_panel');
axes_panel_comp.main_axes=axes('Parent', axes_panel_comp.axes_panel,'FontSize',14,'Units','normalized',...
    'Position',[0 0 1 1],...
    'TickDir','in');

info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');


setappdata(main_figure,'Axes_panel',axes_panel_comp);
setappdata(main_figure,'Info_panel',info_panel_comp);

set(main_figure,'Visible','on');
end



