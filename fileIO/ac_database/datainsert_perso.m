function datainsert_perso(ac_db_filename,tablename,data,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'tablename',@ischar);
addRequired(p,'data',@(x) isstruct(x)||istable(x));
addParameter(p,'idx_insert',[],@isnumeric);
addParameter(p,'unique_conflict_handling','',@ischar);

parse(p,ac_db_filename,tablename,data,varargin{:});

if istable(data)
    data=table2struct(data,'ToScalar',true);
end
col_names=fieldnames(data);

[dbconn,db_type]=connect_to_db(ac_db_filename);

col_num=numel(col_names);
row_num=nan(1,col_num);
data_type = cell(1,col_num);

for ifi=1:col_num
    row_num(ifi) = size(data.(col_names{ifi}),1);
    data_type{ifi} = class(data.(col_names{ifi}));
end
row_num=unique(row_num);

if numel(row_num)>1
    error('datainsert_perso:Could not insert data, not the same number of entries in every columns');
end

sql_query_start = sprintf('INSERT INTO %s (%s) VALUES ',tablename,strjoin(col_names,','));


if ~isempty(p.Results.idx_insert)
    id_row=p.Results.idx_insert;
else
    id_row = 1:row_num;
end
input_vals=cell(1,numel(id_row));
for i = id_row(:)'
    tmp=cell(1,col_num);
    for j = 1:col_num
        switch data_type{j}
            case 'cell'
                tmp{j} = data.(col_names{j}){i};
            case 'char'
                tmp{j} = data.(col_names{j})(i,:);
            otherwise
                tmp{j} = data.(col_names{j})(i);
        end
        if isnumeric(tmp{j})
            tmp{j}=num2str(tmp{j});
        else
            tmp{j}=strrep(tmp{j},'''',''''''); 
            tmp{j}=['''' tmp{j} ''''];
        end
         
    end   
    input_vals{i}=strjoin(tmp,',');
end

sql_query=sprintf('%s (%s) %s',sql_query_start,strjoin(input_vals,'),('),p.Results.unique_conflict_handling);
dbconn.exec(sql_query);
dbconn.close();