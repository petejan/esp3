%% load_bad_pings_tab.m
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
function load_bad_pings_tab(main_figure,algo_tab_panel)


bad_ping_tab_comp.bad_ping_tab=uitab(algo_tab_panel,'Title','Bad Transmit');

algo=algo_cl('Name','BadPings');
varin=algo.Varargin;

x_ini=0.0;
y_ini=1;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(4,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(bad_ping_tab_comp.bad_ping_tab,'title','','Position',[0.01 0.2 0.4 0.7],'fontsize',11);

bad_ping_tab_comp.BS_std_bool=uicontrol(parameters_1,'Style','checkbox','Value',1,'String','BS fluct. limit (dB)','units','normalized','Position',pos{1,1});
bad_ping_tab_comp.BS_std=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.BS_std),'BackgroundColor','white','callback',{@ check_fmt_box,0,12,varin.BS_std,'%.0f'});


bad_ping_tab_comp.Above=uicontrol(parameters_1,'Style','checkbox','Value',1,'String','Above bot. PDF thr.(%)','units','normalized','Position',pos{2,1});
bad_ping_tab_comp.thr_spikes_Above=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.thr_spikes_Above),'BackgroundColor','white','callback',{@ check_fmt_box,0,100,varin.thr_spikes_Above,'%.0f'});


bad_ping_tab_comp.Below=uicontrol(parameters_1,'Style','checkbox','Value',0,'String','Below bot. PDF thr.(%)','units','normalized','Position',pos{3,1});
bad_ping_tab_comp.thr_spikes_Below=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.thr_spikes_Below),'BackgroundColor','white','callback',{@ check_fmt_box,0,100,varin.thr_spikes_Below,'%.0f'});


uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Text','String','Bottom Algo Version','units','normalized','Position',[0.7 0.8 0.2 0.1]);
bad_ping_tab_comp.version=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','popupmenu','Value',1,'String',{'V1','V2'},'units','normalized','Position',[0.7 0.7 0.2 0.1]);

uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.75 0.1 0.1 0.12],'callback',{@copy_across_algo,main_figure,'BadPings'});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.85 0.1 0.1 0.12],'callback',{@validate,main_figure});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.65 0.1 0.1 0.12],'callback',{@save_algos,main_figure});

setappdata(main_figure,'Bad_ping_tab',bad_ping_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('BadPings','load_bar_comp',load_bar_comp);
hide_status_bar(main_figure);

setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end
