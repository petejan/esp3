function import_gps_from_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end

[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.csv;*.txt;*.mat')}, 'Pick a csv/txt/mat','MultiSelect','on');


if isempty(Filename)
    return;
end

if ~iscell(Filename)
    if (Filename==0)
        return;
    end
    Filename={Filename};
end


prompt={'Offset in hours'};
defaultanswer={'0'};

answer=inputdlg(prompt,'Do you want to apply a time offset?',1,defaultanswer);

if isempty(answer)
    answer=defaultanswer;
end
if ~isnan(str2double(answer{1}))
    dt=str2double(answer{1});
else
    dt=0;
    warning('Invalid time offset');
end


for i=1:length(Filename)
    gps_data_temp=gps_data_cl.load_gps_from_file(fullfile(PathToFile,Filename{i}));
    gps_data_temp=gps_data_temp.clean_gps_track();
    gps_data_temp.Time=gps_data_temp.Time+dt/24; 
    if i>1
        gps_data=concatenate_GPSData(gps_data,gps_data_temp);
    else
        gps_data=gps_data_temp;
    end
end
layer.replace_gps_data_layer(gps_data);

setappdata(main_figure,'Layer',layer);
update_axis_panel(main_figure,0)

end