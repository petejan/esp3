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

x_ini=0.0;
y_ini=1;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(5,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(school_detect_tab_comp.school_detect_tab,'title','','Position',[0. 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_1,'Style','text','units','normalized','string','Can. Min. Len(m)','pos',pos{1,1},'HorizontalAlignment','right');
school_detect_tab_comp.l_min_can=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.l_min_can),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.l_min_can,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Can. Min. Hgth(m)','pos',pos{2,1},'HorizontalAlignment','right');
school_detect_tab_comp.h_min_can=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.h_min_can),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.h_min_can,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Tot. Min. Len(m)','pos',pos{3,1},'HorizontalAlignment','right');
school_detect_tab_comp.l_min_tot=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.l_min_tot),'BackgroundColor','white','callback',{@ check_fmt_box,0,10000,varin.l_min_tot,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Tot. Min. Hgth(m)','pos',pos{4,1},'HorizontalAlignment','right');
school_detect_tab_comp.h_min_tot=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.h_min_tot),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.h_min_tot,'%.2f'});

parameters_2=uipanel(school_detect_tab_comp.school_detect_tab,'title','','Position',[0.3 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_2,'Style','text','units','normalized','string','Max. horz. link(m)','pos',pos{1,1},'HorizontalAlignment','right');
school_detect_tab_comp.horz_link_max=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.horz_link_max),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.horz_link_max,'%.2f'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Max. vert. link(m)','pos',pos{2,1},'HorizontalAlignment','right');
school_detect_tab_comp.vert_link_max=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.vert_link_max),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.vert_link_max,'%.2f'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Min. sple number','pos',pos{3,1},'HorizontalAlignment','right');
school_detect_tab_comp.nb_min_sples=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.nb_min_sples),'BackgroundColor','white','callback',{@ check_fmt_box,0,1000,varin.nb_min_sples,'%.0f'});

uicontrol(parameters_2,'Style','text','units','normalized','string','Sv Thr.(dB)','pos',pos{4,1},'HorizontalAlignment','right');
school_detect_tab_comp.Sv_thr=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.Sv_thr),'BackgroundColor','white','callback',{@ check_fmt_box,-120,0,varin.Sv_thr,'%.0f'});

uicontrol(parameters_2,'Style','text','units','normalized','string','Sv Max.(dB)','pos',pos{5,1},'HorizontalAlignment','right');
school_detect_tab_comp.Sv_max=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{5,2},'string',num2str(varin.Sv_max),'BackgroundColor','white','callback',{@ check_fmt_box,-120,Inf,varin.Sv_max,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Defaults Values','units','normalized','Position',[0.7 0.8 0.2 0.1]);

school_detect_tab_comp.denoised=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','checkbox','Value',0,'String','Compute on Denoised data','units','normalized','Position',[0.7 0.4 0.3 0.1]);

[~,~,algo_files]=get_config_files('SchoolDetection');
[~,~,names]=read_config_algo_xml(algo_files{1});

list_params=names;

school_detect_tab_comp.default_params=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','popupmenu','String',list_params,'Value',find(strcmpi(list_params,'--')),'units','normalized','Position', [0.7 0.7 0.2 0.1],'callback',{@load_params,main_figure});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.85 0.1 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.75 0.1 0.1 0.1],'callback',{@copy_across_algo,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.65 0.2 0.1 0.1],'callback',{@save_display_algos_config_callback,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Save as','units','normalized','pos',[0.75 0.2 0.1 0.1],'callback',{@save_new_display_algos_config_callback,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Delete','units','normalized','pos',[0.85 0.2 0.1 0.1],'callback',{@delete_display_algos_config_callback,main_figure,'SchoolDetection'});

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
trans_obj.apply_algo('SchoolDetection','load_bar_comp',load_bar_comp);
update_multi_freq_disp_tab(main_figure,'sv_f',0);
update_multi_freq_disp_tab(main_figure,'ts_f',0);
hide_status_bar(main_figure);

set_alpha_map(main_figure);
display_regions(main_figure,'both');

curr_disp.setActive_reg_ID(trans_obj.get_reg_first_Unique_ID());
order_stacks_fig(main_figure);
end




