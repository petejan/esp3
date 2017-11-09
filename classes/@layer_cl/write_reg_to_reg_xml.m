function write_reg_to_reg_xml(layer_obj)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
parse(p,layer_obj);

[path_xml,reg_file_str,~]=layer_obj.create_files_str();

nb_reg=layer_obj.get_nb_regions();

for ifile=1:length(reg_file_str)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    xml_file=fullfile(path_xml{ifile},reg_file_str{ifile});
    ver='0.2';
    
    if nansum(nb_reg)==0
        if exist(xml_file,'file')==2
            delete(xml_file);
        end
        continue;
    end
        
    docNode = com.mathworks.xml.XMLUtils.createDocument('region_file');
    region_file=docNode.getDocumentElement;
    region_file.setAttribute('version',ver);
    
    if exist(xml_file,'file')==2
        [reg_xml_old,ver_old]=parse_region_xml(xml_file);
        for ib=1:length(reg_xml_old)
            [~,found]=find_cid_idx(layer_obj,reg_xml_old{ib}.Infos.ChannelID);
            if found==0
                if ~strcmpi(ver_old,ver)
                    ver=ver_old;
                    region_file.setAttribute('version',ver);
                end
                docNode=create_reg_xml_node(docNode,reg_xml_old{ib},ver);
            end
        end
    end
    
    

    for i=1:length(layer_obj.Transceivers)
        docNode=layer_obj.Transceivers(i).create_trans_reg_xml_node(docNode,ifile,ver);
    end
    
    
    
    xmlwrite(xml_file,docNode);
    %type(xml_file);
end


end

