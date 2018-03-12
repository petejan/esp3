function create_ac_database(ac_db_filename,replace)

file_sql=fullfile(whereisEcho,'config','db','ac_db.sql');

if isfile(ac_db_filename)
    if replace==1
    delete(ac_db_filename);
    else
        return;
    end
end

fid=fopen(file_sql,'r');
str_sql=fread(fid,'*char')';
fclose(fid);
strrep(str_sql,'SERIAL PRIMARY KEY','INTEGER PRIMARY KEY AUTOINCREMENT');
idx_com_start=strfind(str_sql,'/*');
idx_com_end=strfind(str_sql,'*/');
idx_rem=[];
for i=1:numel(idx_com_start)
     fprintf('%s\n\n',str_sql(idx_com_start(i):idx_com_end(i)+1));
   idx_rem=union(idx_rem,(idx_com_start(i):idx_com_end(i)+1));
end
str_sql(idx_rem)=[];

idx_command=strfind(str_sql,');');
idx_command=[-1 idx_command];

dbconn=sqlite(ac_db_filename,'create');    
for i=1:numel(idx_command)-1
    sql_cmd=str_sql(idx_command(i)+2:idx_command(i+1)+1);
    fprintf('%s\n\n',sql_cmd);
    dbconn.exec(sql_cmd);
end

dbconn.close();

end