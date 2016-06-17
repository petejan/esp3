function toggle_disp_tracks(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

if isfield(axes_panel_comp,'track_plot')
    for i=1:length(axes_panel_comp.track_plot)
        if ishandle(axes_panel_comp.track_plot(i))
            set(axes_panel_comp.track_plot(i),'visible',curr_disp.DispTracks);
        else
            axes_panel_comp.track_plot(i)=[];
        end
    end
end
    
end

