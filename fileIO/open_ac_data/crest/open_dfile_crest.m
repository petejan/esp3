function  open_dfile_crest(hObject,Filename_cell,CVSCheck)

curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');

layers_temp=read_crest(Filename_cell,'PathToMemmap',app_path.data_temp,'CVSCheck',CVSCheck,'CVSroot',app_path.cvs_root);

new_layers=[layers_temp,layers];

new_layers_sorted=new_layers.sort_per_survey_data();
id_lay=new_layers(end).ID_num;
disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',-1)];
end

layers=layers_out;

layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);

setappdata(hObject,'Curr_disp',curr_disp);

end