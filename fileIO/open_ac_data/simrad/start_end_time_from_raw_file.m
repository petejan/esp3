function [start_time,end_time]=start_end_time_from_raw_file(filename)
fid=fopen(filename,'r','l');
BLCK_SIZE=1e4;

if fid==-1
    start_time=0;
    end_time=1;
    return;
end


n=0;
idx_start=[];
while ~feof(fid)
    pos=ftell(fid);
    str_read=fread(fid,BLCK_SIZE,'*char')';
    idx_dg=union(strfind(str_read,'RAW0'),strfind(str_read,'RAW3'));
    if ~isempty(idx_dg)
        idx_start=pos+idx_dg(1)-1;
        break;
    end
    n=n+1;
    fseek(fid,-3,'cof');
end

fseek(fid,0,'eof');

pos=ftell(fid);
idx_end=[];
while pos>=BLCK_SIZE
    pos=ftell(fid);
    fseek(fid,-BLCK_SIZE,'cof');
    str_read=fread(fid,BLCK_SIZE,'*char')';

    idx_dg=union(strfind(str_read,'RAW0'),strfind(str_read,'RAW3'));
    
    if ~isempty(idx_dg)
        idx_end=pos-BLCK_SIZE+idx_dg(end)-1;
        break;
    end
    fseek(fid,-BLCK_SIZE+3,'cof');
    
    
end

%
% frewind(fid);


start_time=0;
end_time=1;

if~isempty(idx_start)
    fseek(fid,idx_start,-1);
    [~,start_time]=readEK60Header(fid);
end

if~isempty(idx_end)
    fseek(fid,idx_end,-1);
    [~,end_time]=readEK60Header(fid);
end

fclose(fid);

end
