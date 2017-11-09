%% update_school_detect_tab.m
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
function update_school_detect_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[idx_algo,found]=find_algo_idx(trans_obj,'SchoolDetection');
if found==0
     return
end

algo_obj=trans_obj.Algo(idx_algo);
varin=algo_obj.Varargin;


set(school_detect_tab_comp.l_min_can,'string',num2str(varin.l_min_can,'%.2f'));

set(school_detect_tab_comp.h_min_can,'string',num2str(varin.h_min_can,'%.2f'));

set(school_detect_tab_comp.l_min_tot,'string',num2str(varin.l_min_tot,'%.2f'));

set(school_detect_tab_comp.h_min_tot,'string',num2str(varin.h_min_tot,'%.2f'));

set(school_detect_tab_comp.horz_link_max,'string',num2str(varin.horz_link_max,'%.2f'));

set(school_detect_tab_comp.vert_link_max,'string',num2str(varin.vert_link_max,'%.2f'));

set(school_detect_tab_comp.nb_min_sples,'string',num2str(varin.nb_min_sples,'%.0f'));

set(school_detect_tab_comp.Sv_thr,'string',num2str(varin.Sv_thr,'%.0f'));

%set(findall(school_detect_tab_comp.school_detect_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);

end
