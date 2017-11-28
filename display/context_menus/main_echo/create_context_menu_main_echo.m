function create_context_menu_main_echo(main_figure)
%tic;
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

delete(findall(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu'));
context_menu=uicontextmenu(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu');
axes_panel_comp.bad_transmits.UIContextMenu=context_menu;
analysis_menu=uimenu(context_menu,'Label','Analysis');
uimenu(analysis_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});
uimenu(analysis_menu,'Label','Remove Tracks','Callback',{@remove_tracks_cback,main_figure});
uimenu(analysis_menu,'Label','Remove ST','Callback',{@remove_ST_cback,main_figure});

if strcmpi(trans_obj.Mode,'FM')
    uimenu(analysis_menu,'Label','Plot Ping TS Spectrum','Callback',{@plot_ping_spectrum_callback,main_figure});
    uimenu(analysis_menu,'Label','Plot Ping Sv Spectrum','Callback',{@plot_ping_sv_spectrum_callback,main_figure});
end

survey_menu=uimenu(context_menu,'Label','Survey Data');
uimenu(survey_menu,'Label','Edit Voyage Info','Callback',{@edit_trip_info_callback,main_figure});
uimenu(survey_menu,'Label','Edit/Add Survey Data','Callback',{@edit_survey_data_callback,main_figure,0});
uimenu(survey_menu,'Label','Edit/Add Survey Data for this file','Callback',{@edit_survey_data_curr_file_callback,main_figure});
uimenu(survey_menu,'Label','Remove Survey Data','Callback',{@edit_survey_data_callback,main_figure,1});
uimenu(survey_menu,'Label','Split Transect Here','Callback',{@split_transect_callback,main_figure});

tools_menu=uimenu(context_menu,'Label','Tools');
uimenu(tools_menu,'Label','Correct this transect position based on cable angle and towbody depth','Callback',{@correct_pos_angle_depth_sector_cback,main_figure});

bt_menu=uimenu(context_menu,'Label','Bad Transmits');
uifreq=uimenu(bt_menu,'Label','Copy to other channels');
uimenu(uifreq,'Label','all','Callback',{@copy_bt_cback,main_figure,[]});
idx_higher_freq=find(layer.Frequencies>layer.Frequencies(idx_freq));
idx_other=setdiff(1:numel(layer.Frequencies),idx_freq);
uimenu(uifreq,'Label','Higher Frequencies','Callback',{@copy_bt_cback,main_figure,idx_higher_freq});
for ifreq=idx_other
    uimenu(uifreq,'Label',sprintf('%.0fkHz',layer.Frequencies(ifreq)/1e3),'Callback',{@copy_bt_cback,main_figure,ifreq});
end

config_menu=uimenu(context_menu,'Label','Configuration');
uimenu(config_menu,'Label','Display Current Ping Config','Callback',{@disp_ping_config_params_callback,main_figure});
%toc
end

function copy_bt_cback(src,~,main_figure,ifreq)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[~,idx_freq]=layer.get_trans(curr_disp);

[bots,ifreq]=layer.generate_bottoms_for_other_freqs(idx_freq,ifreq);

for i=1:numel(ifreq)
    old_bot=layer.Transceivers(ifreq(i)).Bottom;
    bots(i).Sample_idx=old_bot.Sample_idx;
    layer.Transceivers(ifreq(i)).Bottom=bots(i);
    add_undo_bottom_action(main_figure,layer.Transceivers(ifreq(i)),old_bot,bots(i));
end

display_bottom(main_figure);
set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID(ifreq)));

end


function correct_pos_angle_depth_sector_cback(src,~,main_figure)


layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans=trans_obj;

ax_main=axes_panel_comp.main_axes;
x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

xdata=trans.get_transceiver_pings();

[~,idx_ping]=nanmin(abs(xdata-x));

time=trans.Time;
t_n=time(idx_ping);



prompt={'Towing cable angle (in degree)','Towbody depth'};
defaultanswer={'25','500'};

answer=inputdlg(prompt,'Correct position',1,defaultanswer);

if isempty(answer)
    return;
end


angle_deg=str2double(answer{1});

if isnan(angle_deg)
     warning('Invalid Angle');
    return;
end

depth_m=str2double(answer{2});

if isnan(depth_m)
     warning('Invalid Depth');
    return;
end

[surv,~]=layer.get_survdata_at_time(t_n);

[~,idx_ts]=nanmin(abs(time-surv.StartTime));
[~,idx_te]=nanmin(abs(time-surv.EndTime));

idx_t=idx_ts:idx_te;

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);


gps_data=trans_obj.GPSDataPing;

[new_lat,new_long,hfig]=correct_pos_angle_depth(gps_data.Lat(idx_t),gps_data.Long(idx_t),angle_deg,depth_m,curr_disp.Proj);

% Construct a questdlg with three options
choice = questdlg('Would you like to use this corrected track (in red)?', ...
	'?', ...
	'Yes','No','No');
close(hfig);

switch choice
    case 'Yes'
        trans_obj.GPSDataPing.Lat(idx_t)=new_lat;
        trans_obj.GPSDataPing.Long(idx_t)=new_long;
        layer.replace_gps_data_layer(trans_obj.GPSDataPing);
        save_gps_callback([],[],main_figure,1);
    case 'No'
        return;
        
end


update_map_tab(main_figure);

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

set_alpha_map(main_figure);

end