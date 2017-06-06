function axes_panel_comp=display_tracks(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
ST=trans_obj.ST;
tracks=trans_obj.Tracks;
xdata=trans_obj.get_transceiver_pings();

X_st=xdata(ST.Ping_number);
Z_st=ST.idx_r;

if isfield(axes_panel_comp,'track_plot')
    delete(axes_panel_comp.track_plot);
    axes_panel_comp.track_plot=[];
    delete(findobj(axes_panel_comp.main_axes,'Tag','track'));
end

if ~isempty(tracks)
x_lim=get(axes_panel_comp.main_axes,'xlim');

idx_remove=find(cellfun(@(x) any(x<x_lim(1)-diff(x_lim)/10|x>x_lim(2)+diff(x_lim)/10),tracks.target_ping_number));

tracks.target_id(idx_remove)=[];
tracks.target_ping_number(idx_remove)=[];

axes_panel_comp.track_plot=[];

    for k=1:length(tracks.target_id)
        idx_targets=tracks.target_id{k};
        [X_t,idx_sort]=sort(X_st(idx_targets));
        Z_t=Z_st(idx_targets);
        Z_t=Z_t(idx_sort);
        plot_handle=plot(axes_panel_comp.main_axes,X_t,Z_t,'r','linewidth',2,'tag','track','visible',curr_disp.DispTracks);
        axes_panel_comp.track_plot=[axes_panel_comp.track_plot plot_handle];
    end
else
    axes_panel_comp.track_plot=[];
end


end



