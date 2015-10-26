function display_navigation_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
hfigs=getappdata(main_figure,'ExternalFigures');


map_input=map_input_cl.map_input_cl_from_obj(layer,'SliceSize',0);
if nansum(isnan(map_input.LatLim))>=1
    return;
end

hfig=figure('Name','Navigation','NumberTitle','off','tag','nav');
map_input.display_map_input_cl(hfig);

hfigs=[hfigs hfig];
setappdata(main_figure,'ExternalFigures',hfigs);

end