function write_line_to_line_xml(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);

docNode = com.mathworks.xml.XMLUtils.createDocument('line_file');
ver='0.1';

line_file=docNode.getDocumentElement;
line_file.setAttribute('version',ver);
docNode=layer_obj.create_lay_line_xml_node(docNode);

[path_xml,line_file_str]=layer_obj.create_files_line_str();

for ifile=1:length(line_file_str)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    
    
    xml_file=fullfile(path_xml{ifile},line_file_str{ifile});
    xmlwrite(xml_file,docNode);
    %type(xml_file);
end


end
