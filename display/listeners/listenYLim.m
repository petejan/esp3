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
function listenYLim(src,evt,main_figure)
if ~isdeployed
    disp('listenYLim')
end
%profile on;

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);
ax=evt.AffectedObject;
x_lim=get(ax,'XLim');
y_lim=get(ax,'YLim');

range=trans_obj.get_transceiver_range();
%time=trans_obj.get_transceiver_time();
y_lim=ceil(y_lim);

y_lim(y_lim>numel(range))=numel(range);
y_lim(y_lim<=0)=1;
curr_disp.R_disp=range(y_lim);


update_secondary_freq_win(main_figure);
update_axis_panel(main_figure,0);
set_axes_position(main_figure);
%update_cmap(main_figure);
reverse_y_axis(main_figure);

%display_bottom(main_figure);
display_tracks(main_figure);
display_file_lines(main_figure);
display_survdata_lines(main_figure);
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
order_stacks_fig(main_figure);
%curr_disp.R_disp

mini_ax_comp=getappdata(main_figure,'Mini_axes');
patch_obj=mini_ax_comp.patch_obj;
new_vert=patch_obj.Vertices;
new_vert(:,1)=[x_lim(1) x_lim(2) x_lim(2) x_lim(1)];
new_vert(:,2)=[y_lim(1) y_lim(1) y_lim(2) y_lim(2)];
set(patch_obj,'Vertices',new_vert);

reset_disp_info(main_figure);


setappdata(main_figure,'Curr_disp',curr_disp);
order_stacks_fig(main_figure);
% profile off;
% profile viewer
end