%% create_reg_xml_node.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |docNode|: TODO: write description and info on variable
% * |reg_xml|: TODO: write description and info on variable
% * |ver|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |docNode|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function docNode = create_reg_xml_node(docNode,reg_xml,ver)

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
        
        if isnumeric()
            Unique_ID=num2str(reg_curr.Unique_ID,'%.0f');
        else
            Unique_ID=reg_curr.Unique_ID;
        end
        
        region_node = docNode.createElement('region');
        region_node.setAttribute('Name',reg_curr.Name);
        region_node.setAttribute('Tag',reg_curr.Tag);
        region_node.setAttribute('Type',reg_curr.Type);
        region_node.setAttribute('Shape',reg_curr.Shape);
        region_node.setAttribute('Reference',reg_curr.Reference);
        region_node.setAttribute('Cell_w_unit',reg_curr.Cell_w_unit);
        region_node.setAttribute('Cell_h_unit',reg_curr.Cell_h_unit);
        region_node.setAttribute('ID',num2str(reg_curr.ID,'%.0f'));
        region_node.setAttribute('Unique_ID',Unique_ID);
        region_node.setAttribute('Cell_w',num2str(reg_curr.Cell_w,'%.2f'));
        region_node.setAttribute('Cell_h',num2str(reg_curr.Cell_h,'%.2f'));
        
        if isfield(reg_curr,'Remove_ST')
            region_node.setAttribute('Remove_ST',num2str(reg_curr.Remove_ST,'%.0f'));
        end
        
        switch ver
            case '0.1'
                bbox_t_s=datestr(reg_curr.bbox_t(1),'yyyymmddHHMMSSFFF');
                bbox_t_e=datestr(reg_curr.bbox_t(2),'yyyymmddHHMMSSFFF');
                bbox_str=sprintf('%s %.3f ',bbox_t_s,reg_curr.bbox_r(1),bbox_t_e,reg_curr.bbox_r(2));
                
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
            case '0.2'

                bbox_str=sprintf('%d %d ',bbox_p_s,reg_curr.bbox_s(1),bbox_p_e,reg_curr.bbox_s(2));
                
                bbox_node = docNode.createElement('bbox');
                bbox_node.appendChild(docNode.createTextNode(bbox_str));
                region_node.appendChild(bbox_node);
                
                switch reg_curr.Shape
                    case 'Polygon'
                        contours_node = docNode.createElement('contours');
                        for icont=1:length(reg_curr.Contours)
                            contour_node = docNode.createElement('contour');
                            ping_cont=reg_curr.Contours{icont}.Ping;
                            sample_cont=reg_curr.Contours{icont}.Sample;
                            cont_str=[];
                            for istr=1:length(range_cont)
                                cont_str=[cont_str sprintf('%d %.d ',ping_cont(istr,:),sample_cont(istr))];
                            end
                            contour_node.appendChild(docNode.createTextNode(cont_str));
                            contours_node.appendChild(contour_node);
                        end
                        region_node.appendChild(contours_node);
                end
        end
        
        regions_node.appendChild(region_node);
end



end

