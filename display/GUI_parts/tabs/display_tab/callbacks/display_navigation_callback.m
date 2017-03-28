%% display_navigation_callback.m
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
% * 2017-03-29: header (Alex Schimel).
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function display_navigation_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
map_input=map_input_cl.map_input_cl_from_obj(layer,'SliceSize',0);
if nansum(isnan(map_input.LatLim))>=1
    return;
end
layers_Str=list_layers(layer);
hfig=new_echo_figure(main_figure,'Name',sprintf('Navigation  %s',layers_Str{1}),'Tag','nav');
map_input.display_map_input_cl('hfig',hfig,'main_figure',main_figure);

new_fig=layer.Transceivers(idx_freq).GPSDataPing.display_speed(main_figure);
new_echo_figure(main_figure,'fig_handle',new_fig,'Tag','speed','Name',sprintf('Speed  %s',layers_Str{1}));


end