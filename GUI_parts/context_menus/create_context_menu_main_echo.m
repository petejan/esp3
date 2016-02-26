function create_context_menu_main_echo(main_figure,main_echo)

context_menu=uicontextmenu;
main_echo.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});
uimenu(context_menu,'Label','Split Transect Here','Callback',{@split_transect_callback,main_figure});
uimenu(context_menu,'Label','Edit/Add Survey Data','Callback',{@edit_survey_data_callback,main_figure,0});
uimenu(context_menu,'Label','Remove Survey Data','Callback',{@edit_survey_data_callback,main_figure,1});
end