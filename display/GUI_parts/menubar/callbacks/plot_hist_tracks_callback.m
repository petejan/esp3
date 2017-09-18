function plot_hist_tracks_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

display_st_or_track_hist(main_figure,ax,'track');


end