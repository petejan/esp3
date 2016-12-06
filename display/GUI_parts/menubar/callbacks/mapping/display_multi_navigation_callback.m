function display_multi_navigation_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');


map_input=map_input_cl.map_input_cl_from_obj(layers,'SliceSize',0);

if nansum(isnan(map_input.LatLim))>=1
    return;
end

hfig=map_input.display_map_input_cl('main_figure',main_figure,'oneMap',1);
new_echo_figure(main_figure,'fig_handle',hfig);

end