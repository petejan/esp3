function create_menu(main_figure)

m_files = uimenu(main_figure,'Label','File','Tag','menufile');
uimenu(m_files,'Label','Open file','Callback',{@open_file,0,main_figure});
uimenu(m_files,'Label','Open next file','Callback',{@open_file,1,main_figure});
uimenu(m_files,'Label','Open previous file','Callback',{@open_file,2,main_figure});
uimenu(m_files,'Label','Save Current Bottom/Regions/Algo','Callback',{@save_regions_callback,main_figure},'separator','on');
uimenu(m_files,'Label','Load Previously Saved Bottom/Regions/Algo','Callback',{@load_regions_callback,main_figure});


mhh = uimenu(main_figure,'Label','Import/Export','Tag','menuexport');
uimenu(mhh,'Label','Export Regions per Cells','Callback',{@export_regions,main_figure});
uimenu(mhh,'Label','Export Sv per Cells','Callback',{@export_cells,main_figure});
uimenu(mhh,'Label','Import Attitude from .csv','Callback',{@import_att_from_csv_callback,main_figure},'separator','on');
uimenu(mhh,'Label','Import Bottom from .evl','Callback',{@import_bot_from_evl_callback,main_figure});
uimenu(mhh,'Label','Import Regions from .evr','Callback',{@import_regs_from_evr_callback,main_figure});
uimenu(mhh,'Label','Import Trawl Line (*.cnv, *.mat,*.evl,*txt)','Callback',{@import_line_callback,main_figure},'separator','on');
uimenu(mhh,'Label','Import Survey Data from (.*csv)','Callback',{@import_survey_data_callback,main_figure},'separator','on');


mhhhh = uimenu(main_figure,'Label','MultiLayers','Tag','menulayers');
uimenu(mhhhh,'Label','Delete Current Layer','Callback',{@delete_layer_callback,main_figure});
uimenu(mhhhh,'Label','Reload opened Layers Previously Saved Bottom/Regions','Callback',{@reload_psr_callback,main_figure});
uimenu(mhhhh,'Label','Save opened Layers Bottom/Regions','Callback',{@save_psr_callback,main_figure});
uimenu(mhhhh,'Label','Remove opened Layers Previously Saved Bottom/Regions','Callback',{@remove_psr_callback,main_figure});
uimenu(mhhhh,'Label','Reload opened Layers CVS Bottom/Regions','Callback',{@reload_cvs_callback,main_figure});
uimenu(mhhhh,'Label','Remove opened Layers CVS Bottom/Regions','Callback',{@remove_cvs_callback,main_figure});

m_map=uimenu(main_figure,'Label','Mapping Tools','Tag','mapping');
uimenu(m_map,'Label','Multi Layers Map','Callback',{@load_map_fig_callback,main_figure});
uimenu(m_map,'Label','Map from MBS result files','Callback',{@map_mbs_scripts_callback,main_figure});
uimenu(m_map,'Label','Map from saved MBS result','Callback',{@display_saved_mbs_callback,main_figure});

m_display = uimenu(main_figure,'Label','Display','Tag','menulayers');
main_menu.show_colorbar=uimenu(m_display,'Label','Show Colorbar','Callback',{@set_axes_position_callback,main_figure},'Tag','col');
main_menu.show_vaxes=uimenu(m_display,'Label','Show Vert Profile','checked','on','Callback',{@set_axes_position_callback,main_figure},'Tag','axv');
main_menu.show_haxes=uimenu(m_display,'Label','Show Horz profile','Callback',{@set_axes_position_callback,main_figure},'Tag','axh');
main_menu.close_all_fig=uimenu(m_display,'Label','Close All External Figures','Callback',{@close_figures_callback,main_figure});


mhhh = uimenu(main_figure,'Label','Tools','Tag','menutools');

reg_tools=uimenu(mhhh,'Label','Regions');
uimenu(reg_tools,'Label','Display current region','Callback',{@display_region_callback,main_figure});
uimenu(reg_tools,'Label','Display Mean Depth of current region','Callback',{@plot_mean_aggregation_depth_callback,main_figure});
uimenu(reg_tools,'Label','Classify schools','Callback',{@classify_regions_callback,main_figure});

bs_tools=uimenu(mhhh,'Label','Backscatter Analysis');

uimenu(bs_tools,'Label','Load SVP','Callback',{@load_svp_callback,main_figure});
uimenu(bs_tools,'Label','Execute BS analysis','Callback',{@bs_analysis_callback,main_figure});

mcvs = uimenu(main_figure,'Label','CVS','Tag','menucvs');
uimenu(mcvs,'Label','Load Bottom and Regions (if linked to dfile...)','Callback',{@load_bot_reg_callback,main_figure});
uimenu(mcvs,'Label','Load Bottom (if linked to dfile...)','Callback',{@load_bot_callback,main_figure});
uimenu(mcvs,'Label','Load Regions (if linked to dfile...)','Callback',{@load_reg_callback,main_figure});

mbs = uimenu(main_figure,'Label','MBSing','Tag','menumbs');
uimenu(mbs,'Label','MBS Scripts','Callback',{@load_mbs_scripts_callback,main_figure});



curves_tools=uimenu(mhhh,'Label','Curves');
uimenu(curves_tools,'Label','Plot Curves by Tag','Callback',{@plot_curves_callback,main_figure});
uimenu(curves_tools,'Label','Clear Curves','Callback',{@clear_curves_callback,main_figure});

track_tools=uimenu(mhhh,'Label','Track');
uimenu(track_tools,'Label','Plot Frequency response from Tracks','Callback',{@plot_freq_resp_tracks_callback,main_figure});

surveyInfo = uimenu(main_figure,'Label','Survey','Tag','fileinfo');
uimenu(surveyInfo,'Label','Display I-file','Callback',{@ifile_display_callback,main_figure});
uimenu(surveyInfo,'Label','Edit Survey Data','Callback',{@edit_survey_info_callback,main_figure});


options = uimenu(main_figure,'Label','Options','Tag','options');
uimenu(options,'Label','Path','Callback',{@load_path_fig,main_figure});



uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');

setappdata(main_figure,'main_menu',main_menu);

end

function load_map_fig_callback(~,~,main_fig)
load_map_fig(main_fig,[]);
end



function save_regions_callback(~,~,main_figure)  
    layer=getappdata(main_figure,'Layer');
    layer.save_regs();
end


function load_regions_callback(~,~,main_figure)  
    layer=getappdata(main_figure,'Layer');
    layer.load_regs();
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,0);
end
