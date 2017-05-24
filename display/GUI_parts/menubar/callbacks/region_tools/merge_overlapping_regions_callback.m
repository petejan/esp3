%% merge_overlapping_regions_callback.m
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
function merge_overlapping_regions_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
if ~isempty(layer.Transceivers(idx_freq).Regions)
    new_regions=layer.Transceivers(idx_freq).Regions.merge_regions();
    layer.Transceivers(idx_freq).rm_all_region();
    layer.Transceivers(idx_freq).add_region(new_regions,'IDs',1:length(new_regions));
    
    display_regions(main_figure,'both');
    curr_disp=getappdata(main_figure,'Curr_disp');
    trans_obj=layer.get_trans(curr_disp.Freq);
    curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
    
    order_stacks_fig(main_figure);
    
end

end