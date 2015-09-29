function create_menu(main_figure)

mh = uimenu(main_figure,'Label','File','Tag','menufile');
uimenu(mh,'Label','Open file','Callback',{@open_file,0,main_figure});
uimenu(mh,'Label','Open next file','Callback',{@open_file,1,main_figure});
uimenu(mh,'Label','Open previous file','Callback',{@open_file,2,main_figure});
%uimenu(mh,'Label','Save as default config','Callback',{@save_default,main_figure});

mhh = uimenu(main_figure,'Label','Export','Tag','menuexport');
uimenu(mhh,'Label','Export Regions per Cells','Callback',{@export_regions,main_figure});
uimenu(mhh,'Label','Export Sv per Cells','Callback',{@export_cells,main_figure});

mhhhh = uimenu(main_figure,'Label','Layers','Tag','menulayers');
uimenu(mhhhh,'Label','Display opened Layer Navigation','Callback',{@display_layers_nav_callback,main_figure});
uimenu(mhhhh,'Label','Delete Current Layer','Callback',{@delete_layer_callback,main_figure});

m_display = uimenu(main_figure,'Label','Display','Tag','menulayers');
% main_menu.show_xaxes=uimenu(m_display,'Label','Show X Axes','Callback',{@set_axes_position_callback,main_figure},'Tag','axx');
% main_menu.show_yaxes=uimenu(m_display,'Label','Show Y Axes','Callback',{@set_axes_position_callback,main_figure},'Tag','axy');
main_menu.show_colorbar=uimenu(m_display,'Label','Show Colorbar','Callback',{@set_axes_position_callback,main_figure},'Tag','col');
main_menu.show_vaxes=uimenu(m_display,'Label','Show Vert Profile','Callback',{@set_axes_position_callback,main_figure},'Tag','axv');
main_menu.show_haxes=uimenu(m_display,'Label','Show Horz profile','Callback',{@set_axes_position_callback,main_figure},'Tag','axh');
main_menu.close_all_fig=uimenu(m_display,'Label','Close All External Figures','Callback',{@close_figures_callback,main_figure});


mhhh = uimenu(main_figure,'Label','Tools','Tag','menutools');
reg_tools=uimenu(mhhh,'Label','Regions');

curves_tools=uimenu(mhhh,'Label','Curves');


uimenu(reg_tools,'Label','Display current region','Callback',{@display_region_callback,main_figure});
uimenu(reg_tools,'Label','Display Mean Depth of current region','Callback',{@plot_mean_aggregation_depth_callback,main_figure});
uimenu(reg_tools,'Label','Classify schools','Callback',{@classify_regions,main_figure});

bs_tools=uimenu(mhhh,'Label','Backscatter Analysis');

uimenu(bs_tools,'Label','Load SVP','Callback',{@load_svp_callback,main_figure});
uimenu(bs_tools,'Label','Execute BS analysis','Callback',{@bs_analysis_callback,main_figure});



mcvs = uimenu(main_figure,'Label','CVS','Tag','menucvs');
uimenu(mcvs,'Label','Load Bottom and Regions (if linked to dfile...)','Callback',{@load_bot_reg_callback,main_figure});
uimenu(mcvs,'Label','Load Bottom (if linked to dfile...)','Callback',{@load_bot_callback,main_figure});
uimenu(mcvs,'Label','Load Regions (if linked to dfile...)','Callback',{@load_reg_callback,main_figure});
uimenu(mcvs,'Label','MBS Scripts','Callback',{@load_mbs_scripts_callback,main_figure});

fileinfo = uimenu(main_figure,'Label','Info','Tag','filinfo');
uimenu(fileinfo,'Label','Display I-file','Callback',{@ifile_display_callback,main_figure});


track_tools=uimenu(mhhh,'Label','Track');
uimenu(curves_tools,'Label','Plot Curves by Tag','Callback',{@plot_curves_callback,main_figure});
uimenu(curves_tools,'Label','Clear Curves','Callback',{@clear_curves_callback,main_figure});

uimenu(track_tools,'Label','Plot Frequency response from Tracks','Callback',{@plot_freq_resp_tracks_callback,main_figure});


uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');

setappdata(main_figure,'main_menu',main_menu);

end


function save_default(~,~,main_figure)
    app_path=getappdata(main_figure,'App_path');
    layer=getappdata(main_figure,'Layer');
    curr_disp=getappdata(main_figure,'Curr_disp');
    save([app_path.data 'data_default.mat'],'layer','curr_disp');
end