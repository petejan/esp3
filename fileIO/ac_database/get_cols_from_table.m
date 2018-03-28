function [output_cols,output_vals]=get_cols_from_table(ac_db_filename,table_name,varargin)

p = inputParser;
addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'table_name',@ischar);
addParameter(p,'input_cols',{},@iscell);
addParameter(p,'input_vals',{},@iscell);
addParameter(p,'output_cols',{},@iscell);

parse(p,ac_db_filename,table_name,varargin{:});


output_cols=p.Results.output_cols;
output_vals=[];

if numel(p.Results.input_cols)~=numel(p.Results.input_vals)
     disp('get_cols_from_table:Invalid number of column specified in inputs fo sql query');
    return; 
end

inputs_cell=cell(1,numel(p.Results.input_cols));

for i_in=1:numel(p.Results.input_cols)
    if ischar(p.Results.input_vals{i_in})||iscell(p.Results.input_vals{i_in})
        if ~isempty(p.Results.input_vals{i_in})
            inputs_cell{i_in}=sprintf('%s IN ("%s")',p.Results.input_cols{i_in},strjoin(p.Results.input_vals{i_in},'","'));
        end
    elseif isnumeric(p.Results.input_vals{i_in})
        inputs_cell{i_in}=sprintf('%s IN (%s)',p.Results.input_cols{i_in},strjoin(cellfun(@num2str,num2cell(p.Results.input_vals{i_in}),'un',0),','));
    end
end

inputs_cell(cellfun(@isempty,inputs_cell))=[];

if ~isempty(p.Results.output_cols)
    out_str=strjoin(p.Results.output_cols,',');
else
    out_str='*';
end

try
    dbconn=sqlite(ac_db_filename,'connect');
    if ~isempty(inputs_cell)
        sql_query=sprintf('SELECT %s FROM %s WHERE %s',out_str,p.Results.table_name,strjoin(inputs_cell,' AND '));
    else
        sql_query=sprintf('SELECT %s FROM %s',out_str,table_name);
    end
    output_vals=dbconn.fetch(sql_query);
    dbconn.close();
catch err
    disp(err.message);
    warning('get_transect_att_from_att:Error while executing sql query');
end