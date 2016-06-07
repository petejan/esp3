function axes_panel_comp=display_tracks(xdata,ST,tracks,axes_panel_comp,vis)

X_st=xdata(ST.Ping_number);
Z_st=ST.Target_range_disp;

uu=0;
if isfield(axes_panel_comp,'track_plot')
    for i=1:length(axes_panel_comp.track_plot)
        if ishandle(axes_panel_comp.track_plot(i-uu))
            delete(axes_panel_comp.track_plot(i-uu));
        end
            axes_panel_comp.track_plot(i-uu)=[];
            uu=uu+1;
    end
end

if ~isempty(tracks)
x_lim=get(axes_panel_comp.main_axes,'xlim');

idx_remove=find(cellfun(@(x) ~isempty(find(x<x_lim(1)-diff(x_lim)/10|x>x_lim(2)+diff(x_lim)/10,1)),tracks.target_ping_number));

tracks.target_id(idx_remove)=[];
tracks.target_ping_number(idx_remove)=[];

axes_panel_comp.track_plot=[];

    for k=1:length(tracks.target_id)
        idx_targets=tracks.target_id{k};
        [X_t,idx_sort]=sort(X_st(idx_targets));
        Z_t=Z_st(idx_targets);
        Z_t=Z_t(idx_sort);
        plot_handle=plot(X_t,Z_t,'r','linewidth',2,'tag','track','visible',vis);
        axes_panel_comp.track_plot=[axes_panel_comp.track_plot plot_handle];
    end
else
    axes_panel_comp.track_plot=[];
end


end



