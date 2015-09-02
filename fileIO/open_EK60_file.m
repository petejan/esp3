
function  open_EK60_file(hObject,PathToFile,Filename,vec_freq,ping_start,ping_end,multi_layer,join)
curr_disp=getappdata(hObject,'Curr_disp');
layers=getappdata(hObject,'Layers');

app_path=getappdata(hObject,'App_path');

if exist(fullfile(PathToFile,'cal_echo.csv'),'file')>0
    cal=csv2struct(fullfile(PathToFile,'cal_echo.csv'));
else
    cal=[];
end

%     profile on;
layers_temp=open_EK60_file_stdalone(cal,app_path.data,PathToFile,Filename,vec_freq,ping_start,ping_end);
%     profile off;
%     profile viewer
if exist('opening_file','var')
    close(opening_file);
end

if isempty(layers_temp)
    return;
end

disp('Shuffling layers');
[layers,layer]=shuffle_layers(layers,layers_temp,multi_layer,join);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);

idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
curr_disp.Fieldname=layer.Transceivers(idx_freq).Data.SubData(idx_field).Fieldname;

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);
setappdata(hObject,'Curr_disp',curr_disp);




end