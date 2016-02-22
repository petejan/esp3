function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    if ~isempty(layers(1).PathToFile)
        path_csv=layers(1).PathToFile;
    else
        path_csv=pwd;
    end
    
else
    return;
end

survey_struct=import_survey_data(path_csv,'echo_logbook.csv');

for i=1:length(layers)
    layers(i).add_survey_data(survey_struct);
end

setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
update_display(main_figure,0);

end
