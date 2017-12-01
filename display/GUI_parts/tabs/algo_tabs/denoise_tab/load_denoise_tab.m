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

x_ini=0.0;
y_ini=1;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(4,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(denoise_tab_comp.denoise_tab,'title','','Position',[0. 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_1,'Style','text','units','normalized','string','Horz. Filt.(nb pings)','pos',pos{1,1},'HorizontalAlignment','right');
denoise_tab_comp.HorzFilt=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.HorzFilt),'BackgroundColor','white','callback',{@ check_fmt_box,1,inf,varin.HorzFilt,'%.0f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Vert. Filt.(m)','pos',pos{2,1},'HorizontalAlignment','right');
denoise_tab_comp.VertFilt=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.VertFilt),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.VertFilt,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Noise Level Thr(db)','pos',pos{3,1},'HorizontalAlignment','right');
denoise_tab_comp.NoiseThr=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.NoiseThr),'BackgroundColor','white','callback',{@ check_fmt_box,-180,-80,varin.NoiseThr,'%.0f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','SNR Thr(dB)','pos',pos{4,1},'HorizontalAlignment','right');
denoise_tab_comp.SNRThr=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.SNRThr),'BackgroundColor','white','callback',{@ check_fmt_box,0,30,varin.SNRThr,'%.0f'});


uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.85 0.1 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.75 0.1 0.1 0.1],'callback',{@copy_across_algo,main_figure,'Denoise'});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.65 0.1 0.1 0.1],'callback',{@save_display_algos_config_callback,main_figure,'Denoise'});


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
