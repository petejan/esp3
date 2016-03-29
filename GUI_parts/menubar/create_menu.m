function create_menu(main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');

m_files = uimenu(main_figure,'Label','File','Tag','menufile');
uimenu(m_files,'Label','Open file','Callback',{@open_file,0,main_figure});
uimenu(m_files,'Label','Open next file','Callback',{@open_file,1,main_figure});
uimenu(m_files,'Label','Open previous file','Callback',{@open_file,2,main_figure});
uimenu(m_files,'Label','Index Files','Callback',{@index_files_callback,main_figure});


m_bot_reg = uimenu(main_figure,'Label','Bottom/Regions','Tag','menufile');
% m_bot_reg_old = uimenu(m_bot_reg,'Label','Old b-r_files','Tag','menuold');
% uimenu(m_bot_reg_old,'Label','Load Bottom and Regions','Callback',{@load_bottom_reg_old_files_callback,main_figure,1,1});
% uimenu(m_bot_reg_old,'Label','Load Bottom','Callback',{@load_bottom_reg_old_files_callback,main_figure,1,0});
% uimenu(m_bot_reg_old,'Label','Load Regions','Callback',{@load_bottom_reg_old_files_callback,main_figure,0,1});
mcvs = uimenu(m_bot_reg,'Label','CVS','Tag','menucvs');
uimenu(mcvs,'Label','Load Bottom and Regions (if linked to dfile...)','Callback',{@load_bot_reg_callback,main_figure});
uimenu(mcvs,'Label','Load Bottom (if linked to dfile...)','Callback',{@load_bot_callback,main_figure});
uimenu(mcvs,'Label','Load Regions (if linked to dfile...)','Callback',{@load_reg_callback,main_figure});
uimenu(mcvs,'Label','Reload opened Layers CVS Bottom/Regions','Callback',{@reload_cvs_callback,main_figure});
uimenu(mcvs,'Label','Remove opened Layers CVS Bottom/Regions','Callback',{@remove_cvs_callback,main_figure});
uimenu(m_bot_reg,'Label','Save Bottom/Regions to xml','Callback',{@save_bot_reg_xml_callback,main_figure},'separator','on');
uimenu(m_bot_reg,'Label','Save Bottom to xml','Callback',{@save_bot_xml_callback,main_figure});
uimenu(m_bot_reg,'Label','Save Regions to xml','Callback',{@save_reg_xml_callback,main_figure});
uimenu(m_bot_reg,'Label','Load Bottom/Regions from xml','Callback',{@import_bot_regs_from_xml_callback,main_figure,1,1},'separator','on');
uimenu(m_bot_reg,'Label','Load Bottom from xml','Callback',{@import_bot_regs_from_xml_callback,main_figure,1,0});
uimenu(m_bot_reg,'Label','Load Regions from xml','Callback',{@import_bot_regs_from_xml_callback,main_figure,0,1});

mhh = uimenu(main_figure,'Label','Export Results','Tag','menuexport');
%uimenu(mhh,'Label','Export Survey Output to .csv','Callback',{@export_survey_output_callback,main_figure});
uimenu(mhh,'Label','Export Regions per Cells','Callback',{@export_regions,main_figure});
uimenu(mhh,'Label','Export Sv per Cells','Callback',{@export_cells,main_figure});
uimenu(mhh,'Label','Export Tracks','Callback',{@export_tracks_callback,main_figure});
uimenu(mhh,'Label','Export Bottom as .evl','Callback',{@export_bot_as_evl_callback,main_figure});


m_import = uimenu(main_figure,'Label','Import','Tag','menuimport');
uimenu(m_import,'Label','Import Attitude from .csv','Callback',{@import_att_from_csv_callback,main_figure});
uimenu(m_import,'Label','Import Bottom from .evl','Callback',{@import_bot_from_evl_callback,main_figure});
uimenu(m_import,'Label','Import Regions from .evr','Callback',{@import_regs_from_evr_callback,main_figure});
uimenu(m_import,'Label','Import Trawl Line (*.cnv, *.mat,*.evl,*txt)','Callback',{@import_line_callback,main_figure},'separator','on');

m_survey = uimenu(main_figure,'Label','Survey Data','Tag','menu_survey');
uimenu(m_survey,'Label','Reload Survey Data','Callback',{@import_survey_data_callback,main_figure});
uimenu(m_survey,'Label','Edit Voyage Info','Callback',{@edit_trip_info_callback,main_figure});
uimenu(m_survey,'Label','Display logbook','Callback',{@logbook_display_callback,main_figure});


mhhhh = uimenu(main_figure,'Label','Layers','Tag','menulayers');
uimenu(mhhhh,'Label','Display I-file','Callback',{@ifile_display_callback,main_figure});
uimenu(mhhhh,'Label','Re-shuffle Layers','Callback',{@reshuffle_layers_callback,main_figure});
uimenu(mhhhh,'Label','Delete Current Layer','Callback',{@delete_layer_callback,main_figure});

m_map=uimenu(main_figure,'Label','Mapping Tools','Tag','mapping');
uimenu(m_map,'Label','Plot Tracks from current layers','Callback',{@display_multi_navigation_callback,main_figure});
uimenu(m_map,'Label','Plot Tracks from Raw files','Callback',{@plot_gps_track_from_files_callback,main_figure});
uimenu(m_map,'Label','Map from current layers (integrated)','Callback',{@load_map_fig_callback,main_figure},'separator','on');
uimenu(m_map,'Label','Map from MBS result files','Callback',{@map_mbs_scripts_callback,main_figure});
uimenu(m_map,'Label','Map from Survey Output files','Callback',{@map_survey_mat_callback,main_figure});


m_display = uimenu(main_figure,'Label','Display','Tag','menulayers');

m_colormap=uimenu(m_display,'Label','Colormap');
main_menu.colormap=uimenu(m_colormap,'Label','Jet','Callback',{@change_cmap_callback,main_figure},'Tag','jet');
main_menu.colormap=uimenu(m_colormap,'Label','HSV','Callback',{@change_cmap_callback,main_figure},'Tag','hsv');
main_menu.colormap=uimenu(m_colormap,'Label','Esp2','Callback',{@change_cmap_callback,main_figure},'Tag','esp2');

main_menu.show_colorbar=uimenu(m_display,'Label','Show Colorbar','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','col');
main_menu.show_vaxes=uimenu(m_display,'Label','Show Vert Profile','checked','on','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','axv');
main_menu.show_haxes=uimenu(m_display,'Label','Show Horz profile','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','axh');

main_menu.disp_bottom=uimenu(m_display,'checked',curr_disp.DispBottom,'Label','Display bottom');
main_menu.disp_bad_trans=uimenu(m_display,'checked',curr_disp.DispBadTrans,'Label','Display Bad transmits');
main_menu.disp_reg=uimenu(m_display,'checked',curr_disp.DispReg,'Label','Display Regions');
main_menu.disp_tracks=uimenu(m_display,'checked',curr_disp.DispTracks,'Label','Display_tracks');
main_menu.disp_lines=uimenu(m_display,'checked',curr_disp.DispLines,'Label','Display Lines');
main_menu.disp_under_bot=uimenu(m_display,'checked',curr_disp.DispUnderBottom,'Label','Display Under Bottom data');
main_menu.display_file_lines=uimenu(m_display,'checked','off','Label','Display File Lines','Callback',{@checkbox_callback,main_figure,@display_file_lines});
main_menu.reverse_y_axis=uimenu(m_display,'checked','off','Label','Reverse Y-Axis','Callback',{@checkbox_callback,main_figure,@reverse_y_axis});



set([main_menu.disp_tracks main_menu.disp_under_bot main_menu.disp_bottom main_menu.disp_bad_trans main_menu.disp_lines main_menu.disp_reg],'callback',{@set_curr_disp,main_figure});


main_menu.close_all_fig=uimenu(m_display,'Label','Close All External Figures','Callback',{@close_figures_callback,main_figure});

mhhh = uimenu(main_figure,'Label','Tools','Tag','menutools');

reg_tools=uimenu(mhhh,'Label','Regions Tools');
uimenu(reg_tools,'Label','Create WC Region','Callback',{@create_reg_dlbox,main_figure});
uimenu(reg_tools,'Label','Display current region','Callback',{@display_region_callback,main_figure});
uimenu(reg_tools,'Label','Display Mean Depth of current region','Callback',{@plot_mean_aggregation_depth_callback,main_figure});
uimenu(reg_tools,'Label','Classify schools','Callback',{@classify_regions_callback,main_figure});


bs_tools=uimenu(mhhh,'Label','Backscatter Analysis');
uimenu(bs_tools,'Label','Load SVP','Callback',{@load_svp_callback,main_figure});
uimenu(bs_tools,'Label','Execute BS analysis','Callback',{@bs_analysis_callback,main_figure});


curves_tools=uimenu(mhhh,'Label','Curves');
uimenu(curves_tools,'Label','Plot Curves by Tag','Callback',{@plot_curves_callback,main_figure});
uimenu(curves_tools,'Label','Clear Curves','Callback',{@clear_curves_callback,main_figure});

track_tools=uimenu(mhhh,'Label','Track');
uimenu(track_tools,'Label','Plot Frequency response from Tracks','Callback',{@plot_freq_resp_tracks_callback,main_figure});
uimenu(track_tools,'Label','Create Exclude Regions from Tracks','Callback',{@create_regs_from_tracks_callback,'Bad Data',main_figure});


mbs = uimenu(main_figure,'Label','Scripting','Tag','menumbs');
uimenu(mbs,'Label','MBS Scripts','Callback',{@load_mbs_scripts_callback,main_figure});
uimenu(mbs,'Label','Check XML scripts','Callback',{@check_xml_survey_callback,main_figure});
uimenu(mbs,'Label','Integrate Survey(s) from XML','Callback',{@load_xml_survey_callback,main_figure});
uimenu(mbs,'Label','Plot survey results from Survey Output files','Callback',{@plot_survey_results_callback,main_figure});


options = uimenu(main_figure,'Label','Options','Tag','options');
uimenu(options,'Label','Path','Callback',{@load_path_fig,main_figure});
uimenu(options,'Label','Save Current Display Configuration','Callback',{@save_display_config_callback,main_figure});


uitabgroup(main_figure,'Position',[0 .7 0.5 .3],'tag','option_tab_panel');
uitabgroup(main_figure,'Position',[0.5 .7 0.5 .3],'tag','algo_tab_panel');

setappdata(main_figure,'main_menu',main_menu);

end

function change_cmap_callback(src,~,main_fig)
curr_disp=getappdata(main_fig,'Curr_disp');
curr_disp.Cmap=src.Tag;
setappdata(main_fig,'Curr_disp',curr_disp);
end

function load_bottom_reg_old_files_callback(~,~,main_figure,bot,reg)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
[path_f,~]=layer.get_path_files();
folder = uigetdir(path_f{1},'Select folder containing b and r files');
if folder==0
    return
end
layer.load_bottom_regions_from_folder(folder,'bot',bot,'reg',reg);
setappdate(main_figure,'Layer',layer);
update_display(main_figure)

end

function save_display_config_callback(~,~,main_fig)
curr_disp=getappdata(main_fig,'Curr_disp');
write_config_to_xml([],curr_disp);
end

function load_map_fig_callback(~,~,main_fig)
load_map_fig(main_fig,[]);
end

function logbook_display_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
[path_lay,~]=layer.get_path_files();

file=fullfile(path_lay{1},'echo_logbook.csv');
if exist(file,'file')==0
    initialize_echo_logbook_file(path_lay{1});
end

try
    system(sprintf('start notepad++ "%s"',file));
catch
    diap('You should install Notepad++...')
    system(sprintf('start "" "%s"',file));
end

end

function set_curr_disp(src,~,main_figure)
main_menu=getappdata(main_figure,'main_menu');
curr_disp=getappdata(main_figure,'Curr_disp');

switch src
    case main_menu.disp_bad_trans
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispBadTrans='on';
        else
            curr_disp.DispBadTrans='off';
        end
    case main_menu.disp_reg
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispReg='on';
        else
            curr_disp.DispReg='off';
        end
    case main_menu.disp_lines
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispLines='on';
        else
            curr_disp.DispLines='off';
        end
    case main_menu.disp_bottom
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispBottom='on';
        else
            curr_disp.DispBottom='off';
        end
    case main_menu.disp_under_bot
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispUnderBottom='on';
        else
            curr_disp.DispUnderBottom='off';
        end
    case main_menu.disp_tracks
        if strcmp(get(src,'checked'),'off')
            curr_disp.DispTracks='on';
        else
            curr_disp.DispTracks='off';
        end
end

setappdata(main_figure,'Curr_disp',curr_disp);
end



