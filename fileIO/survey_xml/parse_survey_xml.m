%% parse_survey_xml.m
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
% * |xml_file|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |survey_input|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-07-06: start commenting and header (Alex Schimel).
% * 2015-12-18: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function survey_input = parse_survey_xml(xml_file,varargin)

xml_struct = parseXML(xml_file);

if ~strcmpi(xml_struct.Name,'survey_processing')
    warning('XML file not describing a survey');
    survey_input = [];
    return;
end


nb_child = length(xml_struct.Children);
nb_reg = 0;
nb_snap = 0;
nb_cal = 0;
surv_def=survey_input_cl();

Infos=surv_def.Infos;
Options=surv_def.Options;
Algos = {};
Regions_WC = {};
Cal = [];
Snapshots=surv_def.Snapshots;

if nargin>1
    nodes=varargin{1};
    [~,idx_child]=find(ismember({xml_struct.Children(:).Name},nodes));
else
   idx_child=1:nb_child;
end
    
for i = idx_child
    switch xml_struct.Children(i).Name
        case 'survey'
            Infos = get_node_att(xml_struct.Children(i));
        case 'cal'
            nb_cal = nb_cal+1;
            cal_temp = get_cal_node(xml_struct.Children(i),Options.Frequency,nan);
            Cal = [Cal cal_temp];
        case 'options'
            Options = survey_options_cl('Options',get_options_node(xml_struct.Children(i)));
        case 'algos'
            Algos = get_algos(xml_struct.Children(i));
        case 'regions_WC'
            nb_reg = nb_reg+1;
            Regions_WC{nb_reg} = get_node_att(xml_struct.Children(i));
        case 'snapshot'
            nb_snap = nb_snap+1;
            Snapshots{nb_snap} = get_snapshot(xml_struct.Children(i),Options);
        case '#comment'
            continue;
        otherwise
            warning('Unidentified Child in XML');
    end
end

% generate the survey_input object from results
survey_input = survey_input_cl('Infos',Infos,'Options',Options,'Algos',Algos,'Regions_WC',Regions_WC,'Snapshots',Snapshots,'Cal',Cal);

end

%% SUBFUNCTIONS

function  Options = get_options_node(xml_node)
Options = get_node_att(xml_node);

if isfield(Options,'FrequenciesToLoad')
    if ischar(Options.FrequenciesToLoad)
        Options.FrequenciesToLoad = str2double(strsplit(Options.FrequenciesToLoad,';'));
        if isnan(Options.FrequenciesToLoad)
            Options.FrequenciesToLoad = Options.Frequency;
        end
    end
    abs_ori = Options.Absorption;
    Options.Absorption = nan(1,length(Options.FrequenciesToLoad));
    if ischar(abs_ori)
        abs_temp = str2double(strsplit(abs_ori,';'));
        if length(abs_temp) == length(Options.FrequenciesToLoad)
            Options.Absorption = abs_temp;
        end
    else
        Options.Absorption(Options.FrequenciesToLoad == Options.Frequency) = abs_ori;
    end
end

end

function node_atts = get_node_att(node)
if isempty(node)
    node_atts = [];
    return;
end
nb_att = length(node.Attributes);
node_atts = [];

for j = 1:nb_att
    node_atts.(node.Attributes(j).Name) = node.Attributes(j).Value;
    
    if ischar(node_atts.(node.Attributes(j).Name))
        if strcmpi(node_atts.(node.Attributes(j).Name),'nan')
            node_atts.(node.Attributes(j).Name) = nan;
        end
    end
    
end
end

function cal = get_cal_node(node,freq,eqa)
cal = get_node_att(node);

if ~isfield(cal,'FREQ')
    cal.FREQ = freq;
end

if ~isfield(cal,'EQA')
    cal.EQA = eqa;
end


end

function att_val = get_att(node,name)
att_val = [];
for iu = 1:length(node.Attributes)
    if strcmpi(node.Attributes(iu).Name,name)
        att_val = node.Attributes(iu).Value;
    end
end
end

function childs = get_childs(node,name)
childs = [];
for iu = 1:length(node.Children)
    if strcmpi(node.Children(iu).Name,name)
        childs = [childs node.Children(iu)];
    end
end
end

function transects = get_transects(node)
trans_nodes = get_childs(node,'transect');

transects = cell(1,length(trans_nodes));
for iu = 1:length(trans_nodes)
    trans_curr = get_node_att(trans_nodes(iu));
    bott_curr = get_childs(trans_nodes(iu),'bottom');
    reg_curr = get_childs(trans_nodes(iu),'region');
    trans_curr.Bottom = get_node_att(bott_curr);
    trans_curr.Regions = cell(1,length(reg_curr));
    
    for iiu = 1:length(reg_curr)
        trans_curr.Regions{iiu} = get_node_att(reg_curr(iiu));
    end
    
    if isfield(trans_curr,'files')
        trans_curr.files = strsplit(trans_curr.files,';');
    end
    
    cals = get_childs(trans_nodes(iu),'cal');
    Cal = [];
    for ii = 1:length(cals)
        cal_temp = get_cal_node(cals(ii),nan,nan);
        Cal = [Cal cal_temp];
    end
    trans_curr.Cal = Cal;
    transects{iu} = trans_curr;
end

end

function snapshot_struct = get_snapshot(node,options)
snapshot_struct.Number = get_att(node,'number');
snapshot_struct.Folder = get_att(node,'folder');
stratum = get_childs(node,'stratum');
snapshot_struct.Options = update_options(options,get_options_node(get_childs(node,'options')));
snapshot_struct.Stratum = cell(1,length(stratum));
cals = get_childs(node,'cal');
Cal = [];
for i = 1:length(cals)
    cal_temp = get_cal_node(cals(i),options.Frequency,nan);
    Cal = [Cal cal_temp];
end
snapshot_struct.Cal = Cal;

for i = 1:length(stratum)
    strat_curr = get_strat_node(stratum(i),snapshot_struct.Options);
    snapshot_struct.Stratum{i} = strat_curr;
end

end

function strat_curr = get_strat_node(stratum,options)
strat_curr.Name = get_att(stratum,'name');
strat_curr.Transects = get_transects(stratum);
strat_curr.Type = get_att(stratum,'type');
strat_curr.Radius = get_att(stratum,'radius');
if isnumeric(strat_curr.Name)
    strat_curr.Name = num2str(strat_curr.Name,'%.0f');
end

cals = get_childs(stratum,'cal');
Cal = [];
for ii = 1:length(cals)
    cal_temp = get_cal_node(cals,options.Frequency,nan);
    Cal = [Cal cal_temp];
end

strat_curr.Cal = Cal;
strat_curr.Options = update_options(options,get_options_node(get_childs(stratum,'options')));
end
