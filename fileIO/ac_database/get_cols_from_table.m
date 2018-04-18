function [output_cols,output_vals]=get_cols_from_table(ac_db_filename,table_name,varargin)

p = inputParser;
addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'table_name',@ischar);
addParameter(p,'input_cols',{},@iscell);
addParameter(p,'input_vals',{},@iscell);
addParameter(p,'output_cols',{},@iscell);
addParameter(p,'input_struct',struct.empty(),@isstruct);
addParameter(p,'row_idx',[],@isnumeric);

parse(p,ac_db_filename,table_name,varargin{:});

output_cols=p.Results.output_cols;
output_vals=[];


if ~isempty(p.Results.input_vals)
    if numel(p.Results.input_cols)~=numel(p.Results.input_vals)
        disp('get_cols_from_table:Invalid number of column specified in inputs fo sql query');
        return;
    end
    input_vals=p.Results.input_vals;
    input_cols=p.Results.input_cols;
elseif ~isempty(p.Results.input_struct)
    input_cols=fieldnames(p.Results.input_struct);
    input_vals=cell(1,numel(input_cols));
    for iin=1:numel(input_cols)
        if ~isempty(p.Results.row_idx)
            if iscell(p.Results.input_struct.(input_cols{iin}))
                input_vals{iin}=p.Results.input_struct.(input_cols{iin})(p.Results.row_idx);
            else
                if ischar(p.Results.input_struct.(input_cols{iin})(p.Results.row_idx))
                    input_vals{iin}=p.Results.input_struct.(input_cols{iin}){p.Results.row_idx};
                else
                    input_vals{iin}=p.Results.input_struct.(input_cols{iin})(p.Results.row_idx);
                end
            end
        else
             if ischar(p.Results.input_struct.(input_cols{iin})(p.Results.row_idx))
                    input_vals{iin}={p.Results.input_struct.(input_cols{iin})};
                else
                    input_vals{iin}=p.Results.input_struct.(input_cols{iin});
                end
 
        end
    end
else
    return;
end

nb_vals=cellfun(@numel,input_vals);
nb_comb=max(nb_vals);

input_tot=cell(1,nb_comb);

for i_comb=1:nb_comb
    inputs_cell=cell(1,numel(input_cols));
    for i_in=1:numel(input_cols)
        if ~isempty(input_vals{i_in})
            if ischar(input_vals{i_in})
                input_vals{i_in}{i_comb}=strrep(input_vals{i_in}{i_comb},'''',''''''); 
                inputs_cell{i_in}=sprintf('%s = ''%s''',input_cols{i_in},input_vals{i_in});
            elseif iscell(input_vals{i_in})
                if isnumeric(input_vals{i_in}{i_comb})
                    inputs_cell{i_in}=sprintf('%s = %f',input_cols{i_in},input_vals{i_in}{i_comb});
                else
                    input_vals{i_in}{i_comb}=strrep(input_vals{i_in}{i_comb},'''',''''''); 
                    inputs_cell{i_in}=sprintf('%s = ''%s''',input_cols{i_in},input_vals{i_in}{i_comb});
                end
            elseif isnumeric(input_vals{i_in})
                inputs_cell{i_in}=sprintf('%s = %f',input_cols{i_in},input_vals{i_in}(i_comb));
            end
        end
    end
    
inputs_cell(cellfun(@isempty,inputs_cell))=[];
input_tot{i_comb}=strjoin(inputs_cell,' AND ');
end

input_tot(cellfun(@isempty,input_tot))=[];

if ~isempty(p.Results.output_cols)
    out_str=strjoin(p.Results.output_cols,',');
else
    out_str='*';
end


try
    dbconn=connect_to_db(ac_db_filename);
    if ~isempty(input_tot)
        sql_query=sprintf('SELECT %s FROM %s WHERE (%s)',out_str,p.Results.table_name,strjoin(input_tot,') OR ('));
    else
        sql_query=sprintf('SELECT %s FROM %s',out_str,table_name);
    end
    output_vals=dbconn.fetch(sql_query);
    dbconn.close();
catch err
    disp(err.message);
    warning('get_cols_from_table:Error while executing sql query');
end
% 
% inputs_cell=cell(1,numel(input_cols));
% 
% idx_keep=cellfun(@(x) ~isempty(x),input_vals);
% 
% if any(idx_keep)
%     input_statement_start=sprintf('(%s) IN',strjoin(input_cols,','));
%     
%     for i_in=1:numel(input_cols)
%         if ~isempty(input_vals{i_in})
%             if ischar(input_vals{i_in})
%                 inputs_cell{i_in}=sprintf('(%s)',input_vals{i_in});
%             elseif iscell(input_vals{i_in})
%                 inputs_cell{i_in}=sprintf('("%s")',strjoin(input_vals{i_in},'","'));
%             elseif isnumeric(input_vals{i_in})
%                 inputs_cell{i_in}=sprintf('(%s)',input_cols{i_in},strjoin(cellfun(@num2str,num2cell(input_vals{i_in}),'un',0),','));
%             end
%         end
%     end
% else
%     input_statement_start='';
% end
% 
% inputs_cell(cellfun(@isempty,inputs_cell))=[];
% 
% if ~isempty(p.Results.output_cols)
%     out_str=strjoin(p.Results.output_cols,',');
% else
%     out_str='*';
% end
% 
% try
%     dbconn=connect_to_db(ac_db_filename);
%     if ~isempty(inputs_cell)
%         sql_query=sprintf('SELECT %s FROM %s WHERE %s IN (%s)',out_str,p.Results.table_name,input_statement_start,strjoin(inputs_cell,','));
%     else
%         sql_query=sprintf('SELECT %s FROM %s',out_str,table_name);
%     end
%     output_vals=dbconn.fetch(sql_query);
%     dbconn.close();
% catch err
%     disp(err.message);
%     warning('get_cols_from_table:Error while executing sql query');
% end