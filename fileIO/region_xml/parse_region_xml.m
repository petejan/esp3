function [region_xml,ver]=parse_region_xml(xml_file)

xml_struct=parseXML(xml_file);

if ~strcmpi(xml_struct.Name,'region_file')
    warning('XML file not describing a region');
    region_xml=[];
    return;
end
ver=num2str(xml_struct.Attributes(1).Value,'%.1f');
regions_node=get_childs(xml_struct,'regions');
nb_reg_groups=length(regions_node);
if isempty(regions_node)
    warning('No regions definitions in the file');
    region_xml=[];
    return;
end


for i=1:nb_reg_groups
    region_xml{i}.Infos=get_node_att(xml_struct.Children(i));
    switch ver
        case '0.1'
            region_xml{i}.Regions=get_regions_node(xml_struct.Children(i));
        case '0.2'
            region_xml{i}.Regions=get_regions_node_v2(xml_struct.Children(i));
    end
    if isnumeric(region_xml{i}.Infos.ChannelID)
        region_xml{i}.Infos.ChannelID=num2str(region_xml{i}.Infos.ChannelID);
    end
end


end

function regions=get_regions_node(node)
regions_node=get_childs(node,'region');

regions=cell(1,length(regions_node));

for iu=1:length(regions_node)
    region_curr=struct('ID',0,'Unique_ID',[],'Tag','','Shape','Rectangular','Name','','Type','Data','Ref','Surface',...
        'Cell_w',100,'Cell_h',5,'Cell_w_unit','pings','Cell_h_unit','meters','bbox_t',[],'bbox_r',[],'Contours',[]);
    region_att=get_node_att(regions_node(iu));
    field_att=fieldnames(region_att);
    for ifa=1:length(field_att)
        region_curr.(field_att{ifa})=region_att.(field_att{ifa});
    end
    
    bbox=get_childs(regions_node(iu),'bbox');
    
    bbox_cell=textscan(bbox.Data,'%s %f');
    region_curr.bbox_t=datenum(bbox_cell{1},'yyyymmddHHMMSSFFF');
    region_curr.bbox_r=bbox_cell{2};
    
    contours_node=get_childs(regions_node(iu),'contours');
    if ~isempty(contours_node)
        region_curr.Shape='Polygon';
        contour_nodes=get_childs(contours_node,'contour');
        region_curr.Contours=cell(1,length(contour_nodes));
        for ic=1:length(contour_nodes)
            tmp=textscan(contour_nodes(ic).Data,'%s %f');
            region_curr.Contours{ic}.Time=datenum(tmp{1},'yyyymmddHHMMSSFFF');
            region_curr.Contours{ic}.Range=tmp{2};
        end
    end
    
    regions{iu}=region_curr;
end


end


function regions=get_regions_node_v2(node)
regions_node=get_childs(node,'region');

regions=cell(1,length(regions_node));

for iu=1:length(regions_node)
    region_curr=struct('ID',0,'Unique_ID',[],'Tag','','Shape','Rectangular','Name','','Type','Data','Ref','Surface',...
        'Cell_w',100,'Cell_h',5,'Cell_w_unit','pings','Cell_h_unit','meters','bbox_p',[],'bbox_s',[],'Contours',[]);
    region_att=get_node_att(regions_node(iu));
    field_att=fieldnames(region_att);
    
    for ifa=1:length(field_att)
        region_curr.(field_att{ifa})=region_att.(field_att{ifa});
    end
    
    bbox=get_childs(regions_node(iu),'bbox');
    
    bbox_cell=textscan(bbox.Data,'%d %d');
    region_curr.bbox_p=double(bbox_cell{1});
    region_curr.bbox_s=double(bbox_cell{2});
    
    contours_node=get_childs(regions_node(iu),'contours');
    if ~isempty(contours_node)
        region_curr.Shape='Polygon';
        contour_nodes=get_childs(contours_node,'contour');
        region_curr.Contours=cell(1,length(contour_nodes));
        for ic=1:length(contour_nodes)
            tmp=textscan(contour_nodes(ic).Data,'%d %d');
            region_curr.Contours{ic}.Ping=double(tmp{1});
            region_curr.Contours{ic}.Sample=double(tmp{2});
        end
    end
    
    regions{iu}=region_curr;
end


end


