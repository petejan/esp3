%% load_bottom_tab_v2.m
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
function load_bottom_tab_v2(main_figure,algo_tab_panel)

bottom_tab_v2_comp.bottom_tab=uitab(algo_tab_panel,'Title','Bottom Detect V2');

algo=algo_cl('Name','BottomDetectionV2');
varin=algo.Varargin;

x_ini=0.0;
y_ini=1;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(4,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(bottom_tab_v2_comp.bottom_tab,'title','','Position',[0.01 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_1,'Style','text','units','normalized','string','BS thr(dB)','pos',pos{1,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.thr_bottom=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.thr_bottom),'BackgroundColor','white','callback',{@ check_fmt_box,-80,-15,varin.thr_bottom,'%.0f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Min Depth(m)','pos',pos{2,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.r_min=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.r_min),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.r_min,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Max Depth(m)','pos',pos{3,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.r_max=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.r_max),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.r_max,'%.2f'});


uicontrol(parameters_1,'Style','text','units','normalized','string','Back Thr(dB)','pos',pos{4,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.thr_backstep=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.thr_backstep),'BackgroundColor','white','callback',{@ check_fmt_box,-12,6,varin.thr_backstep,'%.0f'});

parameters_2=uipanel(bottom_tab_v2_comp.bottom_tab,'title','','Position',[0.32 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_2,'Style','text','units','normalized','string','Around Echo Thr(dB)','pos',pos{1,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.thr_echo=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.thr_echo),'BackgroundColor','white','callback',{@ check_fmt_box,-60,-3,varin.thr_echo,'%.0f'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Cumul.Thr(%)','pos',pos{2,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.thr_cum=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.thr_cum),'BackgroundColor','white','callback',{@ check_fmt_box,0,0.9,varin.thr_cum,'%.g'});


uicontrol(parameters_2,'Style','text','units','normalized','string','Shift Bottom(m)','pos',pos{3,1},'HorizontalAlignment','right');
bottom_tab_v2_comp.shift_bot=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.shift_bot),'BackgroundColor','white','callback',{@ check_fmt_box,0,inf,varin.shift_bot,'%.2f'});
bottom_tab_v2_comp.denoised=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','checkbox','Value',0,'String','Compute on Denoised data','units','normalized','Position',[0.7 0.3 0.3 0.1]);


uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Defaults Values','units','normalized','Position',[0.7 0.8 0.2 0.1]);
list_params={'--','Flat Hard','Flat Soft','Hills'};
bottom_tab_v2_comp.default_params=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','popupmenu','String',list_params,'Value',1,'units','normalized','Position', [0.7 0.7 0.2 0.1],'callback',{@load_default_params,main_figure});

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.85 0.1 0.1 0.12],'callback',{@validate,main_figure});
uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.75 0.1 0.1 0.12],'callback',{@copy_across_algo,main_figure,'BottomDetection'});
uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.65 0.1 0.1 0.12],'callback',{@save_algos,main_figure});


setappdata(main_figure,'Bottom_tab_v2',bottom_tab_v2_comp);


end

function load_default_params(src,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);


[idx_algo,found]=find_algo_idx(trans_obj,'BottomDetectionV2');
if found==0
    return
end


switch src.String{src.Value}
    case 'Flat Hard'
        
        trans_obj.Algo(idx_algo).Varargin.thr_bottom=-30;
        trans_obj.Algo(idx_algo).Varargin.thr_backstep= 1;
        trans_obj.Algo(idx_algo).Varargin.thr_echo= -20;
        trans_obj.Algo(idx_algo).Varargin.thr_cum= 0.1;
        trans_obj.Algo(idx_algo).Varargin.shift_bot= 0;
        
    case 'Flat Soft'        
        trans_obj.Algo(idx_algo).Varargin.thr_bottom= -40;
        trans_obj.Algo(idx_algo).Varargin.thr_backstep= -3;
        trans_obj.Algo(idx_algo).Varargin.thr_echo= -30;
        trans_obj.Algo(idx_algo).Varargin.thr_cum= 1e-6;
        trans_obj.Algo(idx_algo).Varargin.shift_bot= 0;
        
    case 'Hills'
        trans_obj.Algo(idx_algo).Varargin.thr_bottom= -45;
        trans_obj.Algo(idx_algo).Varargin.thr_backstep= -3;
        trans_obj.Algo(idx_algo).Varargin.thr_echo= -20;
        trans_obj.Algo(idx_algo).Varargin.thr_cum= 1e-6;
        trans_obj.Algo(idx_algo).Varargin.shift_bot= 0;
        
    otherwise
        return;
end
setappdata(main_figure,'Layer',layer);
update_bottom_tab_v2(main_figure);

end


function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('BottomDetectionV2','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end

