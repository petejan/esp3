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
function classify_reg_callback(~,~,main_figure)
school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

if isempty(school_detect_tab_comp.classification_files)
    return;
end
idx_val=get(school_detect_tab_comp.classification_list,'value');

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

hfigs=getappdata(main_figure,'ExternalFigures');

[trans_obj,~]=layer.get_trans(curr_disp);


idx_reg=trans_obj.find_regions_Unique_ID(curr_disp.Active_reg_ID);

layer.apply_classification('primary_freq',curr_disp.Freq,'idx_schools',idx_reg,...
    'classification_file',school_detect_tab_comp.classification_files{idx_val},'denoised',school_detect_tab_comp.denoised.Value);

setappdata(main_figure,'ExternalFigures',hfigs);
setappdata(main_figure,'Layer',layer);


update_reglist_tab(main_figure,1);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);

end
