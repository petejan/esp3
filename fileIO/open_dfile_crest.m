function  open_dfile_crest(hObject,PathToFile,Filename_cell,CVSCheck)

curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');



layers_temp=read_crest(PathToFile,Filename_cell,'PathToMemmap',app_path.data,'CVSCheck',CVSCheck);

disp('Shuffling layers');
[layers,layer]=shuffle_layers(layers,layers_temp,1,0);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);
curr_disp.setField('sv');

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);

end