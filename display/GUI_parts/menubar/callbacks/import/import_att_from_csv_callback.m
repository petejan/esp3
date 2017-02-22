function import_att_from_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');


if isempty(layer)
    return;
end

[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.csv;3DM*.log')}, 'Pick a csv/log','MultiSelect','on');

if ~iscell(Filename)
    if Filename==0
        return;
    end
end

attitude_full=attitude_nav_cl.load_att_from_file(fullfile(PathToFile,Filename));

layer.add_attitude(attitude_full);

setappdata(main_figure,'Layer',layer);

display_attitude_cback([],[],main_figure);

end