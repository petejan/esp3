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

pos=create_pos_algo_new(5,2);

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Candidate Minimum length(m)','units','normalized','Position',pos{1,1});
school_detect_tab_comp.l_min_can_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
school_detect_tab_comp.l_min_can_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(school_detect_tab_comp.l_min_can_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.l_min_can_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_can_ed,'%.1f'});
set(school_detect_tab_comp.l_min_can_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_can_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Candidate Minimum Heigth(m)','units','normalized','Position',pos{2,1});
school_detect_tab_comp.h_min_can_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
school_detect_tab_comp.h_min_can_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(school_detect_tab_comp.h_min_can_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.h_min_can_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_can_ed,'%.1f'});
set(school_detect_tab_comp.h_min_can_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_can_sl,'%.1f'});


uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Total Minimum length(m)','units','normalized','Position',pos{3,1});
school_detect_tab_comp.l_min_tot_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
school_detect_tab_comp.l_min_tot_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(school_detect_tab_comp.l_min_tot_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.l_min_tot_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_tot_ed,'%.1f'});
set(school_detect_tab_comp.l_min_tot_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_tot_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Total Minimum height(m)','units','normalized','Position',pos{4,1});
school_detect_tab_comp.h_min_tot_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
school_detect_tab_comp.h_min_tot_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(school_detect_tab_comp.h_min_tot_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.h_min_tot_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_tot_ed,'%.1f'});
set(school_detect_tab_comp.h_min_tot_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_tot_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Maximum horizontal linking (m)','units','normalized','Position',pos{1,4});
school_detect_tab_comp.horz_link_max_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,5});
school_detect_tab_comp.horz_link_max_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{1,6},'string',num2str(get(school_detect_tab_comp.horz_link_max_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.horz_link_max_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.horz_link_max_ed,'%.1f'});
set(school_detect_tab_comp.horz_link_max_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.horz_link_max_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Maximum vertical linking (m)','units','normalized','Position',pos{2,4});
school_detect_tab_comp.vert_link_max_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',20,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,5});
school_detect_tab_comp.vert_link_max_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{2,6},'string',num2str(get(school_detect_tab_comp.vert_link_max_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.vert_link_max_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.vert_link_max_ed,'%.1f'});
set(school_detect_tab_comp.vert_link_max_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.vert_link_max_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Minimum sample number','units','normalized','Position',pos{3,4});
school_detect_tab_comp.nb_min_sples_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',1000,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,5});
school_detect_tab_comp.nb_min_sples_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{3,6},'string',num2str(get(school_detect_tab_comp.nb_min_sples_sl,'Value'),'%.0f'));
set(school_detect_tab_comp.nb_min_sples_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.nb_min_sples_ed,'%.0f'});
set(school_detect_tab_comp.nb_min_sples_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.nb_min_sples_sl,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Sv Threshold (dB)','units','normalized','Position',pos{4,4});
school_detect_tab_comp.sv_thr_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',-120,'Max',-30,'Value',-50,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,5});
school_detect_tab_comp.sv_thr_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{4,6},'string',num2str(get(school_detect_tab_comp.sv_thr_sl,'Value'),'%.0f'));
set(school_detect_tab_comp.sv_thr_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.sv_thr_ed,'%.0f'});
set(school_detect_tab_comp.sv_thr_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.sv_thr_sl,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.05 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.6 0.05 0.1 0.1],'callback',{@copy_across_algo,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.4 0.05 0.1 0.1],'callback',{@save_algos,main_figure});

%set(findall(school_detect_tab_comp.school_detect_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);
end







function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

%school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('SchoolDetection','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

setappdata(main_figure,'Layer',layer);
update_regions_tab(main_figure,[]);
display_regions(main_figure,'both');
set_alpha_map(main_figure);
update_reglist_tab(main_figure,[],0);
order_stacks_fig(main_figure);
end




