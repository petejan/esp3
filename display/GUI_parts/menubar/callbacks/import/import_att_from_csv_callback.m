function import_att_from_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');


if isempty(layer)
return;
end

[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.csv;3DM*.log')}, 'Pick a csv/log','MultiSelect','off');
if Filename==0
    return;
end

attitude_full=csv_to_attitude(PathToFile,Filename);

layer.add_attitude(attitude_full);

setappdata(main_figure,'Layer',layer);

end