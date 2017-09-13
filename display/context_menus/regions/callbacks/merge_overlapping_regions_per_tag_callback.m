%% merge_overlapping_regions_per_tag_callback.m
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
function merge_overlapping_regions_per_tag_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);
if ~isempty(trans_obj.Regions)
    new_regions=[];
    old_regs=trans_obj.Regions;
    tag=trans_obj.get_reg_tags();
    for t=1:1:length(tag)
        idx=trans_obj.find_regions_tag(tag{t});
        regions_tmps=trans_obj.Regions(idx).merge_regions();
        for i=1:length(regions_tmps)
            regions_tmps(i).Tag=tag{t};
        end
        new_regions=[new_regions regions_tmps];
    end
    trans_obj.rm_all_region();
    IDs=trans_obj.add_region(new_regions,'IDs',1:length(new_regions));
   
    display_regions(main_figure,'both');
   
    add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);


    if ~isempty(IDs)
    curr_disp.Active_reg_ID=IDs(end);   
    curr_disp.Reg_changed_flag=1;
    end
    
    order_stacks_fig(main_figure);

end

end