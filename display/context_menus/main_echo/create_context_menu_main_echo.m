function create_context_menu_main_echo(main_figure)
axes_panel_comp=getappdata(main_figure,'Axes_panel');
 
context_menu=uicontextmenu(main_figure);
axes_panel_comp.bad_transmits.UIContextMenu=context_menu;
analysis_menu=uimenu(context_menu,'Label','Analysis');
uimenu(analysis_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});
uimenu(analysis_menu,'Label','Plot Ping Spectrum','Callback',{@plot_ping_spectrum_callback,main_figure});


survey_menu=uimenu(context_menu,'Label','Survey Data');
uimenu(survey_menu,'Label','Edit/Add Survey Data','Callback',{@edit_survey_data_callback,main_figure,0});
uimenu(survey_menu,'Label','Edit/Add Survey Data for this file','Callback',{@edit_survey_data_curr_file_callback,main_figure});
uimenu(survey_menu,'Label','Remove Survey Data','Callback',{@edit_survey_data_callback,main_figure,1});
uimenu(survey_menu,'Label','Split Transect Here','Callback',{@split_transect_callback,main_figure});

config_menu=uimenu(context_menu,'Label','Configuration');
uimenu(config_menu,'Label','Display Current Ping Config','Callback',{@disp_ping_config_params_callback,main_figure});
end