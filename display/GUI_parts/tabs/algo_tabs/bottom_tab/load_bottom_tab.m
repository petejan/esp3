%% load_bottom_tab.m
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
function load_bottom_tab(main_figure,algo_tab_panel)

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(5,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{5,1}{1};
p_button(3)=gui_fmt.button_w;

tab_main=uitab(algo_tab_panel,'Title','Bottom Detect');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Version 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
algo=algo_cl('Name','BottomDetection');
varin=algo.Varargin;

bottom_tab_comp.bottom_tab=uipanel(tab_main,'title','Version 1','Position',[0 0 0.5 1],'fontsize',11);

uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','BS thr(dB)','pos',pos{1,1}{1});
bottom_tab_comp.thr_bottom=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{1,1}{2},'string',num2str(varin.thr_bottom),'callback',{@ check_fmt_box,-80,-15,varin.thr_bottom,'%.0f'});

uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Min Depth(m)','pos',pos{2,1}{1});
bottom_tab_comp.r_min=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(varin.r_min),'callback',{@ check_fmt_box,0,inf,varin.r_min,'%.0f'});


uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Max Depth(m)','pos',pos{3,1}{1});
bottom_tab_comp.r_max=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(varin.r_max),'callback',{@ check_fmt_box,0,inf,varin.r_max,'%.0f'});


uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Back Thr(dB)','pos',pos{4,1}{1});
bottom_tab_comp.thr_backstep=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(varin.thr_backstep),'callback',{@ check_fmt_box,-12,6,varin.thr_backstep,'%.0f'});

uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Vert. Res.(m)','pos',pos{1,2}{1});
bottom_tab_comp.vert_filt=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{1,2}{2},'string',num2str(varin.vert_filt),'callback',{@ check_fmt_box,0,inf,varin.vert_filt,'%.0f'});


uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Horz. Res.(m)','pos',pos{2,2}{1});
bottom_tab_comp.horz_filt=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{2,2}{2},'string',num2str(varin.horz_filt),'callback',{@ check_fmt_box,0,inf,varin.horz_filt,'%.0f'});

uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.txtStyle,'string','Shift Bottom(m)','pos',pos{3,2}{1});
bottom_tab_comp.shift_bot=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{3,2}{2},'string',num2str(varin.shift_bot),'callback',{@ check_fmt_box,0,inf,varin.shift_bot,'%.1f'});
bottom_tab_comp.denoised=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.chckboxStyle,'Value',0,'String','Compute on Denoised data','Position',pos{4,2}{1}+[0 0 100 0]);

try
    [~,~,algo_files]=get_config_files('BottomDetection');
    [~,~,names]=read_config_algo_xml(algo_files{1});
catch
    algo=init_algos('BottomDetection');
    write_config_algo_to_xml(algo,{'--'},0);
    [~,~,names]=read_config_algo_xml(algo_files{1});
end
 
list_params=names;

uicontrol(bottom_tab_comp.bottom_tab,'Style','Text','String','Load Values','Position',pos{1,1}{1}+[0 gui_fmt.y_sep+gui_fmt.box_h 0 0]);
bottom_tab_comp.default_params=uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.popumenuStyle,'String',list_params,'Value',find(strcmpi(list_params,'--')),...
    'Position', pos{1,1}{1}+[gui_fmt.txt_w+gui_fmt.x_sep gui_fmt.y_sep+gui_fmt.box_h 0 0],'callback',{@load_params_v1,main_figure});


uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate_v1,main_figure});
%uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',p_button+[button_w 0 0 0],'callback',{@copy_across_algo,main_figure,'BottomDetection'});
uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'BottomDetection'});
uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Save as','pos',p_button+[3*gui_fmt.button_w 0 0 0],'callback',{@save_new_display_algos_config_callback,main_figure,'BottomDetection'});
uicontrol(bottom_tab_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Delete','pos',p_button+[4*gui_fmt.button_w 0 0 0],'callback',{@delete_display_algos_config_callback,main_figure,'BottomDetection'});

setappdata(main_figure,'Bottom_tab',bottom_tab_comp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

algo=algo_cl('Name','BottomDetectionV2');
varin=algo.Varargin;

bottom_tab_v2_comp.bottom_tab=uipanel(tab_main,'title','Version 2','Position',[0.5 0 0.5 1],'fontsize',11);

uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','BS thr(dB)','pos',pos{1,1}{1});
bottom_tab_v2_comp.thr_bottom=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{1,1}{2},'string',num2str(varin.thr_bottom),'callback',{@ check_fmt_box,-80,-15,varin.thr_bottom,'%.0f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Min Depth(m)','pos',pos{2,1}{2});
bottom_tab_v2_comp.r_min=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(varin.r_min),'callback',{@ check_fmt_box,0,inf,varin.r_min,'%.0f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Max Depth(m)','pos',pos{3,1}{1});
bottom_tab_v2_comp.r_max=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(varin.r_max),'callback',{@ check_fmt_box,0,inf,varin.r_max,'%.1f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Back Thr(dB)','pos',pos{4,1}{1});
bottom_tab_v2_comp.thr_backstep=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(varin.thr_backstep),'callback',{@ check_fmt_box,-12,6,varin.thr_backstep,'%.0f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Around Echo Thr(dB)','pos',pos{1,2}{1});
bottom_tab_v2_comp.thr_echo=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{1,2}{2},'string',num2str(varin.thr_echo),'callback',{@ check_fmt_box,-60,-3,varin.thr_echo,'%.0f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Cumul.Thr(%)','pos',pos{2,2}{1});
bottom_tab_v2_comp.thr_cum=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{2,2}{2},'string',num2str(varin.thr_cum),'callback',{@ check_fmt_box,0,90,varin.thr_cum,'%.g'});


uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'string','Shift Bottom(m)','pos',pos{3,2}{1});
bottom_tab_v2_comp.shift_bot=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.edtStyle,'pos',pos{3,2}{2},'string',num2str(varin.shift_bot),'callback',{@ check_fmt_box,0,inf,varin.shift_bot,'%.1f'});
bottom_tab_v2_comp.denoised=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.chckboxStyle,'Value',0,'String','Compute on Denoised data','Position',pos{4,2}{1}+[0 0 100 0]);

try
    [~,~,algo_files]=get_config_files('BottomDetectionV2');
    [~,~,names]=read_config_algo_xml(algo_files{1});
catch
    algo=init_algos('BottomDetectionV2');
    write_config_algo_to_xml(algo,{'--'},0);
    [~,~,names]=read_config_algo_xml(algo_files{1});
end

uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.txtStyle,'String','Load Values','Position',pos{1,1}{1}+[0 gui_fmt.y_sep+gui_fmt.box_h 0 0]);
list_params=names;

bottom_tab_v2_comp.default_params=uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.popumenuStyle,'String',list_params,'Value',find(strcmpi(list_params,'--')),...
    'Position', pos{1,1}{1}+[gui_fmt.txt_w+gui_fmt.x_sep gui_fmt.y_sep+gui_fmt.box_h 0 0],'callback',{@load_params_v2,main_figure});

uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate_v2,main_figure});
%uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',p_button+[gui_fmt.button_w 0 0 0],'callback',{@copy_across_algo,main_figure,'BottomDetectionV2'});
uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'BottomDetectionV2'});
uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Save as','pos',p_button+[3*gui_fmt.button_w 0 0 0],'callback',{@save_new_display_algos_config_callback,main_figure,'BottomDetectionV2'});
uicontrol(bottom_tab_v2_comp.bottom_tab,gui_fmt.pushbtnStyle,'String','Delete','pos',p_button+[4*gui_fmt.button_w 0 0 0],'callback',{@delete_display_algos_config_callback,main_figure,'BottomDetectionV2'});

setappdata(main_figure,'Bottom_tab_v2',bottom_tab_v2_comp);


end
function load_params_v2(~,~,main_figure)
    update_bottom_tab_v2(main_figure);
end


function load_params_v1(~,~,main_figure)
    update_bottom_tab(main_figure);
end

function validate_v2(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);

old_bot=trans_obj.Bottom;

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('BottomDetectionV2','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);
setappdata(main_figure,'Layer',layer);
bot=trans_obj.Bottom;

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

set_alpha_map(main_figure);
display_bottom(main_figure);
order_stacks_fig(main_figure);

end


function validate_v1(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

old_bot=trans_obj.Bottom;
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('BottomDetection','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);
setappdata(main_figure,'Layer',layer);
bot=trans_obj.Bottom;

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

set_alpha_map(main_figure);
display_bottom(main_figure);
order_stacks_fig(main_figure);

end