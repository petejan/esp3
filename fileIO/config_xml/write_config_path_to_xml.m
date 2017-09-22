function write_config_path_to_xml(app_path)

p = inputParser;
addRequired(p,'app_path',@(obj) isempty(obj)||isa(obj,'struct'));

parse(p,app_path);

[~,file_xml,~]=get_config_files();

docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');

config_file=docNode.getDocumentElement;
config_file.setAttribute('version','0.2');

if isempty(app_path)
    return;
end

app_path_deflt=app_path_create();
prop_deflt=fieldnames(app_path_deflt);

for iprop =1:numel(prop_deflt)
    if~isfield(app_path,prop_deflt{iprop})
        app_path.(prop_deflt{iprop})=app_path_deflt.(prop_deflt{iprop});
    end
end

path_node = docNode.createElement('AppPath');
fields=fieldnames(app_path);
for ifi=1:length(fields)
    path_node.setAttribute(fields{ifi},app_path.(fields{ifi}));
end
config_file.appendChild(path_node);

xmlwrite(file_xml,docNode);
type(file_xml);


end
