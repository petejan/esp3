function write_config_to_xml(app_path,curr_disp,algos)

p = inputParser;
addRequired(p,'app_path',@(obj) isempty(obj)||isa(obj,'struct'));
addRequired(p,'curr_disp',@(obj) isempty(obj)||isa(obj,'curr_state_disp_cl'));

parse(p,app_path,curr_disp);

app_path_main=whereisEcho();
file_xml=fullfile(app_path_main,'config','config_echo.xml');

docNode = com.mathworks.xml.XMLUtils.createDocument('config_file');

config_file=docNode.getDocumentElement;
config_file.setAttribute('version','0.1');

if isempty(app_path)
    return;
end

path_node = docNode.createElement('AppPath');
fields=fieldnames(app_path);
for ifi=1:length(fields)
    path_node.setAttribute(fields{ifi},app_path.(fields{ifi}));
end
config_file.appendChild(path_node);

if isempty(curr_disp)
    return;
end

disp_node = docNode.createElement('Display');
fields=properties(curr_disp);
for ifi=1:length(fields)
    if ~ismember(fields{ifi},{'Type','Fieldname','CursorMode','NbLayers','Cax','CurrLayerID','Fieldnames','Caxes','R_disp','UIupdate','Reg_changed_flag','Bot_changed_flag','Active_line_ID','Active_reg_ID'})
        val=curr_disp.(fields{ifi});
        if ~isnan(num2str(val,'%.0f'))
            disp_node.setAttribute(fields{ifi},num2str(val,'%.0f'));
        else
            disp_node.setAttribute(fields{ifi},val);
        end
    end
end
config_file.appendChild(disp_node);

algo_node = docNode.createElement('algos');
for ial=1:length(algos)
    algocurr_node = docNode.createElement(algos(ial).Name);
    f_algo=fieldnames(algos(ial).Varargin);
    %algocurr_node.setAttribute(char('Function'),char(algos(ial).Function));
    for ivar=1:length(f_algo)
        if ~ismember(f_algo{ivar},{'idx_r','idx_ping','reg_obj'})
            algocurr_node.setAttribute(f_algo{ivar},num2str(algos(ial).Varargin.(f_algo{ivar}),'%f'));
        end
    end
    algo_node.appendChild(algocurr_node);
end

config_file.appendChild(algo_node);


xmlwrite(file_xml,docNode);
type(file_xml);


end
