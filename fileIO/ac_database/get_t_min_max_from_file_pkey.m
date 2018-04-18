function [t_min,t_max]=get_t_min_max_from_file_pkey(ac_db_filename,file_pkeys)

t_min=[];
t_max=[];

str_cell=cellfun(@num2str,num2cell(file_pkeys),'un',0);

sql_query=sprintf(['SELECT MIN(file_start_time),MAX(file_end_time))'....
'from t_file where file_pkey IN (%s)'],...
     strjoin(str_cell(:),','));
try
    dbconn=connect_to_db(ac_db_filename);
    output_vals=dbconn.fetch(sql_query);
    dbconn.close();
catch err
    disp(err.message);
    warning('get_t_min_max_from_file_pkey:Error while executing sql query');
end

if ~isempty(output_vals)
    t_min=output_vals{1};
    t_max=output_vals{2}; 
end