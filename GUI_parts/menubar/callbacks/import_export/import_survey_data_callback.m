function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    if ~isempty(layers(1).Filename)
        [path_csv,~,~]=fileparts(layers(1).Filename{1});
    else
        path_csv=pwd;
    end
    
else
    return;
end

survey_struct=import_survey_data(fullfile(path_csv,'echo_logbook.csv'));

for i=1:length(layers)
    layers(i).add_survey_data(survey_struct);
end

setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
update_display(main_figure,0);

end
