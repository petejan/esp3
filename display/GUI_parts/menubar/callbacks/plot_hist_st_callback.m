%% plot_hist_st_callback.m
%
% Callback plotting histogram of detected single target on currently
% displayed frequency.
%
%% Help
%
% *USE*
%
% TODO
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
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-02: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function plot_hist_st_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
display_st_or_track_hist(main_figure,ax,'st');


end