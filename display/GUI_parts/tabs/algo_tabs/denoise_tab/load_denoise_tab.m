%% load_denoise_tab.m
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
function load_denoise_tab(main_figure,algo_tab_panel)

denoise_tab_comp.denoise_tab=uitab(algo_tab_panel,'Title','Denoise');

algo=algo_cl('Name','Denoise');
varin=algo.Varargin;

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*2;

pos=create_pos_3(5,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{5,1}{1};
p_button(3)=gui_fmt.button_w;


uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.txtStyle,'string','Horz. Filt.(nb pings)','pos',pos{1,1}{1});
denoise_tab_comp.HorzFilt=uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.edtStyle,'pos',pos{1,1}{2},'string',num2str(varin.HorzFilt),'callback',{@ check_fmt_box,1,inf,varin.HorzFilt,'%.0f'});


uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.txtStyle,'string','Vert. Filt.(m)','pos',pos{2,1}{1});
denoise_tab_comp.VertFilt=uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(varin.VertFilt),'callback',{@ check_fmt_box,0,inf,varin.VertFilt,'%.2f'});


uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.txtStyle,'string','Noise Level Thr(db)','pos',pos{3,1}{1});
denoise_tab_comp.NoiseThr=uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(varin.NoiseThr),'callback',{@ check_fmt_box,-180,-80,varin.NoiseThr,'%.0f'});


uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.txtStyle,'string','SNR Thr(dB)','pos',pos{4,1}{1});
denoise_tab_comp.SNRThr=uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(varin.SNRThr),'callback',{@ check_fmt_box,0,30,varin.SNRThr,'%.0f'});


uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate,main_figure});
%uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',[0.75 0.1 0.1 0.1],'callback',{@copy_across_algo,main_figure,'Denoise'});
uicontrol(denoise_tab_comp.denoise_tab,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'Denoise'});


%set(findall(denoise_tab_comp.denoise_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Denoise_tab',denoise_tab_comp);

end



function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,~]=layer.get_trans(curr_disp);


show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('Denoise','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

curr_disp.setField('svdenoised');


end
