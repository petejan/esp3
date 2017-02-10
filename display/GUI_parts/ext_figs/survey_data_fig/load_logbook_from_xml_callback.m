function load_logbook_from_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    path_init = uigetdir(app_path.data,'Choose Data Folder');
    if path_init==0
        return;
    end
else
    [path_lay,~]=get_path_files(layer);
    path_init=path_lay{1};
end

[xml_file,path_f]= uigetfile(fullfile(path_init,'*.csv;*.txt'), 'Choose csv file','MultiSelect','off');

if path_f==0
    return;
end


xml_logbook_to_db(fullfile(path_f,xml_file));
import_survey_data_callback([],[],main_figure);
load_survey_data_fig_from_db(main_figure,0);

end