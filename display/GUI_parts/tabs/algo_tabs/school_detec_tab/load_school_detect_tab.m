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

pos=create_pos_2(4,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(school_detect_tab_comp.school_detect_tab,'title','','Position',[0.01 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_1,'Style','text','units','normalized','string','Can. Min. Len(m)','pos',pos{1,1},'HorizontalAlignment','right');
school_detect_tab_comp.l_min_can=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.l_min_can),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.l_min_can,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Can. Min. Hgth(m)','pos',pos{2,1},'HorizontalAlignment','right');
school_detect_tab_comp.h_min_can=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.h_min_can),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.h_min_can,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Tot. Min. Len(m)','pos',pos{3,1},'HorizontalAlignment','right');
school_detect_tab_comp.l_min_tot=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.l_min_tot),'BackgroundColor','white','callback',{@ check_fmt_box,0,10000,varin.l_min_tot,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Tot. Min. Hgth(m)','pos',pos{4,1},'HorizontalAlignment','right');
school_detect_tab_comp.h_min_tot=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.h_min_tot),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.h_min_tot,'%.2f'});

parameters_2=uipanel(school_detect_tab_comp.school_detect_tab,'title','','Position',[0.32 0.2 0.32 0.7],'fontsize',11);

uicontrol(parameters_2,'Style','text','units','normalized','string','Max. horz. link(m)','pos',pos{1,1},'HorizontalAlignment','right');
school_detect_tab_comp.horz_link_max=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.horz_link_max),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.horz_link_max,'%.2f'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Max. vert. link(m)','pos',pos{2,1},'HorizontalAlignment','right');
school_detect_tab_comp.vert_link_max=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.vert_link_max),'BackgroundColor','white','callback',{@ check_fmt_box,0,500,varin.vert_link_max,'%.2f'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Min. sple number','pos',pos{3,1},'HorizontalAlignment','right');
school_detect_tab_comp.nb_min_sples=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.nb_min_sples),'BackgroundColor','white','callback',{@ check_fmt_box,0,1000,varin.nb_min_sples,'%.0f'});

uicontrol(parameters_2,'Style','text','units','normalized','string','Sv Thr.(dB)','pos',pos{4,1},'HorizontalAlignment','right');
school_detect_tab_comp.Sv_thr=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.Sv_thr),'BackgroundColor','white','callback',{@ check_fmt_box,-120,-10,varin.Sv_thr,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Defaults Values','units','normalized','Position',[0.7 0.8 0.2 0.1]);
list_params={'--','Long Layers','Round Large','Small Long','Small Round','Tiny Round'};
school_detect_tab_comp.default_params=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','popupmenu','String',list_params,'Value',1,'units','normalized','Position', [0.7 0.7 0.2 0.1],'callback',{@load_default_params,main_figure});


uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.85 0.1 0.1 0.12],'callback',{@validate,main_figure});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.75 0.1 0.1 0.12],'callback',{@copy_across_algo,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.65 0.1 0.1 0.12],'callback',{@save_algos,main_figure});

%set(findall(school_detect_tab_comp.school_detect_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);
end



function load_default_params(src,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[idx_algo,found]=find_algo_idx(trans_obj,'SchoolDetection');
if found==0
    return
end

switch src.String{src.Value}
    
    case 'Long Layers'
        trans_obj.Algo(idx_algo).Varargin.l_min_can=100;
        trans_obj.Algo(idx_algo).Varargin.l_min_tot=200;
        trans_obj.Algo(idx_algo).Varargin.h_min_can=10;
        trans_obj.Algo(idx_algo).Varargin.h_min_tot=20;
        trans_obj.Algo(idx_algo).Varargin.nb_min_sples=1000;
        trans_obj.Algo(idx_algo).Varargin.horz_link_max=50;
        trans_obj.Algo(idx_algo).Varargin.vert_link_max=5;
    case 'Round Large'
        trans_obj.Algo(idx_algo).Varargin.l_min_can=20;
        trans_obj.Algo(idx_algo).Varargin.h_min_can=20;
        trans_obj.Algo(idx_algo).Varargin.h_min_tot=50;
        trans_obj.Algo(idx_algo).Varargin.l_min_tot=50;
        trans_obj.Algo(idx_algo).Varargin.nb_min_sples=1000;
        trans_obj.Algo(idx_algo).Varargin.horz_link_max=10;
        trans_obj.Algo(idx_algo).Varargin.vert_link_max=10;
    case 'Small Long'
        trans_obj.Algo(idx_algo).Varargin.l_min_can=5;
        trans_obj.Algo(idx_algo).Varargin.h_min_can=0.5;
        trans_obj.Algo(idx_algo).Varargin.l_min_tot=10;
        trans_obj.Algo(idx_algo).Varargin.h_min_tot=1;
        trans_obj.Algo(idx_algo).Varargin.nb_min_sples=100;
        trans_obj.Algo(idx_algo).Varargin.horz_link_max=2;
        trans_obj.Algo(idx_algo).Varargin.vert_link_max=0.5;
        
    case 'Small Round'
        trans_obj.Algo(idx_algo).Varargin.l_min_can=0.5;
        trans_obj.Algo(idx_algo).Varargin.l_min_tot=1;
        trans_obj.Algo(idx_algo).Varargin.h_min_can=0.5;
        trans_obj.Algo(idx_algo).Varargin.h_min_tot=1;
        trans_obj.Algo(idx_algo).Varargin.nb_min_sples=50;
        trans_obj.Algo(idx_algo).Varargin.horz_link_max=0.5;
        trans_obj.Algo(idx_algo).Varargin.vert_link_max=0.5;
        
     case 'Tiny Round'
        trans_obj.Algo(idx_algo).Varargin.l_min_can=0.5;
        trans_obj.Algo(idx_algo).Varargin.l_min_tot=0.5;
        trans_obj.Algo(idx_algo).Varargin.h_min_can=0.5;
        trans_obj.Algo(idx_algo).Varargin.h_min_tot=0.5;
        trans_obj.Algo(idx_algo).Varargin.nb_min_sples=50;
        trans_obj.Algo(idx_algo).Varargin.horz_link_max=0.5;
        trans_obj.Algo(idx_algo).Varargin.vert_link_max=0.5;
        
    otherwise
        return;
end
setappdata(main_figure,'Layer',layer);
update_school_detect_tab(main_figure);

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




