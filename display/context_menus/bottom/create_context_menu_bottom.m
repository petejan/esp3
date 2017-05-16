%% create_context_menu_bottom.m
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
% * |bottom_line|: TODO: write description and info on variable
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
% * 2017-03-29: header (Alex Schimel).
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function create_context_menu_bottom(main_figure,bottom_line)

context_menu=uicontextmenu(ancestor(bottom_line,'figure'));
bottom_line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Display Bottom Region','Callback',@display_bottom_region_callback);
uimenu(context_menu,'Label','Filter Bottom','Callback',@filter_bottom_callback);
% uimenu(context_menu,'Label','Display Slope estimation','Callback',@slope_est_callback);
% uimenu(context_menu,'Label','Display Shadow zone height estimation','Callback',@shadow_zone_est_callback);
uimenu(context_menu,'Label','Display Shadow zone content estimation (10m X 10m)','Callback',@shadow_zone_content_est_callback);

end

% 
% function shadow_zone_est_callback(src,~)
% main_figure=ancestor(src,'Figure');
% 
% layer=getappdata(main_figure,'Layer');
% curr_disp=getappdata(main_figure,'Curr_disp');
% idx_freq=find_freq_idx(layer,curr_disp.Freq);
% trans_obj=layer.Transceivers(idx_freq);
% 
% [shadow_zone_height_est,~] = trans_obj.get_shadow_zone_height_est();
% 
% fig_handle=new_echo_figure(main_figure,'Tag','shadow_zone');
% ax=axes(fig_handle);
% plot(ax,shadow_zone_height_est);
% grid(ax,'on');
% xlabel(ax,'Ping number')
% ylabel(ax,'Shadow Zone (m)');
% 
% end

function shadow_zone_content_est_callback(src,~)
main_figure=ancestor(src,'Figure');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

[outer_reg,slope_est,shadow_height_est]=trans_obj.estimate_shadow_zone('DispReg',1,'intersect_only',0);

fig_handle=new_echo_figure(main_figure,'Tag','shadow_zone');
ax1=axes(fig_handle,'nextplot','add','units','normalized','OuterPosition',[0 0.5 1 0.5]);
yyaxis(ax1,'left');
plot(ax1,shadow_height_est);
grid(ax1,'on');
xlabel(ax1,'Ping number')
ylabel(ax1,'Shadow Zone (m)');
yyaxis(ax1,'right');
plot(ax1,slope_est);
xlabel(ax1,'Ping number')
ylabel(ax1,'Slope (deg)');


ax2=axes(fig_handle,'nextplot','add','units','normalized','OuterPosition',[0 0 1 0.5]);
plot((outer_reg.Ping_E+outer_reg.Ping_S)/2,pow2db_perso(outer_reg.Sv_mean_lin),'k')
xlabel(ax2,'Ping number')
ylabel(ax2,'Sv mean(m)')
grid(ax2,'on');

linkaxes([ah,ax1,ax2],'x');

end
% 
% function slope_est_callback(src,~)
% main_figure=ancestor(src,'Figure');
% 
% layer=getappdata(main_figure,'Layer');
% curr_disp=getappdata(main_figure,'Curr_disp');
% idx_freq=find_freq_idx(layer,curr_disp.Freq);
% trans_obj=layer.Transceivers(idx_freq);
% 
% slope_est=trans_obj.get_slope_est();
% 
% fig_handle=new_echo_figure(main_figure,'Tag','slope_est');
% ax=axes(fig_handle);
% plot(ax,slope_est);
% grid(ax,'on');
% xlabel(ax,'Ping number')
% ylabel(ax,'Slope (deg)');
% 
% end

function display_bottom_region_callback(src,~)
main_figure=ancestor(src,'Figure');
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

bot_range=trans_obj.get_bottom_range();
nb_pings=length(bot_range);
mean_depth=nanmean(trans_obj.get_bottom_range());

% profile on;

reg_wc=trans_obj.create_WC_region('y_min',mean_depth/50,...
    'y_max',0,...
    'Type','Data',...
    'Ref','Bottom',...
    'Cell_w',floor(nb_pings/100)+1,...
    'Cell_h',mean_depth/200,...
    'Cell_w_unit','pings',...
    'Cell_h_unit','meters');

reg_wc.display_region(trans_obj,'main_figure',main_figure);

% profile off;
% profile viewer;

end

function filter_bottom_callback(src,~)
main_figure=ancestor(src,'Figure');
prompt={'Filter Width (in pings)'};
defaultanswer={'10'};

answer=inputdlg(prompt,'Filter Width (in pings)',1,defaultanswer);

if isempty(answer)
    answer=defaultanswer;
end
if ~isnan(str2double(answer{1}))
    w_filter=str2double(answer{1});
else
    warning('Invalid filter_width');
    return
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

trans_obj.filter_bottom('FilterWidth',w_filter);

curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');

end