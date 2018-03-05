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

size_bttn_grp=[0 0.6 1 0.4];

display_tab_comp.top_button_group=uipanel(display_tab_comp.display_tab,'units','norm','Position',size_bttn_grp);

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','Chan.','units','pixels','Position',[10 50 50 30]);
display_tab_comp.tog_freq=uicontrol(display_tab_comp.top_button_group,'Style','popupmenu','String','--','Value',1,'units','pixels','Position',[60 50 80 30],...
    'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','Data','units','pixels','Position',[10 10 50 30]);
display_tab_comp.tog_type=uicontrol(display_tab_comp.top_button_group,'Style','popupmenu','String','--','Value',1,'units','pixels','Position',[60 10 120 30],...
    'Callback',{@choose_field,main_figure});

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','X grid:','units','pixels','Position',[190 50 50 30]);
display_tab_comp.grid_x=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[240 55 50 25],'string','');
display_tab_comp.tog_axes=uicontrol(display_tab_comp.top_button_group,'Style','popupmenu','String','--','Value',1,'units','pixels','Position', [295 50 80 30],...
    'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','Y grid:','units','pixels','Position',[190 10 50 30]);
display_tab_comp.grid_y=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[240 15 50 25],'string','');
display_tab_comp.grid_y_unit=uicontrol(display_tab_comp.top_button_group,'Style','Text','unit','pixels','position',[295 10 50 30],'string','meters');

set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})

cax=[0 1];

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','TS(dB)','units','pixels','Position',[375 50 55 30]);
display_tab_comp.TS=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[430 50 40 30],...
    'string',-50,'callback',{@set_TS_cback,main_figure},'TooltipString','TS used for Fish density estimation display');

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','Transp.%','units','pixels','Position',[375 10 55 30]);
display_tab_comp.trans_bot=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[430 10 40 30],...
    'string',num2str(curr_disp.UnderBotTransparency,'%.0f'),'callback',{@set_bot_trans_cback,main_figure},'TooltipString','Under Bottom Data Transparency');

uicontrol(display_tab_comp.top_button_group,'Style','Text','String','C-Max','units','pixels','Position',[480 50 60 30]);
uicontrol(display_tab_comp.top_button_group,'Style','Text','String','C-Min','units','pixels','Position',[480 10 60 30]);
%uicontrol(display_tab_comp.top_button_group,'Style','Text','String','Min','units','pixels','Position',[540 85 60 30],'Fontweight','bold');

display_tab_comp.caxis_up=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[540 50 40 30],'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.top_button_group,'Style','edit','unit','pixels','position',[540 10 40 30],'string',cax(1));

set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});

display_tab_comp.sec_freq_disp=uicontrol(display_tab_comp.top_button_group,'Style','checkbox','Value',curr_disp.DispSecFreqs,...
    'String','Disp Other Channels','units','pixels','Position',[590 10 150 30],...
    'BackgroundColor','w',...
    'callback',{@change_DispSecFreqs_cback,main_figure});

uicontrol(display_tab_comp.top_button_group,'Style','pushbutton','String','Motion','units','pixels','pos',[590 50 60 30],'callback',{@display_attitude_cback,main_figure});
uicontrol(display_tab_comp.top_button_group,'Style','pushbutton','String','Speed','units','pixels','pos',[650 50 60 30],'callback',{@display_speed_callback,main_figure});

%set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Display_tab',display_tab_comp);


end


function change_DispSecFreqs_cback(src,~,main_figure)
	curr_disp=getappdata(main_figure,'Curr_disp');
    curr_disp.DispSecFreqs=get(src,'Value');
end

