function [Frequencies,Variables,Nodes,Title]=parse_classification_xml(xml_file)

xml_struct=parseXML(xml_file);
Title='';
Frequencies=[];
Variables={};
Nodes={};
if ~strcmpi(xml_struct.Name,'classification_descr')
    warning('XML file not describing a Classification');
    return;
end

Title=get_att(xml_struct,'title');
if isempty(Title)
    Title='';
end

nb_child=length(xml_struct.Children);

for i=1:nb_child
    switch xml_struct.Children(i).Name
        case 'variables'
           Variables=get_variables(xml_struct.Children(i));
        case 'nodes'
           Nodes=get_nodes(xml_struct.Children(i));
        case 'frequencies'
          Frequencies=str2double(strsplit(xml_struct.Children(i).Data,';'));
        otherwise
            warning('Unidentified Child in XML');
    end
end

end

function var_cell=get_variables(var_node)
nb_var=length(var_node.Children);
var_cell=cell(1,nb_var);
for i=1:nb_var
    var_cell{i}=get_att(var_node.Children(i),'name');
end
end

function node_cell=get_nodes(nodes_node)
nb_node=length(nodes_node.Children);
node_cell=cell(1,nb_node);
for i=1:nb_node
    switch nodes_node.Children(i).Name
        case '#comment'
        case 'node'
            node_cell{i}=get_node_att(nodes_node.Children(i));
            cond_child=get_childs(nodes_node.Children(i),'condition');
            if ~isempty(cond_child)
                node_cell{i}.Condition=cond_child.Data;
            end
            
            class_child=get_childs(nodes_node.Children(i),'class');
            if ~isempty(class_child)
                node_cell{i}.Class=class_child.Data;
            end
    end
end
node_cell(cellfun(@isempty,node_cell))=[];

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

function att_val=get_att(node,name)
    att_val=[];
    for iu=1:length(node.Attributes)
        if strcmpi(node.Attributes(iu).Name,name)
        att_val=node.Attributes(iu).Value;
        end
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
