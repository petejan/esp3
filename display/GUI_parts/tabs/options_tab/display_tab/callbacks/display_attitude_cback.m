%% display_attitude_cback.m
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
function display_attitude_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

layers_Str=list_layers(layer);
new_figs=layer.AttitudeNav.display_att(main_figure);

for i=1:length(new_figs)
    set(new_figs(i),'Tag',sprintf('attitude%s',layer.Unique_ID),'Name',sprintf('Attitude  %s',layers_Str{1}));
end

end