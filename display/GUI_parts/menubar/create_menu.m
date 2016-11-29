function create_menu(main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');

m_files = uimenu(main_figure,'Label','File(s)','Tag','menufile');
uimenu(m_files,'Label','Open file','Callback',{@open_file,0,main_figure});
uimenu(m_files,'Label','Open next file','Callback',{@open_file,1,main_figure});
uimenu(m_files,'Label','Open previous file','Callback',{@open_file,2,main_figure});
uimenu(m_files,'Label','Reload Current file(s)','Callback',{@reload_file,main_figure});
uimenu(m_files,'Label','Index Files','Callback',{@index_files_callback,main_figure});
uimenu(m_files,'Label','Clean temp. files','Callback',{@clean_temp_files_callback,main_figure});

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

eport_menu = uimenu(main_figure,'Label','Export','Tag','menuexport');
uimenu(eport_menu,'Label','Save Echogramm','Callback',{@save_echo_callback,main_figure});



m_import = uimenu(main_figure,'Label','Import','Tag','menuimport');
uimenu(m_import,'Label','Import Attitude from .csv','Callback',{@import_att_from_csv_callback,main_figure});
uimenu(m_import,'Label','Import Bottom from .evl','Callback',{@import_bot_from_evl_callback,main_figure});
uimenu(m_import,'Label','Import Regions from .evr','Callback',{@import_regs_from_evr_callback,main_figure});
uimenu(m_import,'Label','Import Trawl Line (*.cnv, *.mat,*.evl,*txt)','Callback',{@import_line_callback,main_figure},'separator','on');

m_survey = uimenu(main_figure,'Label','Survey Data','Tag','menu_survey');
uimenu(m_survey,'Label','Reload Survey Data','Callback',{@import_survey_data_callback,main_figure});
uimenu(m_survey,'Label','Edit Voyage Info','Callback',{@edit_trip_info_callback,main_figure});
%uimenu(m_survey,'Label','Display logbook (In Browser)','Callback',{@logbook_display_callback,main_figure});
uimenu(m_survey,'Label','Edit/Display logbook','Callback',{@logbook_dispedit_callback,main_figure});
%uimenu(m_survey,'Label','Convert Csv Logbook to Xml (current layer)','Callback',{@convert_csv_logbook_to_xml_callback,main_figure});
uimenu(m_survey,'Label','Look for new files in current folder','Callback',{@look_for_new_files_callback,main_figure})


mhhhh = uimenu(main_figure,'Label','Layers','Tag','menulayers');
uimenu(mhhhh,'Label','Display I-file','Callback',{@ifile_display_callback,main_figure});
uimenu(mhhhh,'Label','Re-shuffle Layers','Callback',{@reshuffle_layers_callback,main_figure});
uimenu(mhhhh,'Label','Delete Current Layer','Callback',{@delete_layer_callback,main_figure})
uimenu(mhhhh,'Label','Reload Current Layer','Callback',{@reload_current_layer_callback,main_figure});

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
main_menu.colormap=uimenu(m_colormap,'Label','Hot','Callback',{@change_cmap_callback,main_figure},'Tag','hot');
main_menu.colormap=uimenu(m_colormap,'Label','Cool','Callback',{@change_cmap_callback,main_figure},'Tag','cool');
main_menu.colormap=uimenu(m_colormap,'Label','Parula','Callback',{@change_cmap_callback,main_figure},'Tag','parula');
main_menu.colormap=uimenu(m_colormap,'Label','Autumn','Callback',{@change_cmap_callback,main_figure},'Tag','autumn');
main_menu.colormap=uimenu(m_colormap,'Label','Winter','Callback',{@change_cmap_callback,main_figure},'Tag','winter');
main_menu.colormap=uimenu(m_colormap,'Label','Spring','Callback',{@change_cmap_callback,main_figure},'Tag','spring');
main_menu.colormap=uimenu(m_colormap,'Label','Esp2','Callback',{@change_cmap_callback,main_figure},'Tag','esp2');
main_menu.colormap=uimenu(m_colormap,'Label','EK500','Callback',{@change_cmap_callback,main_figure},'Tag','ek500');

main_menu.show_colorbar=uimenu(m_display,'Label','Show Colorbar','checked','on','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','col');
main_menu.show_vaxes=uimenu(m_display,'Label','Show Vert Profile','checked','on','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','axv');
main_menu.show_haxes=uimenu(m_display,'Label','Show Horz profile','Callback',{@checkbox_callback,main_figure,@set_axes_position},'Tag','axh');

main_menu.disp_bottom=uimenu(m_display,'checked',curr_disp.DispBottom,'Label','Display bottom');
main_menu.disp_bad_trans=uimenu(m_display,'checked',curr_disp.DispBadTrans,'Label','Display Bad transmits');
main_menu.disp_reg=uimenu(m_display,'checked',curr_disp.DispReg,'Label','Display Regions');
main_menu.disp_tracks=uimenu(m_display,'checked',curr_disp.DispTracks,'Label','Display_tracks');
main_menu.disp_lines=uimenu(m_display,'checked',curr_disp.DispLines,'Label','Display Lines');
main_menu.disp_under_bot=uimenu(m_display,'checked',curr_disp.DispUnderBottom,'Label','Display Under Bottom data');
main_menu.display_file_lines=uimenu(m_display,'checked','off','Label','Display File Lines','Callback',{@checkbox_callback,main_figure,@toggle_display_file_lines});
main_menu.reverse_y_axis=uimenu(m_display,'checked','off','Label','Reverse Y-Axis','Callback',{@checkbox_callback,main_figure,@reverse_y_axis});



set([main_menu.disp_tracks main_menu.disp_under_bot main_menu.disp_bottom main_menu.disp_bad_trans main_menu.disp_lines main_menu.disp_reg],'callback',{@set_curr_disp,main_figure});


main_menu.close_all_fig=uimenu(m_display,'Label','Close All External Figures','Callback',{@close_figures_callback,main_figure});

mhhh = uimenu(main_figure,'Label','Tools','Tag','menutools');

reg_tools=uimenu(mhhh,'Label','Regions Tools');
uimenu(reg_tools,'Label','Create WC Region','Callback',{@create_reg_dlbox,main_figure});
uimenu(reg_tools,'Label','Display current region','Callback',{@display_region_callback,[],main_figure});
uimenu(reg_tools,'Label','Display Mean Depth of current region','Callback',{@plot_mean_aggregation_depth_callback,main_figure});
uimenu(reg_tools,'Label','Classify schools','Callback',{@classify_regions_callback,main_figure});
uimenu(reg_tools,'Label','Slice Transect','CallBack',{@display_sliced_transect_callback,main_figure});
uimenu(reg_tools,'Label','Merge Overlapping Regions','CallBack',{@merge_overlapping_regions_callback,main_figure});



bs_tools=uimenu(mhhh,'Label','Backscatter Analysis');
uimenu(bs_tools,'Label','Load SVP','Callback',{@load_svp_callback,main_figure});
uimenu(bs_tools,'Label','Execute BS analysis','Callback',{@bs_analysis_callback,main_figure});


curves_tools=uimenu(mhhh,'Label','Curves');
uimenu(curves_tools,'Label','Plot Curves by Tag','Callback',{@plot_curves_callback,main_figure});
uimenu(curves_tools,'Label','Clear Curves','Callback',{@clear_curves_callback,main_figure});

track_tools=uimenu(mhhh,'Label','Track');
uimenu(track_tools,'Label','Plot Frequency response from Fish Tracks','Callback',{@plot_freq_resp_tracks_callback,main_figure});
uimenu(track_tools,'Label','Plot Histogram from Fish Tracks','Callback',{@plot_hist_tracks_callback,main_figure});
uimenu(track_tools,'Label','Create Exclude Regions from Tracks','Callback',{@create_regs_from_tracks_callback,'Bad Data',main_figure});


mbs = uimenu(main_figure,'Label','Scripting','Tag','menumbs');
uimenu(mbs,'Label','MBS Scripts','Callback',{@load_mbs_scripts_callback,main_figure});
uimenu(mbs,'Label','XML Scripts','Callback',{@load_xml_scripts_callback,main_figure},'separator','on');
uimenu(mbs,'Label','Plot survey results from Survey Output files','Callback',{@plot_survey_results_callback,main_figure});


options = uimenu(main_figure,'Label','Options','Tag','options');
uimenu(options,'Label','Path','Callback',{@load_path_fig,main_figure});
uimenu(options,'Label','Save Current Display Configuration','Callback',{@save_display_config_callback,main_figure});

help_shortcuts=uimenu(main_figure,'Label','Shortcuts/Help');
uimenu(help_shortcuts,'Label','Shortcuts','Callback',{@help_menu,main_figure});

setappdata(main_figure,'main_menu',main_menu);

end

function reload_current_layer_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer'); 

file_id=layer.Filename;
delete_layer_callback([],[],main_figure);

open_file([],[],file_id,main_figure);

end

function clean_temp_files_callback(src,~,main_figure)
layers=getappdata(main_figure,'Layers');

temp_files_in_use=layers.list_memaps();
app_path=getappdata(main_figure,'App_path');

files_in_temp=dir(app_path.data_temp);

idx_delete=[];
for uu=1:length(files_in_temp)
    if nansum(strcmpi(fullfile(app_path.data_temp,files_in_temp(uu).name),temp_files_in_use))==0&&files_in_temp(uu).isdir==0
        idx_delete=[idx_delete uu];
    end
end

for i=1:length(idx_delete)
    if exist(fullfile(app_path.data_temp,files_in_temp(idx_delete(i)).name),'file')==2
        delete(fullfile(app_path.data_temp,files_in_temp(idx_delete(i)).name));
    end
end

fprintf('%d files deleted, %.0f Mb\n',length(idx_delete),nansum([files_in_temp(idx_delete).bytes])/1e6);

end

function change_cmap_callback(src,~,main_fig)
curr_disp=getappdata(main_fig,'Curr_disp');
curr_disp.Cmap=src.Tag;
setappdata(main_fig,'Curr_disp',curr_disp);
end


function save_display_config_callback(~,~,main_fig)
curr_disp=getappdata(main_fig,'Curr_disp');
app_path=getappdata(main_fig,'App_path');
layer=getappdata(main_fig,'Layer');
if isempty(layer)
    return;
end
idx_freq=find_freq_idx(layer,curr_disp.Freq);

write_config_to_xml(app_path,curr_disp,layer.Transceivers(idx_freq).Algo);
end

function load_map_fig_callback(~,~,main_fig)
load_map_fig(main_fig,[]);
end


function look_for_new_files_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
layer.update_echo_logbook_dbfile();

hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];
idx_tag=find(strcmp({hfigs(:).Tag},'logbook'), 1);

if ~isempty(idx_tag)
    load_survey_data_fig_from_db(main_figure);
end

end



function logbook_display_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');

if isempty(layer)
    path_f = uigetdir(app_path.data,'Choose data folder');
    if path_f==0
        return;
    end
else
    [path_lay,~]=layer.get_path_files();
    path_f=path_lay{1};
end

xmlfile=fullfile(path_f,'echo_logbook.xml');
htmlfile=fullfile(path_f,'echo_logbook.html');

if exist(xmlfile,'file')==0
    initialize_echo_logbook_file(path_f);
end

if exist(htmlfile,'file')==0
    xslt(xmlfile, fullfile(whereisEcho,'config','echo_logbook.xsl'), htmlfile);
end

system(sprintf('start "" "%s"',htmlfile));

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



