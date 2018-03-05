function load_single_target_tab(main_figure,algo_tab_panel)

single_target_tab_comp.single_target_tab=uitab(algo_tab_panel,'Title','Single Targets');


algo=algo_cl('Name','SingleTarget');
varin=algo.Varargin;

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(6,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{5,1}{1};
p_button(3)=gui_fmt.button_w;


uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string','TS thr(dB)','pos',pos{1,1}{1});
single_target_tab_comp.TS_threshold=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{1,1}{2},'string',num2str(varin.TS_threshold),'callback',{@ check_fmt_box,-120,-10,varin.TS_threshold,'%.0f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string','PLDL(dB)','pos',pos{2,1}{1});
single_target_tab_comp.PLDL=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(varin.PLDL),'callback',{@ check_fmt_box,1,12,varin.PLDL,'%.0f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string','Min Norm PL','pos',pos{3,1}{1});
single_target_tab_comp.MinNormPL=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(varin.MinNormPL),'callback',{@ check_fmt_box,0.2,2,varin.MinNormPL,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string','Max Norm PL','pos',pos{4,1}{1});
single_target_tab_comp.MaxNormPL=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(varin.MaxNormPL),'callback',{@ check_fmt_box,0.2,2,varin.MaxNormPL,'%.1f'});


uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string','Max. Beam Comp.','pos',pos{1,2}{1});
single_target_tab_comp.MaxBeamComp=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{1,2}{2},'string',num2str(varin.MaxBeamComp),'callback',{@ check_fmt_box,3,18,varin.MaxBeamComp,'%.0f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string',[char(hex2dec('0394')) ' Along Angle(' char(hex2dec('00B0')) ')'],'pos',pos{2,2}{1});
single_target_tab_comp.MaxStdMinAxisAngle=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{2,2}{2},'string',num2str(varin.MaxStdMinAxisAngle),'callback',{@ check_fmt_box,0,45,varin.MaxStdMinAxisAngle,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.txtStyle,'string',[char(hex2dec('0394')) ' Across Angle(' char(hex2dec('00B0')) ')'],'pos',pos{3,2}{1});
single_target_tab_comp.MaxStdMajAxisAngle=uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.edtStyle,'pos',pos{3,2}{2},'string',num2str(varin.MaxStdMajAxisAngle),'callback',{@ check_fmt_box,0,45,varin.MaxStdMajAxisAngle,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate,main_figure});
%uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@copy_across_algo,main_figure,'SingleTarget'});
uicontrol(single_target_tab_comp.single_target_tab,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'SingleTarget'});

%set(findall(single_target_tab_comp.single_target_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Single_target_tab',single_target_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('SingleTarget','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);
curr_disp.setField('singletarget');
display_tracks(main_figure);
setappdata(main_figure,'Curr_disp',curr_disp);
update_single_target_tab(main_figure,0);
update_track_target_tab(main_figure);
end




