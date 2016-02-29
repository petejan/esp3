function  open_dfile_crest(hObject,Filename_cell,CVSCheck)

curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');

layers_temp=read_crest(Filename_cell,'PathToMemmap',app_path.data,'CVSCheck',CVSCheck,'CVSroot',app_path.cvs_root);

layer=layers_temp(end);
layers=[layers_temp,layers];

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);

end