function docNode=create_trans_reg_xml_node(trans_obj,docNode)

p = inputParser;
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));

parse(p,trans_obj,docNode);


range=trans_obj.Data.Range;
time=trans_obj.Data.Time;
region_file=docNode.getDocumentElement;

regions_node = docNode.createElement('regions');
regions_node.setAttribute('Freq',num2str(trans_obj.Config.Frequency,'%.0f'));
regions_node.setAttribute('ChannelID',deblank(trans_obj.Config.ChannelID));
region_file.appendChild(regions_node);

for ir=1:length(trans_obj.Regions)
   region_node = docNode.createElement('region');
   region_node.setAttribute('Name',trans_obj.Regions(ir).Name);
   region_node.setAttribute('Tag',trans_obj.Regions(ir).Tag);
   region_node.setAttribute('Type',trans_obj.Regions(ir).Type);
   region_node.setAttribute('Shape',trans_obj.Regions(ir).Shape);
   region_node.setAttribute('Reference',trans_obj.Regions(ir).Reference);
   region_node.setAttribute('Cell_w_unit',trans_obj.Regions(ir).Cell_w_unit);
   region_node.setAttribute('Cell_h_unit',trans_obj.Regions(ir).Cell_h_unit);
   region_node.setAttribute('ID',num2str(trans_obj.Regions(ir).ID,'%.0f'));
   region_node.setAttribute('Cell_w',num2str(trans_obj.Regions(ir).Cell_w,'%.0f'));
   region_node.setAttribute('Cell_h',num2str(trans_obj.Regions(ir).Cell_h,'%.0f'));
   if trans_obj.Regions(ir).Remove_ST==1
        region_node.setAttribute('Remove_ST',num2str(trans_obj.Regions(ir).Remove_ST,'%.0f'));
   end
   
   
   bbox_t_s=datestr(time(trans_obj.Regions(ir).Idx_pings(1)),'yyyymmddHHMMSSFFF');
   bbox_t_e=datestr(time(trans_obj.Regions(ir).Idx_pings(end)),'yyyymmddHHMMSSFFF');
   bbox_str=sprintf('%s %.3f ',bbox_t_s,range(trans_obj.Regions(ir).Idx_r(1)),bbox_t_e,range(trans_obj.Regions(ir).Idx_r(end)));
   
   bbox_node = docNode.createElement('bbox');
   bbox_node.appendChild(docNode.createTextNode(bbox_str));
   region_node.appendChild(bbox_node);
   
   switch trans_obj.Regions(ir).Shape
       case 'Polygon'
        contours_node = docNode.createElement('contours');
        for icont=1:length(trans_obj.Regions(ir).X_cont)
            contour_node = docNode.createElement('contour');
            time_cont=datestr(time(trans_obj.Regions(ir).Idx_pings(1)+trans_obj.Regions(ir).X_cont{icont}-1),'yyyymmddHHMMSSFFF');
            range_cont=range(trans_obj.Regions(ir).Idx_r(1)+trans_obj.Regions(ir).Y_cont{icont}-1);
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

