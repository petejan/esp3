function survey_input=parse_survey_xml(xml_file)

xml_struct=parseXML(xml_file);

if ~strcmpi(xml_struct.Name,'survey_processing')
    warning('XML file not describing a survey');
    survey_input=[];
    return;
end

Algos={};
Regions_WC={};
Cal=[];
nb_child=length(xml_struct.Children);
nb_reg=0;
nb_snap=0;
nb_cal=0;

for i=1:nb_child
    switch xml_struct.Children(i).Name
        case 'survey'
           Infos=get_node_att(xml_struct.Children(i));
        case 'cal'
           nb_cal=nb_cal+1;
           cal_temp=get_node_att(xml_struct.Children(i));
           if ~isfield(cal_temp,'FREQ')
               cal_temp.FREQ=Options.Frequency;
           end
           Cal=[Cal cal_temp];
        case 'options'
           Options=get_node_att(xml_struct.Children(i));
           if isfield(Options,'FrequenciesToLoad')
               if ischar(Options.FrequenciesToLoad)
                   Options.FrequenciesToLoad=str2double(strsplit(Options.FrequenciesToLoad,';'));
                   if isnan(Options.FrequenciesToLoad)
                       Options.FrequenciesToLoad=Options.Frequency;
                   end
               end
                abs_ori=Options.Absorption;
                Options.Absorption=nan(1,length(Options.FrequenciesToLoad));
                if ischar(abs_ori)
                    abs_temp=str2double(strsplit(abs_ori,';'));
                    if length(abs_temp)==length(Options.FrequenciesToLoad)
                        Options.Absorption=abs_temp;
                    end
                else
                   Options.Absorption(Options.FrequenciesToLoad==Options.Frequency)=abs_ori;
                end
           end

           
        case 'algos'
            Algos=get_algos(xml_struct.Children(i));
        case 'regions_WC'
            nb_reg=nb_reg+1;
            Regions_WC{nb_reg}=get_node_att(xml_struct.Children(i));
        case 'snapshot'
            nb_snap=nb_snap+1;
            Snapshots{nb_snap}=get_snapshot(xml_struct.Children(i));      
        otherwise
            warning('Unidentified Child in XML');
    end
end
survey_input=survey_input_cl('Infos',Infos,'Options',Options,'Algos',Algos,'Regions_WC',Regions_WC,'Snapshots',Snapshots,'Cal',Cal);

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

    if ischar(node_atts.(node.Attributes(j).Name))
        if strcmpi(node_atts.(node.Attributes(j).Name),'nan')
            node_atts.(node.Attributes(j).Name)=nan;
        end
    end
    
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

function transects=get_transects(node)
trans_nodes=get_childs(node,'transect');

transects=cell(1,length(trans_nodes));
for iu=1:length(trans_nodes)
    trans_curr=get_node_att(trans_nodes(iu));
    bott_curr=get_childs(trans_nodes(iu),'bottom');
    reg_curr=get_childs(trans_nodes(iu),'region'); 
    trans_curr.Bottom=get_node_att(bott_curr);
    trans_curr.Regions=cell(1,length(reg_curr));
    for iiu=1:length(reg_curr)
        trans_curr.Regions{iiu}=get_node_att(reg_curr(iiu));
    end
    if isfield(trans_curr,'files')
        trans_curr.files=strsplit(trans_curr.files,';');
    end
    cals=get_childs(trans_nodes(iu),'cal');
    Cal=[];
    for ii=1:length(cals)
        cal_temp=get_node_att(cals(ii));
        Cal=[Cal cal_temp];
    end
    trans_curr.Cal=Cal;
    transects{iu}=trans_curr;
end
    
end

function snapshot_struct=get_snapshot(node)
snapshot_struct.Number=get_att(node,'number');
snapshot_struct.Folder=get_att(node,'folder');
stratum=get_childs(node,'stratum');
snapshot_struct.Stratum=cell(1,length(stratum));
cals=get_childs(node,'cal');
Cal=[];
for i=1:length(cals)
    cal_temp=get_node_att(cals(i));
    Cal=[Cal cal_temp];
end
snapshot_struct.Cal=Cal;

for i=1:length(stratum)
    strat_curr.Name=get_att(stratum(i),'name');
    strat_curr.Transects=get_transects(stratum(i));
    if isnumeric(strat_curr.Name)
           strat_curr.Name=num2str(strat_curr.Name,'%.0f');
    end
    
    cals=get_childs(stratum(i),'cal');
    Cal=[];
    for ii=1:length(cals)
        cal_temp=get_node_att(cals(ii));
        Cal=[Cal cal_temp];
    end
    strat_curr.Cal=Cal;
    snapshot_struct.Stratum{i}=strat_curr;
end

end
