
function  open_EK_file_GPS_only(hObject,Filename)

new_layers=open_EK_file_stdalone(Filename,'GPSOnly',1);
        

if isempty(new_layers)
    return;
end


new_layers.load_echo_logbook_db();


map_obj=map_input_cl.map_input_cl_from_obj(new_layers);
 
hfigs=getappdata(hObject,'ExternalFigures');

hfig=new_echo_figure([],'Tag','nav');
map_obj.display_map_input_cl('hfig',hfig,'main_figure',hObject,'oneMap',1);

hfigs=[hfigs hfig];
setappdata(hObject,'ExternalFigures',hfigs);

end