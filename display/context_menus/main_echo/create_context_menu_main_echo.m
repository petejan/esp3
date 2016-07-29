function create_context_menu_main_echo(main_figure)
 axes_panel_comp=getappdata(main_figure,'Axes_panel');
 
context_menu=uicontextmenu(main_figure);
axes_panel_comp.bad_transmits.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});
uimenu(context_menu,'Label','Split Transect Here','Callback',{@split_transect_callback,main_figure});
uimenu(context_menu,'Label','Edit/Add Survey Data','Callback',{@edit_survey_data_callback,main_figure,0});
uimenu(context_menu,'Label','Edit/Add Survey Data for this file','Callback',{@edit_survey_data_curr_file_callback,main_figure});
uimenu(context_menu,'Label','Remove Survey Data','Callback',{@edit_survey_data_callback,main_figure,1});
end