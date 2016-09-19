function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    for i=1:length(layers)
        switch layers(i).Filetype
            case {'EK80','EK60'}
                if ~isempty(layers(i).Filename)
                    [path_csv,~,~]=fileparts(layers(i).Filename{1});
                else
                    path_csv=pwd;
                end
                
                survey_struct=import_survey_data_xml(fullfile(path_csv,'echo_logbook.xml'));
                layers(i).add_survey_data(survey_struct);
        end
    end
else
    return;
end
setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
display_survdata_lines(main_figure)
end
