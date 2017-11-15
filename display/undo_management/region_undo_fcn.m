%% region_undo_fcn.m
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
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-09-12 first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function region_undo_fcn(main_figure,trans_obj,regs)
if~isdeployed()
    disp('Undo Region')
end
trans_obj.rm_all_region();
IDs=trans_obj.add_region(regs);
curr_disp=getappdata(main_figure,'Curr_disp');
display_regions(main_figure,'both');
order_stacks_fig(main_figure);
curr_disp.Reg_changed_flag=1;
if ~isempty(IDs)
    curr_disp.Active_reg_ID=IDs{end};   
    curr_disp.Reg_changed_flag=1;
end
end


