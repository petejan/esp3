function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    for i=1:length(layers)
        switch layers(i).Filetype
            case {'EK80','EK60','ASL'}
                layers(i).add_survey_data_db();
        end
    end
else
    return;
end
setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
display_survdata_lines(main_figure)
end
