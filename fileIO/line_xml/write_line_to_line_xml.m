function write_line_to_line_xml(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));

parse(p,layer_obj);



[path_xml,line_file_str]=layer_obj.create_files_line_str();
[start_time,end_time]=layer_obj.get_time_bound_files();
for ifile=1:length(line_file_str)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    
    docNode = com.mathworks.xml.XMLUtils.createDocument('line_file');
    ver='0.1';
    
    line_file=docNode.getDocumentElement;
    line_file.setAttribute('version',ver);
    docNode=layer_obj.create_lay_line_xml_node(docNode,start_time(ifile),end_time(ifile),line_file_str{ifile});
    
    xml_file=fullfile(path_xml{ifile},line_file_str{ifile});
    xmlwrite(xml_file,docNode);
    %type(xml_file);
end


end
