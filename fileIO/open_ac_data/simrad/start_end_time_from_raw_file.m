function [start_time,end_time]=start_end_time_from_raw_file(filename)
fid=fopen(filename,'r','l');
BLCK_SIZE=1e3;

if fid==-1
    start_time=0;
    end_time=1;
    return;
end


str_read=char(zeros(1,BLCK_SIZE+4));
found_start=0;
n=0;
idx_start=[];
while found_start==0&&~feof(fid)
    str_read(1:4)=str_read(BLCK_SIZE+1:BLCK_SIZE+4);
    temp=fread(fid,BLCK_SIZE,'*char');
    str_read(5:length(temp)+4)=temp;
    idx_dg=union(union(strfind(str_read,'RAW0'),strfind(str_read,'RAW3')),strfind(str_read,'NME0'));
    if ~isempty(idx_dg)
        found_start=1;
        idx_start=BLCK_SIZE*n+idx_dg(1)-5;
    end
    n=n+1;
end

fseek(fid,0,'eof');
str_read=char(zeros(1,BLCK_SIZE+4));
found_end=0;
n=0;
pos=ftell(fid);
idx_end=[];
while found_end==0&&pos>=BLCK_SIZE
    
    fseek(fid,-BLCK_SIZE,'cof');
    temp=fread(fid,BLCK_SIZE,'*char');
    str_read(5:length(temp)+4)=temp;
    idx_dg=union(union(strfind(str_read,'RAW0'),strfind(str_read,'RAW3')),strfind(str_read,'NME0'));
    
    if ~isempty(idx_dg)
        found_end=1;
        idx_end=pos-BLCK_SIZE+idx_dg(1)-5;
    end
    fseek(fid,-BLCK_SIZE,'cof');
    pos=ftell(fid);
    n=n+1;
end

%
% frewind(fid);
% file_comp=fread(fid,'*char', 'l')';
% idx_raw0=strfind(file_comp,'RAW0');
% idx_raw3=strfind(file_comp,'RAW3');
%
% idx_dg=union(idx_raw0,idx_raw3);
% idx_start_old=idx_dg(1)-1;
% idx_end_old=idx_dg(end)-1;

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
