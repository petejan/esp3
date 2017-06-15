%% classify_reg_callback.m
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
% * |reg_curr|: TODO: write description and info on variable
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
function classify_reg_callback(~,~,ID,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

hfigs=getappdata(main_figure,'ExternalFigures');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

%reg_curr=layer.Transceivers(idx_freq).get_region_from_Unique_ID(ID);
idx_reg=layer.Transceivers(idx_freq).find_regions_Unique_ID(ID);
if isempty(idx_reg)
    return; 
end

new_fig=layer.apply_classification(idx_freq,idx_reg);

hfigs=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs);
setappdata(main_figure,'Layer',layer);

update_regions_tab(main_figure);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);

end
