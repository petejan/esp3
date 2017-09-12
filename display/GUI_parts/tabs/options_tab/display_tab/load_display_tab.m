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

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Freq.','units','normalized','Position',[0 0.85 0.1 0.1]);
display_tab_comp.tog_freq=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.1 0.85 0.15 0.1],...
    'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Data','units','normalized','Position',[0 0.7 0.1 0.1]);
display_tab_comp.tog_type=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.1 0.7 0.15 0.1],...
    'Callback',{@choose_field,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','X grid:','units','normalized','Position',[0.25 0.85 0.1 0.1]);
display_tab_comp.grid_x=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.35 0.85 0.1 0.1],'string','');
display_tab_comp.tog_axes=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String','--','Value',1,'units','normalized','Position', [0.5 0.85 0.1 0.1],...
    'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Y grid:','units','normalized','Position',[0.25 0.7 0.1 0.1]);
display_tab_comp.grid_y=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.35 0.7 0.1 0.1],'string','');
display_tab_comp.grid_y_unit=uicontrol(display_tab_comp.display_tab,'Style','Text','unit','normalized','position',[0.5 0.7 0.1 0.1],'string','meters');

set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})

cax=[0 1];

uicontrol(display_tab_comp.display_tab,'Style','Text','String','TS(dB)','units','normalized','Position',[0.6 0.85 0.1 0.1]);
display_tab_comp.TS=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.7 0.85 0.05 0.1],...
    'string',-50,'callback',{@set_TS_cback,main_figure},'TooltipString','TS used for Fish density estimation display');

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Transp.%','units','normalized','Position',[0.6 0.7 0.1 0.1]);
display_tab_comp.trans_bot=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.7 0.7 0.05 0.1],...
    'string',num2str(curr_disp.UnderBotTransparency,'%.0f'),'callback',{@set_bot_trans_cback,main_figure},'TooltipString','Under Bottom Data Transparency');

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Max','units','normalized','Position',[0.8 0.85 0.1 0.1]);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Min','units','normalized','Position',[0.8 0.7 0.1 0.1]);

display_tab_comp.caxis_up=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.9 0.85 0.05 0.1],'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.9 0.7 0.05 0.1],'string',cax(1));

set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Att.','units','normalized','pos',[0.8725 0.25 0.1 0.15],'callback',{@display_attitude_cback,main_figure});
uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Speed.','units','normalized','pos',[0.8725 0.1 0.1 0.15],'callback',{@display_speed_callback,main_figure});

%set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Display_tab',display_tab_comp);


end
