
function  open_EK60_file_GPS_only(hObject,Filename)

new_layers=open_EK60_file_stdalone(Filename,'GPSOnly',1);
        

if isempty(new_layers)
    return;
end


new_layers.load_echo_logbook();

new_layers_sorted=new_layers.sort_per_survey_data();

disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',0)];
end


map_obj=map_input_cl.map_input_cl_from_obj(layers_out);
 
hfigs=getappdata(hObject,'ExternalFigures');

hfig=figure();
map_obj.display_map_input_cl('hfig',hfig,'main_figure',hObject,'oneMap',1);

hfigs=[hfigs hfig];
setappdata(hObject,'ExternalFigures',hfigs);

end