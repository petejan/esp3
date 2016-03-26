function [start_time,end_time]=start_end_time_from_file(filename)
fid=fopen(filename);

if fid==-1
    start_time=0;
    end_time=1;
    return;
end

file_comp=fread(fid,'*char', 'l')';

idx_raw0=strfind(file_comp,'RAW0');
idx_raw3=strfind(file_comp,'RAW3');

idx_dg=union(idx_raw0,idx_raw3);

 fseek(fid,idx_dg(1)-1,-1);
 
 [~,start_time]=readEK60Header(fid);

 fseek(fid,idx_dg(end)-1,-1);
 
 [~,end_time]=readEK60Header(fid);


fclose(fid);

end
