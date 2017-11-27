function write_config_display_to_xml(curr_disp)

[file_xml,~,~]=get_config_files();

p = inputParser;
addRequired(p,'curr_disp',@(obj) isempty(obj)||isa(obj,'curr_state_disp_cl'));
addParameter(p,'file_xml',file_xml,@(x) ischar(x));

parse(p,curr_disp);

file_xml=p.Results.file_xml;

docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');

config_file=docNode.getDocumentElement;
config_file.setAttribute('version','0.2');

if isempty(curr_disp)
    return;
end

disp_node = docNode.createElement('Display');
fields=properties(curr_disp);
for ifi=1:length(fields)
    if ~ismember(fields{ifi},{'ChannelID' 'SecFreqs' 'Type','Fieldname','CursorMode','NbLayers','Cax','CurrLayerID','Fieldnames','Caxes','R_disp','UIupdate','Reg_changed_flag','Bot_changed_flag','Active_line_ID','Active_reg_ID'})
        val=curr_disp.(fields{ifi});
        if isnumeric(val)
             disp_node.setAttribute(fields{ifi},strjoin(arrayfun(@(x) num2str(x),val,'UniformOutput',false),';'));
        elseif iscell(val)
            continue;           
        else
            disp_node.setAttribute(fields{ifi},val);
        end
    end
end
config_file.appendChild(disp_node);


xmlwrite(file_xml,docNode);
type(file_xml);


end
