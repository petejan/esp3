%% load_display_tab.m
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
% * |main_figure|: Handle to main ESP3 window
% * |option_tab_panel|: TODO: write description and info on variable
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
% * 2015-06-25: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_display_tab(main_figure,option_tab_panel)

curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp.display_tab=uitab(option_tab_panel,'Title','Display Option');
nb_col=6;
size_bttn_grp=[0 0.7 1 0.3];
gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w/2.5;
gui_fmt.box_w=gui_fmt.box_w*2;

pos=create_pos_3(2,nb_col,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);

display_tab_comp.top_button_group=uipanel(display_tab_comp.display_tab,'units','norm','Position',size_bttn_grp);

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','Chan.','Position',pos{1,1}{1});
display_tab_comp.tog_freq=uicontrol(display_tab_comp.top_button_group,gui_fmt.popumenuStyle,'String','--','Value',1,'Position',pos{1,1}{2},...
    'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','Data','Position',pos{2,1}{1});
display_tab_comp.tog_type=uicontrol(display_tab_comp.top_button_group,gui_fmt.popumenuStyle,'String','--','Value',1,'Position',pos{2,1}{2},...
    'Callback',{@choose_field,main_figure});

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','X grid:','Position',pos{1,2}{1});
display_tab_comp.grid_x=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{1,2}{2},'string','');
display_tab_comp.tog_axes=uicontrol(display_tab_comp.top_button_group,gui_fmt.popumenuStyle,'String','--','Value',1,'Position',pos{1,2}{2}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0],...
    'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','Y grid:','Position',pos{2,2}{1});
display_tab_comp.grid_y=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{2,2}{2},'string','');
display_tab_comp.grid_y_unit=uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'position',pos{2,2}{2}+[gui_fmt.box_w+gui_fmt.x_sep 0 0 0],'string','meters');

set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})

cax=[0 1];

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w/1.85;
pos=create_pos_3(2,nb_col,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);


uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','TS(dB)','Position',pos{1,4}{1});
display_tab_comp.TS=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{1,4}{2},...
    'string',-50,'callback',{@set_TS_cback,main_figure},'TooltipString','TS used for Fish density estimation display');

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','Trans.%','Position',pos{2,4}{1});
display_tab_comp.trans_bot=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{2,4}{2},...
    'string',num2str(curr_disp.UnderBotTransparency,'%.0f'),'callback',{@set_bot_trans_cback,main_figure},'TooltipString','Under Bottom Data Transparency');

uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','C-Max','Position',pos{1,5}{1});
uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','C-Min','Position',pos{2,5}{1});
%uicontrol(display_tab_comp.top_button_group,gui_fmt.txtStyle,'String','Min','Position',[540 85 60 30],'Fontweight','bold');

display_tab_comp.caxis_up=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{1,5}{2},'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.top_button_group,gui_fmt.edtStyle,'position',pos{2,5}{2},'string',cax(1));

set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});

p_button=pos{1,6}{1};
p_button(3)=gui_fmt.button_w;

display_tab_comp.sec_freq_disp=uicontrol(display_tab_comp.top_button_group,gui_fmt.chckboxStyle,'Value',curr_disp.DispSecFreqs,...
    'String','Disp Other Channels','Position',pos{2,6}{1}+[0 0 gui_fmt.txt_w 0],...
    'BackgroundColor','w',...
    'callback',{@change_DispSecFreqs_cback,main_figure});

uicontrol(display_tab_comp.top_button_group,gui_fmt.pushbtnStyle,'String','Motion','pos',p_button,'callback',{@display_attitude_cback,main_figure});
uicontrol(display_tab_comp.top_button_group,gui_fmt.pushbtnStyle,'String','Speed','pos',p_button+[gui_fmt.button_w 0 0 0],'callback',{@display_speed_callback,main_figure});

%set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Display_tab',display_tab_comp);


end


function change_DispSecFreqs_cback(src,~,main_figure)
	curr_disp=getappdata(main_figure,'Curr_disp');
    curr_disp.DispSecFreqs=get(src,'Value');
end

