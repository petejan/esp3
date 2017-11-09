function disp_ping_config_params_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans_obj=trans_obj;

ax_main=axes_panel_comp.main_axes;
x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

xdata=trans_obj.get_transceiver_pings();

[~,idx_ping]=nanmin(abs(xdata-x));

hfigs=getappdata(main_figure,'ExternalFigures');

hfigs(~isvalid(hfigs))=[];
idx_tag=find(strcmpi({hfigs(:).Tag},sprintf('config_params%s',trans_obj.Config.ChannelID)));
if ~isempty(idx_tag)
    close(hfigs(idx_tag(1)));
end

new_fig=trans_obj.disp_config_params('idx_ping',idx_ping);

hfigs_new=[hfigs new_fig];
setappdata(main_figure,'ExternalFigures',hfigs_new);

end