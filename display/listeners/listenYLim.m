%% listenYLim.m
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
% * |main_figure|: Handle to main ESP3 window
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
% * 2017-04-02: header (Alex Schimel). 
% * 2016-06-17: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function listenYLim(~,~,main_figure)
% profile on;
wbmf_ori=get(main_figure,'WindowButtonMotionFcn');

set(main_figure,'WindowButtonMotionFcn','');
% 
update_axis_panel(main_figure,0);
set_axes_position(main_figure);
update_cmap(main_figure);
reverse_y_axis(main_figure);

display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_survdata_lines(main_figure);
set_alpha_map(main_figure);
order_stacks_fig(main_figure);


axes_panel_comp=getappdata(main_figure,'Axes_panel');
x_lim=get(axes_panel_comp.main_axes,'XLim');
y_lim=get(axes_panel_comp.main_axes,'YLim');
mini_ax_comp=getappdata(main_figure,'Mini_axes');
patch_obj=mini_ax_comp.patch_obj;
new_vert=patch_obj.Vertices;
new_vert(:,1)=[x_lim(1) x_lim(2) x_lim(2) x_lim(1)];
new_vert(:,2)=[y_lim(1) y_lim(1) y_lim(2) y_lim(2)];
set(patch_obj,'Vertices',new_vert);

reset_disp_info(main_figure);

set(main_figure,'WindowButtonMotionFcn',wbmf_ori);

% profile off;
% profile viewer
end