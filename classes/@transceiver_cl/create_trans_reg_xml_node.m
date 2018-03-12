function docNode=create_trans_reg_xml_node(trans_obj,docNode,file_id,ver)

p = inputParser;
addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'docNode',@(docnode) isa(docNode,'org.apache.xerces.dom.DocumentImpl'));
addRequired(p,'file_id',@isnumeric);
addRequired(p,'ver',@ischar);
parse(p,trans_obj,docNode,file_id,ver);

idx_ping=find(file_id==trans_obj.Data.FileId);

range=trans_obj.get_transceiver_range();
time=trans_obj.Time;
region_file=docNode.getDocumentElement;
regions_node = docNode.createElement('regions');
regions_node.setAttribute('Freq',num2str(trans_obj.Config.Frequency,'%.0f'));
regions_node.setAttribute('ChannelID',deblank(trans_obj.Config.ChannelID));
region_file.appendChild(regions_node);



for ir=1:length(trans_obj.Regions)
    try
        if isempty(intersect(idx_ping,trans_obj.Regions(ir).Idx_pings))
            continue;
        end
        if numel(unique(trans_obj.Data.FileId))>1
            splitted_reg=trans_obj.Regions(ir).split_region(trans_obj.Data.FileId,1);
        else
            splitted_reg=trans_obj.Regions(ir);
        end
        for irs=1:length(splitted_reg)
            
            if isempty(intersect(idx_ping,splitted_reg(irs).Idx_pings))
                continue;
            end
            
            region_node = docNode.createElement('region');
            region_node.setAttribute('Name',splitted_reg(irs).Name);
            region_node.setAttribute('Tag',splitted_reg(irs).Tag);
            region_node.setAttribute('Type',splitted_reg(irs).Type);
            region_node.setAttribute('Shape',splitted_reg(irs).Shape);
            region_node.setAttribute('Reference',splitted_reg(irs).Reference);
            region_node.setAttribute('Cell_w_unit',splitted_reg(irs).Cell_w_unit);
            region_node.setAttribute('Cell_h_unit',splitted_reg(irs).Cell_h_unit);
            region_node.setAttribute('ID',num2str(splitted_reg(irs).ID,'%.0f'));
            region_node.setAttribute('Unique_ID',num2str(splitted_reg(irs).Unique_ID,'%.0f'));
            region_node.setAttribute('Cell_w',num2str(splitted_reg(irs).Cell_w,'%.2f'));
            region_node.setAttribute('Cell_h',num2str(splitted_reg(irs).Cell_h,'%.2f'));
            
            if splitted_reg(irs).Remove_ST==1
                region_node.setAttribute('Remove_ST',num2str(splitted_reg(irs).Remove_ST,'%.0f'));
            end
            
            [X_cont,Y_cont]=vertices2contours(splitted_reg(irs).Poly.Vertices);
            
            switch ver
                case '0.1'
                    
                    bbox_t_s=datestr(time(splitted_reg(irs).Idx_pings(1)),'yyyymmddHHMMSSFFF');
                    bbox_t_e=datestr(time(splitted_reg(irs).Idx_pings(end)),'yyyymmddHHMMSSFFF');
                    bbox_str=sprintf('%s %.3f ',bbox_t_s,range(splitted_reg(irs).Idx_r(1)),bbox_t_e,range(splitted_reg(irs).Idx_r(end)));
                    
                    bbox_node = docNode.createElement('bbox');
                    bbox_node.appendChild(docNode.createTextNode(bbox_str));
                    region_node.appendChild(bbox_node);
                    
                    switch splitted_reg(irs).Shape
                        case 'Polygon'
                            contours_node = docNode.createElement('contours');
                            non_empty=false;
                            
                            for icont=1:length(X_cont)
                                contour_node = docNode.createElement('contour');
                                
                                time_cont=datestr(time(X_cont{icont}),'yyyymmddHHMMSSFFF');
                                range_cont=range(Y_cont{icont}-1);
                                if numel(range_cont)<=2
                                    continue;
                                end
                                cont_str=[];
                                for istr=1:length(range_cont)
                                    cont_str=[cont_str sprintf('%s %.4f ',time_cont(istr,:),range_cont(istr))];
                                end
                                non_empty=true;
                                contour_node.appendChild(docNode.createTextNode(cont_str));
                                contours_node.appendChild(contour_node);
                            end
                            if non_empty
                                region_node.appendChild(contours_node);
                            end
                    end
                    
                case '0.2'
                    
                    bbox_p_s=splitted_reg(irs).Idx_pings(1)-idx_ping(1)+1;
                    bbox_p_e=splitted_reg(irs).Idx_pings(end)-idx_ping(1)+1;
                    bbox_str=sprintf('%d %d ',bbox_p_s,splitted_reg(irs).Idx_r(1),bbox_p_e,splitted_reg(irs).Idx_r(end));
                    
                    bbox_node = docNode.createElement('bbox');
                    bbox_node.appendChild(docNode.createTextNode(bbox_str));
                    region_node.appendChild(bbox_node);

                    switch splitted_reg(irs).Shape
                        case 'Polygon'
                            contours_node = docNode.createElement('contours');
                            for icont=1:length(X_cont)
                                contour_node = docNode.createElement('contour');
                                ping_cont=X_cont{icont}-splitted_reg(irs).Idx_pings(1)+1;

                                sample_cont=Y_cont{icont}-splitted_reg(irs).Idx_r(1)+1;
                                cont_str=[];
                                for istr=1:length(sample_cont)
                                    cont_str=[cont_str sprintf('%d %d ',ping_cont(istr),sample_cont(istr))];
                                end
                                contour_node.appendChild(docNode.createTextNode(cont_str));
                                contours_node.appendChild(contour_node);
                            end
                            region_node.appendChild(contours_node);
                    end
            end
            
            regions_node.appendChild(region_node);
        end
    catch
        sprintf('Could not save region %.0f from %.0f kHz',trans_obj.Regions(ir).ID,trans_obj.Config.Frequency/1e3);
    end
    
end



end



