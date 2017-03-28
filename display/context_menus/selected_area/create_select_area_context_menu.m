%% create_select_area_context_menu.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |select_plot|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function create_select_area_context_menu(select_plot,main_figure)

context_menu=uicontextmenu(main_figure);
select_plot.UIContextMenu=context_menu;

uimenu(context_menu,'Label','Apply Bottom Detection V1 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v1'});
uimenu(context_menu,'Label','Apply Bottom Detection V2 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v2'});
uimenu(context_menu,'Label','Shift Bottom ','Callback',{@shift_bottom_callback,select_plot,main_figure});
uimenu(context_menu,'Label','Apply Single Target Detection ','Callback',{@apply_st_detect_cback,select_plot,main_figure});
uimenu(context_menu,'Label','ApplySchool Detection ','Callback',{@apply_school_detect_cback,select_plot,main_figure});


end


