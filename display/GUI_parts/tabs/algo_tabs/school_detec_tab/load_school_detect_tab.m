%% load_school_detect_tab.m
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
% * |algo_tab_panel|: TODO: write description and info on variable
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
function load_school_detect_tab(main_figure,algo_tab_panel)

school_detect_tab_comp.school_detect_tab=uitab(algo_tab_panel,'Title','School Detection');

algo=algo_cl('Name','SchoolDetection');
varin=algo.Varargin;

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*1.2;
pos=create_pos_3(6,4,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{6,1}{1};
p_button(3)=gui_fmt.button_w;


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Can. Min. Len(m)','pos',pos{1,1}{1});
school_detect_tab_comp.l_min_can=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{1,1}{2},'string',num2str(varin.l_min_can),'callback',{@ check_fmt_box,0,500,varin.l_min_can,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Can. Min. Hgth(m)','pos',pos{2,1}{1});
school_detect_tab_comp.h_min_can=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(varin.h_min_can),'callback',{@ check_fmt_box,0,inf,varin.h_min_can,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Tot. Min. Len(m)','pos',pos{3,1}{1});
school_detect_tab_comp.l_min_tot=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(varin.l_min_tot),'callback',{@ check_fmt_box,0,10000,varin.l_min_tot,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Tot. Min. Hgth(m)','pos',pos{4,1}{1});
school_detect_tab_comp.h_min_tot=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(varin.h_min_tot),'callback',{@ check_fmt_box,0,500,varin.h_min_tot,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Max. horz. link(m)','pos',pos{1,2}{1});
school_detect_tab_comp.horz_link_max=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{1,2}{2},'string',num2str(varin.horz_link_max),'callback',{@ check_fmt_box,0,500,varin.horz_link_max,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Max. vert. link(m)','pos',pos{2,2}{1});
school_detect_tab_comp.vert_link_max=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{2,2}{2},'string',num2str(varin.vert_link_max),'callback',{@ check_fmt_box,0,500,varin.vert_link_max,'%.2f'});


uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Min. sple number','pos',pos{3,2}{1});
school_detect_tab_comp.nb_min_sples=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{3,2}{2},'string',num2str(varin.nb_min_sples),'callback',{@ check_fmt_box,0,1000,varin.nb_min_sples,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Sv Thr.(dB)','pos',pos{4,2}{1});
school_detect_tab_comp.Sv_thr=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{4,2}{2},'string',num2str(varin.Sv_thr),'callback',{@ check_fmt_box,-120,0,varin.Sv_thr,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtStyle,'string','Sv Max.(dB)','pos',pos{5,2}{1});
school_detect_tab_comp.Sv_max=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.edtStyle,'pos',pos{5,2}{2},'string',num2str(varin.Sv_max),'callback',{@ check_fmt_box,-120,Inf,varin.Sv_max,'%.0f'});


school_detect_tab_comp.denoised=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.chckboxStyle,'Value',0,'String','Compute on Denoised data','Position',pos{5,1}{1}+[0 0 100 0]);

try
    [~,~,algo_files]=get_config_files('SchoolDetection');
    [~,~,names]=read_config_algo_xml(algo_files{1});
catch
    algo=init_algos('SchoolDetection');
    write_config_algo_to_xml(algo,{'--'},0);
    [~,~,names]=read_config_algo_xml(algo_files{1});
end

list_params=names;
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Load Values','Position',pos{1,1}{1}+[0 gui_fmt.y_sep+gui_fmt.box_h 0 0]);
school_detect_tab_comp.default_params=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.popumenuStyle,'String',list_params,'Value',find(strcmpi(list_params,'--')),...
    'Position', pos{1,1}{1}+[gui_fmt.txt_w+gui_fmt.x_sep gui_fmt.y_sep+gui_fmt.box_h 0 0],'callback',{@load_params,main_figure});

uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate,main_figure});
%uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@copy_across_algo,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Save as','pos',p_button+[3*gui_fmt.button_w 0 0 0],'callback',{@save_new_display_algos_config_callback,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Delete','pos',p_button+[4*gui_fmt.button_w 0 0 0],'callback',{@delete_display_algos_config_callback,main_figure,'SchoolDetection'});

[school_detect_tab_comp.classification_files,school_detect_tab_comp.classification_trees,titles]=list_classification_files();

uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.txtTitleStyle,'string','Trees:','pos',pos{2,3}{1});
if isempty(titles)
    titles={'--'};
end

school_detect_tab_comp.classification_list=uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.popumenuStyle,'pos',pos{3,3}{1}+[0 0 gui_fmt.box_w 0],'string',titles,'value',1);

p_button=pos{4,3}{1};
p_button(3)=gui_fmt.button_w;
uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Reload','pos',p_button,'callback',{@reload_classification_trees_cback,main_figure});
uicontrol(school_detect_tab_comp.school_detect_tab,gui_fmt.pushbtnStyle,'String','Edit','pos',p_button+[gui_fmt.button_w 0 0 0],'callback',{@edit_classif_file_cback,main_figure});

setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);

end
function edit_classif_file_cback(~,~,main_figure)
school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

if isempty(school_detect_tab_comp.classification_files)
    return;
end
idx_val=get(school_detect_tab_comp.classification_list,'value');

[stat,~]=system(['start notepad++ ' school_detect_tab_comp.classification_files{idx_val}]);
if stat~=0
    disp('You should install Notepad++...');
    system(['start ' school_detect_tab_comp.classification_files{idx_val}]);
end

end

function reload_classification_trees_cback(~,~,main_figure)
school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');
[school_detect_tab_comp.classification_files,school_detect_tab_comp.classification_trees,titles]=list_classification_files();
if isempty(titles)
    titles={'--'};
end
set(school_detect_tab_comp.classification_list,'string',titles,'value',1);
setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);

end

function load_params(src,~,main_figure)
    update_school_detect_tab(main_figure);
end


function validate(~,~,main_figure)

update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

%school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

[trans_obj,~]=layer.get_trans(curr_disp);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
old_regs=trans_obj.Regions;
trans_obj.apply_algo('SchoolDetection','load_bar_comp',load_bar_comp);
add_undo_region_action(main_figure,trans_obj,old_regs,trans_obj.Regions);

update_multi_freq_disp_tab(main_figure,'sv_f',0);
update_multi_freq_disp_tab(main_figure,'ts_f',0);
hide_status_bar(main_figure);

set_alpha_map(main_figure);
display_regions(main_figure,'both');

curr_disp.setActive_reg_ID(trans_obj.get_reg_first_Unique_ID());
order_stacks_fig(main_figure);
end




