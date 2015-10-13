function  open_dfile_crest(hObject,PathToFile,Filename_cell,CVSCheck,load_reg,multi_layer)

curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');

layers_temp=read_crest(PathToFile,Filename_cell,'PathToMemmap',app_path.data,'CVSCheck',CVSCheck,'CVSroot',app_path.cvs_root);


disp('Shuffling layers');
[layers,layer]=shuffle_layers(layers,layers_temp,'load_reg',load_reg,'multi_layer',multi_layer);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);
curr_disp.setField('sv');

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);

end