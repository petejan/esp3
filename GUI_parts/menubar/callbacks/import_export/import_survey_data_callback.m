function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    if ~isempty(layers(1).PathToFile)
        path=layers(1).PathToFile;
    else
        path=pwd;
    end
    
else
    return;
end

[Filename,PathToFile]= uigetfile({fullfile(path,'*.csv')}, 'Pick a Csv file','MultiSelect','off');
if Filename==0
    return;
end

[files_csv,survey_vec]=import_survey_data(PathToFile,Filename);

for i=1:length(layers)
    layers(i).add_survey_data(files_csv,survey_vec);
end

setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
update_display(main_figure,0);

end
