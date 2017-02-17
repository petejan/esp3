function display_navigation_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
map_input=map_input_cl.map_input_cl_from_obj(layer,'SliceSize',0);
if nansum(isnan(map_input.LatLim))>=1
    return;
end
layers_Str=list_layers(layer);
hfig=new_echo_figure(main_figure,'Name',sprintf('Navigation  %s',layers_Str{1}),'Tag','nav');
map_input.display_map_input_cl('hfig',hfig,'main_figure',main_figure);

new_fig=layer.Transceivers(idx_freq).GPSDataPing.display_speed();
new_echo_figure(main_figure,'fig_handle',new_fig,'Tag','speed','Name',sprintf('Speed  %s',layers_Str{1}));


end