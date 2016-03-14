function write_config_to_xml(app_path,curr_disp)

p = inputParser;
addRequired(p,'app_path',@(obj) isempty(obj)||isa(obj,'struct'));
addRequired(p,'curr_disp',@(obj) isempty(obj)||isa(obj,'curr_state_disp_cl'));

parse(p,app_path,curr_disp);

app_path_main=whereisEcho();
file_xml=fullfile(app_path_main,'config_echo.xml');

docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');

config_file=docNode.getDocumentElement;
config_file.setAttribute('version','0.1');

if isempty(app_path)
    [app_path,~]=load_config_from_xml(file_xml);
end

path_node = docNode.createElement('AppPath');
fields=fieldnames(app_path);
for ifi=1:length(fields)
    path_node.setAttribute(fields{ifi},app_path.(fields{ifi}));
end
config_file.appendChild(path_node);

if isempty(curr_disp)
    [~,curr_disp]=load_config_from_xml(file_xml);
end

disp_node = docNode.createElement('Display');
fields=properties(curr_disp);
for ifi=1:length(fields)
    if nansum(strcmp(fields{ifi},{'Type','Fieldname','CursorMode','NbLayers','Cax','CurrLayerID'}))==0
        val=curr_disp.(fields{ifi});
        if ~isnan(num2str(val,'%.0f'))
            disp_node.setAttribute(fields{ifi},num2str(val,'%.0f'));
        else
            disp_node.setAttribute(fields{ifi},val);
        end
    end
end


config_file.appendChild(disp_node);

xmlwrite(file_xml,docNode);
type(file_xml);


end
