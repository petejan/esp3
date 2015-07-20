
function  open_EK60_file(hObject,PathToFile,Filename,ping_start,ping_end,multi_layer,accolate)
curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');

%     profile on;
layers_temp=open_EK60_file_stdalone(hObject,PathToFile,Filename,[],ping_start,ping_end);
%     profile off;
%     profile viewer
%

[layers,layer]=shuffle_layers(layers,layers_temp,multi_layer,accolate);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);

idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
curr_disp.Fieldname=layer.Transceivers(idx_freq).Data.SubData(idx_field).Fieldname;

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);
if exist('opening_file','var')
    close(opening_file);
end

update_display(hObject,1);

end