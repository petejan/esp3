function docNode=create_reg_xml_node(docNode,reg_xml)

p = inputParser;
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));
addRequired(p,'reg_xml',@(x) isstruct(x));

parse(p,docNode,reg_xml);

region_file=docNode.getDocumentElement;

regions_node = docNode.createElement('regions');
regions_node.setAttribute('Freq',num2str(reg_xml.Infos.Freq,'%.0f'));
regions_node.setAttribute('ChannelID',deblank(reg_xml.Infos.ChannelID));
region_file.appendChild(regions_node);

for ir=1:length(reg_xml.Regions)
    
        reg_curr=reg_xml.Regions{ir};
        
        region_node = docNode.createElement('region');
        region_node.setAttribute('Name',reg_curr.Name);
        region_node.setAttribute('Tag',reg_curr.Tag);
        region_node.setAttribute('Type',reg_curr.Type);
        region_node.setAttribute('Shape',reg_curr.Shape);
        region_node.setAttribute('Reference',reg_curr.Reference);
        region_node.setAttribute('Cell_w_unit',reg_curr.Cell_w_unit);
        region_node.setAttribute('Cell_h_unit',reg_curr.Cell_h_unit);
        region_node.setAttribute('ID',num2str(reg_curr.ID,'%.0f'));
        region_node.setAttribute('Unique_ID',num2str(reg_curr.Unique_ID,'%.0f'));
        region_node.setAttribute('Cell_w',num2str(reg_curr.Cell_w,'%.0f'));
        region_node.setAttribute('Cell_h',num2str(reg_curr.Cell_h,'%.0f'));
        if isfield(reg_curr,'Remove_ST')
            region_node.setAttribute('Remove_ST',num2str(reg_curr.Remove_ST,'%.0f'));
        end
        
        
        bbox_t_s=datestr(reg_curr.bbox_t(1),'yyyymmddHHMMSSFFF');
        bbox_t_e=datestr(reg_curr.bbox_t(2),'yyyymmddHHMMSSFFF');
        bbox_str=sprintf('%s %.3f ',bbox_t_s,reg_curr.bbox_r(1),bbox_t_e,reg_curr.bbox_r(1));
        
        bbox_node = docNode.createElement('bbox');
        bbox_node.appendChild(docNode.createTextNode(bbox_str));
        region_node.appendChild(bbox_node);
        
        switch reg_curr.Shape
            case 'Polygon'
                contours_node = docNode.createElement('contours');
                for icont=1:length(reg_curr.Contours)
                    contour_node = docNode.createElement('contour');
                    time_cont=datestr(reg_curr.Contours{icont}.Time,'yyyymmddHHMMSSFFF');
                    range_cont=reg_curr.Contours{icont}.Range;
                    cont_str=[];
                    for istr=1:length(range_cont)
                        cont_str=[cont_str sprintf('%s %.4f ',time_cont(istr,:),range_cont(istr))];
                    end
                    contour_node.appendChild(docNode.createTextNode(cont_str));
                    contours_node.appendChild(contour_node);
                end
                region_node.appendChild(contours_node);
        end
        regions_node.appendChild(region_node);
end



end
