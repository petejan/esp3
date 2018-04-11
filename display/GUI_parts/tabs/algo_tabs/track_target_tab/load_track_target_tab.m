%% load_track_target_tab.m
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
function load_track_target_tab(main_figure,algo_tab_panel)


track_target_tab_comp.track_target_tab=uitab(algo_tab_panel,'Title','Target Tracking');

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(7,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

p_button=pos{6,1}{1};
p_button(3)=gui_fmt.button_w;

next_w=[gui_fmt.x_sep+gui_fmt.box_w 0 0 0];

alpha_beta=uipanel(track_target_tab_comp.track_target_tab,'title','Alpha/Beta tracking','Position',[0.0 0.0 0.45 1],'fontsize',11,'Tag','alpha_beta');

uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Al.','pos',pos{1,1}{2},'HorizontalAlignment','left','tooltipstring','AlongShip');
uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Ac.','pos',pos{1,1}{2}+next_w,'HorizontalAlignment','left','tooltipstring','AcrossShip');
uicontrol(alpha_beta,gui_fmt.txtStyle,'string','R.','pos',pos{1,1}{2}+2*next_w,'HorizontalAlignment','left','tooltipstring','Range');

uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Alpha','pos',pos{2,1}{1});
track_target_tab_comp.AlphaMinAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(0.3),'callback',{@check_box,[0 1]});
track_target_tab_comp.AlphaMajAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{2,1}{2}+next_w,'string',num2str(0.3),'callback',{@check_box,[0 1]});
track_target_tab_comp.AlphaRange=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{2,1}{2}+2*next_w,'string',num2str(0.3),'callback',{@check_box,[0 1]});

uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Beta','pos',pos{3,1}{1});
track_target_tab_comp.BetaMinAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(0.5),'callback',{@check_box,[0 1]});
track_target_tab_comp.BetaMajAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{3,1}{2}+next_w,'string',num2str(0.5),'callback',{@check_box,[0 1]});
track_target_tab_comp.BetaRange=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{3,1}{2}+2*next_w,'string',num2str(0.5),'callback',{@check_box,[0 1]});

uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Excl dist(m)','pos',pos{4,1}{1});
track_target_tab_comp.ExcluDistMinAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(1),'callback',{@check_box,[0 50]});
track_target_tab_comp.ExcluDistMajAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{4,1}{2}+next_w,'string',num2str(1),'callback',{@check_box,[0 50]});
track_target_tab_comp.ExcluDistRange=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{4,1}{2}+2*next_w,'string',num2str(1),'callback',{@check_box,[0 50]});


uicontrol(alpha_beta,gui_fmt.txtStyle,'string',['Angle Uncert.(' char(hex2dec('00B0')) ')'],'pos',pos{5,1}{1});
track_target_tab_comp.MaxStdMinorAxisAngle=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{5,1}{2},'string',num2str(1),'callback',{@check_box,[0 50]});
track_target_tab_comp.MaxStdMajorAxisAngle=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{5,1}{2}+next_w,'string',num2str(1),'callback',{@check_box,[0 50]});

uicontrol(alpha_beta,gui_fmt.txtStyle,'string','Ping exp(%)','pos',pos{6,1}{1});
track_target_tab_comp.MissedPingExpMinAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{6,1}{2},'string',num2str(5),'callback',{@check_box,[0 100]});
track_target_tab_comp.MissedPingExpMajAxis=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{6,1}{2}+next_w,'string',num2str(5),'callback',{@check_box,[0 100]});
track_target_tab_comp.MissedPingExpRange=uicontrol(alpha_beta,gui_fmt.edtStyle,'pos',pos{6,1}{2}+2*next_w,'string',num2str(5),'callback',{@check_box,[0 100]});


weights_panel=uipanel(track_target_tab_comp.track_target_tab,'title','Weights','Position',[0.45 0 0.25 1],'fontsize',11,'Tag','exclu_dist');

uicontrol(weights_panel,gui_fmt.txtStyle,'string','Along','pos',pos{2,1}{1});
track_target_tab_comp.WeightMinAxis=uicontrol(weights_panel,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(20),'callback',{@check_box,[0 100]});

