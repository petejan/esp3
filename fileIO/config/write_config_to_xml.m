function write_config_to_xml(app_path)

p = inputParser;
addRequired(p,'app_path',@(obj) isa(obj,'struct'));

parse(p,app_path);

app_path_main=whereisEcho();
file_xml=fullfile(app_path_main,'config_echo.xml');

docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');

config_file=docNode.getDocumentElement;
config_file.setAttribute('version','0.1');

path_node = docNode.createElement('AppPath');
path_node.setAttribute('cvs_root',app_path.cvs_root);
path_node.setAttribute('data_root',app_path.data_root);
path_node.setAttribute('data_temp',app_path.data_temp);

config_file.appendChild(path_node);

xmlwrite(file_xml,docNode);
type(file_xml);


end
