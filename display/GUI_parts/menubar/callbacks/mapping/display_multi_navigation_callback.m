%% display_multi_navigation_callback.m
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
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function display_multi_navigation_callback(~,~,main_figure)


layers=getappdata(main_figure,'Layers');

map_input=map_input_cl.map_input_cl_from_obj(layers,'SliceSize',0);

if nansum(isnan(map_input.LatLim))>=1
    return;
end

map_input.display_map_input_cl('main_figure',main_figure,'oneMap',1);

end