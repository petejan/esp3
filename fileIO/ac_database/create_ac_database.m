function create_ac_database(ac_db_filename,replace)

file_sql=fullfile(whereisEcho,'config','db','ac_db.sql');

if isfile(ac_db_filename)
    if replace==1
        delete(ac_db_filename);
    else
        return;
    end
end

fid=fopen(file_sql,'r','n');
str_sql_ori=fread(fid,'*char')';
fclose(fid);
str_sql=strrep(str_sql_ori,'SERIAL PRIMARY KEY','INTEGER PRIMARY KEY AUTOINCREMENT');
str_sql=strrep(str_sql,'COMMENT','--COMMENT');
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

if replace==0
    dbconn=sqlite(ac_db_filename,'connect');  
else
    dbconn=sqlite(ac_db_filename,'create');  
end

for i=1:numel(idx_command)-1
    sql_cmd=str_sql(idx_command(i)+2:idx_command(i+1)+1);
    fprintf('%s\n\n',sql_cmd);
    dbconn.exec(sql_cmd);
end

idx_trigger_start=strfind(str_sql,'CREATE TRIGGER');
idx_trigger_end=strfind(str_sql,'END;');
idx_trigger_end=idx_trigger_end+numel('END;')-1;

for i=1:numel(idx_trigger_start)
    sql_cmd=str_sql(idx_trigger_start(i):idx_trigger_end(i));
    fprintf('%s\n\n',sql_cmd);
    dbconn.exec(sql_cmd);
end



dbconn.close();



end