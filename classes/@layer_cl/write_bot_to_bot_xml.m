function write_bot_to_bot_xml(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

[path_xml,~,bot_file_str]=layer_obj.create_files_str();

if exist(path_xml,'dir')==0
    mkdir(path_xml);
end

for ifile=1:length(bot_file_str)
    docNode = com.mathworks.xml.XMLUtils.createDocument('bottom_file');
    
    region_file=docNode.getDocumentElement;
    region_file.setAttribute('version','0.1');
    
    for i=1:length(layer_obj.Transceivers)
        docNode=layer_obj.Transceivers(i).create_trans_bot_xml_node(docNode,ifile);
    end
    xml_file=fullfile(path_xml,bot_file_str{ifile});
    xmlwrite(xml_file,docNode);
    %type(xml_file);
end


end