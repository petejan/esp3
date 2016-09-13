function write_reg_to_reg_xml(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
parse(p,layer_obj);

[path_xml,reg_file_str,~]=layer_obj.create_files_str();

if exist(path_xml,'dir')==0
    mkdir(path_xml);
end

nb_reg=layer_obj.get_nb_regions();



for ifile=1:length(reg_file_str)
    xml_file=fullfile(path_xml,reg_file_str{ifile});

    if nansum(nb_reg)==0
        if exist(xml_file,'file')==2
            delete(xml_file);
        end
        continue;
    end
    
    docNode = com.mathworks.xml.XMLUtils.createDocument('region_file');
    region_file=docNode.getDocumentElement;
    region_file.setAttribute('version','0.1');
    
    for i=1:length(layer_obj.Transceivers)
        docNode=layer_obj.Transceivers(i).create_trans_reg_xml_node(docNode,ifile);
    end
    
    if exist(xml_file,'file')==2
        reg_xml_old=parse_region_xml(xml_file);
        for ib=1:length(reg_xml_old)
            [~,found]=find_freq_idx(layer_obj,reg_xml_old{ib}.Infos.Freq);
            if found==0
                docNode=create_reg_xml_node(docNode,reg_xml_old{ib});
            end
        end
    end
    
    xmlwrite(xml_file,docNode);
    %type(xml_file);
end


end

