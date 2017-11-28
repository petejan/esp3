%% bottom_undo_fcn.m
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
% * 2017-06-26 first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function bottom_undo_fcn(main_figure,trans_obj,bot)
if~isdeployed()
    disp('Undo Bottom')
end
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj.Bottom=bot;
display_bottom(main_figure);
layer=getappdata(main_figure,'Layer');
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
curr_disp.Bot_changed_flag=1;
end


