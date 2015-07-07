function initialize_display(main_figure)

mh = uimenu(main_figure,'Label','File','Tag','menufile');
uimenu(mh,'Label','Open file','Callback',{@open_file,0,main_figure});
uimenu(mh,'Label','Open next file','Callback',{@open_file,1,main_figure});
uimenu(mh,'Label','Open previous file','Callback',{@open_file,2,main_figure});
uimenu(mh,'Label','Save as default config','Callback',{@save_default,main_figure});

mhh = uimenu(main_figure,'Label','Export','Tag','menuexport');
uimenu(mhh,'Label','Export Regions per Cells','Callback',{@export_regions,main_figure});
uimenu(mhh,'Label','Export Sv per Cells','Callback',{@export_cells,main_figure});

mhhh = uimenu(main_figure,'Label','Tools','Tag','menutools');
reg_tools=uimenu(mhhh,'Label','Regions');

uimenu(reg_tools,'Label','Display current region','Callback',{@display_region_callback,main_figure});
uimenu(reg_tools,'Label','Display current region','Callback',{@plot_mean_aggregation_depth_callback,main_figure});


uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');


axes_panel_comp.axes_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0.05 1 .65],'BackgroundColor',[1 1 1],'tag','axes_panel');
axes_panel_comp.main_axes=axes('Parent', axes_panel_comp.axes_panel,'FontSize',14,'Units','normalized',...
    'Position',[0 0 1 1],...
    'TickDir','in');
info_panel_comp.info_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0 1 .05],'BackgroundColor',[1 1 1],'tag','axes_panel');


setappdata(main_figure,'Axes_panel',axes_panel_comp);
setappdata(main_figure,'Info_panel',info_panel_comp);

set(main_figure,'Visible','on');
end




function save_default(~,~,main_figure)
    app_path=getappdata(main_figure,'App_path');
    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    save([app_path.data 'data_default.mat'],'layer','curr_disp');
end