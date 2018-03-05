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

algo=algo_cl('Name','BadPingsV2');
varin=algo.Varargin;

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(6,2,gui_fmt.x_sep,gui_fmt.y_sep,150,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{4,1}{1};
p_button(3)=gui_fmt.button_w;

bad_ping_tab_comp.BS_std_bool=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',1,'String','BS fluct. limit (dB)','units','pixels','Position',pos{1,1}{1});
bad_ping_tab_comp.BS_std=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Edit','units','pixels','pos',pos{1,1}{2},'string',num2str(varin.BS_std),'BackgroundColor','white','callback',{@check_fmt_box,0,20,varin.BS_std,'%.0f'});

bad_ping_tab_comp.Above=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',1,'String','Above Bot. thr (dB)','units','pixels','Position',pos{2,1}{1});
bad_ping_tab_comp.thr_spikes_Above=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Edit','units','pixels','pos',pos{2,1}{2},'string',num2str(varin.thr_spikes_Above),'BackgroundColor','white','callback',{@check_fmt_box,0,100,varin.thr_spikes_Above,'%.0f'});

bad_ping_tab_comp.Below=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',0,'String','Below Bot. thr (dB)','units','pixels','Position',pos{3,1}{1});
bad_ping_tab_comp.thr_spikes_Below=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Edit','units','pixels','pos',pos{3,1}{2},'string',num2str(varin.thr_spikes_Below),'BackgroundColor','white','callback',{@ check_fmt_box,0,100,varin.thr_spikes_Below,'%.0f'});

bad_ping_tab_comp.percent_BP=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','text','String','','units','pixels','pos',pos{2,2}{1}+[0 0 gui_fmt.txt_w 0],'fontweight','bold','fontsize',14);

%uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Copy','units','pixels','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@copy_across_algo,main_figure,'BadPingsV2'});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Apply','units','pixels','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate,main_figure});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Save','units','pixels','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'BadPingsV2'});

setappdata(main_figure,'Bad_ping_tab',bad_ping_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);

show_status_bar(main_figure);

old_bot=trans_obj.Bottom;
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('BadPingsV2','load_bar_comp',load_bar_comp,'replace_bot',0);
hide_status_bar(main_figure);
setappdata(main_figure,'Layer',layer);
bot=trans_obj.Bottom;

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

set_alpha_map(main_figure);
display_bottom(main_figure);
order_stacks_fig(main_figure);

end
