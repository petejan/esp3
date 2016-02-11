function bottom_xml=parse_bottom_xml(xml_file)

xml_struct=parseXML(xml_file);

if ~strcmpi(xml_struct.Name,'bottom_file')
    warning('XML file not describing a region');
    bottom_xml=[];
    return;
end

bottoms_node=get_childs(xml_struct,'bottom_line');

nb_bot=length(bottoms_node);
if isempty(bottoms_node)
    warning('No bottom definitions in the file');
    bottom_xml=[];
    return;
end
    

for i=1:nb_bot
    bottom_xml{i}.Infos=get_node_att(xml_struct.Children(i));
    bottom_xml{i}.Bottom=get_bottom_node(xml_struct.Children(i));
end

end

function node_atts=get_node_att(node)
if isempty(node)
    node_atts=[];
    return;
end
nb_att=length(node.Attributes);
node_atts=[];
for j=1:nb_att
    node_atts.(node.Attributes(j).Name)=node.Attributes(j).Value;
end
end


function childs=get_childs(node,name)
    childs=[];
    for iu=1:length(node.Children)
        if strcmpi(node.Children(iu).Name,name)
        childs=[childs node.Children(iu)];
        end
    end
end

function bottom=get_bottom_node(bottom_node)



    bottom=struct('Range',[],'Tag',[],'Time',[]);

    
    time_node=get_childs(bottom_node,'time');
    
    range_node=get_childs(bottom_node,'range');
    
    tag_node=get_childs(bottom_node,'tag');

    range=textscan(range_node.Data,'%f');
    bottom.Range=range{1};
    
    time=textscan(time_node.Data,'%s');
    bottom.Time=datenum(time{1},'yyyymmddHHMMSSFFF');
    
    tag=textscan(tag_node.Data,'%d');
    bottom.Tag=double(tag{1});
   

end