uicontrol(weights_panel,gui_fmt.txtStyle,'string','Across','pos',pos{3,1}{1});
track_target_tab_comp.WeightMajAxis=uicontrol(weights_panel,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(20),'callback',{@check_box,[0 100]});

uicontrol(weights_panel,gui_fmt.txtStyle,'string','Range','pos',pos{4,1}{1});
track_target_tab_comp.WeightRange=uicontrol(weights_panel,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(20),'callback',{@check_box,[0 100]});

uicontrol(weights_panel,gui_fmt.txtStyle,'string','TS','pos',pos{5,1}{1});
track_target_tab_comp.WeightTS=uicontrol(weights_panel,gui_fmt.edtStyle,'pos',pos{5,1}{2},'string',num2str(20),'callback',{@check_box,[0 100]});

uicontrol(weights_panel,gui_fmt.txtStyle,'string','Ping Gap','pos',pos{6,1}{1});
track_target_tab_comp.WeightPingGap=uicontrol(weights_panel,gui_fmt.edtStyle,'pos',pos{6,1}{2},'string',num2str(20),'callback',{@check_box,[0 100]});


accept=uipanel(track_target_tab_comp.track_target_tab,'title','Track acceptance','Position',[0.7 0 0.3 1],'fontsize',11,'Tag','accept');

uicontrol(accept,gui_fmt.txtStyle,'string','MinST #','pos',pos{2,1}{1});
track_target_tab_comp.Min_ST_Track=uicontrol(accept,gui_fmt.edtStyle,'pos',pos{2,1}{2},'string',num2str(5),'callback',{@check_box,[0 200]});

uicontrol(accept,gui_fmt.txtStyle,'string','MinPings #','pos',pos{3,1}{1});
track_target_tab_comp.Min_Pings_Track=uicontrol(accept,gui_fmt.edtStyle,'pos',pos{3,1}{2},'string',num2str(8),'callback',{@check_box,[0 100]});

uicontrol(accept,gui_fmt.txtStyle,'string','MaxPingGap #','pos',pos{4,1}{1});
track_target_tab_comp.Max_Gap_Track=uicontrol(accept,gui_fmt.edtStyle,'pos',pos{4,1}{2},'string',num2str(2),'callback',{@check_box,[0 100]});

track_target_tab_comp.IgnoreAttitude=uicontrol(accept,'Style','checkbox','Value',0,'String','Ignore Attitude','Position',pos{5,1}{1});


uicontrol(accept,gui_fmt.pushbtnStyle,'String','Apply','pos',p_button+[1*gui_fmt.button_w 0 0 0],'callback',{@validate,main_figure});
%uicontrol(track_target_tab_comp.track_target_tab,gui_fmt.pushbtnStyle,'String','Copy','pos',[0.6 0.05 0.1 0.1],'callback',{@copy_across_algo,main_figure,'TrackTarget'});
uicontrol(accept,gui_fmt.pushbtnStyle,'String','Save','pos',p_button+[2*gui_fmt.button_w 0 0 0],'callback',{@save_display_algos_config_callback,main_figure,'TrackTarget'});


%set(findall(track_target_tab_comp.track_target_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Track_target_tab',track_target_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,~]=layer.get_trans(curr_disp);
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
trans_obj.apply_algo('TrackTarget','load_bar_comp',load_bar_comp);
hide_status_bar(main_figure);
if~isempty(layer.Curves)
    layer.Curves(contains({layer.Curves(:).Unique_ID},'track'))=[];
end
setappdata(main_figure,'Layer',layer);
display_tracks(main_figure);
update_track_target_tab(main_figure);
update_multi_freq_disp_tab(main_figure,'ts_f',1);
end


function check_box(hObject,~,min_max)
user_entry = str2double(get(hObject,'string'));
if isnan(user_entry)||user_entry<min_max(1)||user_entry>min_max(2)
    set(hObject,'string',min_max(1));
    warndlg(['Input outside range [' num2str(min_max(1)) ' ' num2str(min_max(2)) ']'] ,'Bad Input','modal')
    uicontrol(hObject);
end
end

    
