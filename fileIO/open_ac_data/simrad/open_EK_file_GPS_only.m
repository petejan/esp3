
function  open_EK_file_GPS_only(main_figure,Filename)

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

new_layers=open_EK_file_stdalone(Filename,'GPSOnly',1,'load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

if isempty(new_layers)
    return;
end

new_layers.load_echo_logbook_db();

map_obj=map_input_cl.map_input_cl_from_obj(new_layers);
 
hfigs=getappdata(main_figure,'ExternalFigures');

hfig=new_echo_figure([],'Tag','nav');
map_obj.display_map_input_cl('hfig',hfig,'main_figure',main_figure,'oneMap',1);

hfigs=[hfigs hfig];
setappdata(main_figure,'ExternalFigures',hfigs);

end