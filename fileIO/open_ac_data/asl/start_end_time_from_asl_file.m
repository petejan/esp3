function [start_time,end_time]=read_asl_start_end_time(filename)
fid=fopen(filename,'r','b');
BLCK_SIZE=1e3;

if fid==-1
    start_time=0;
    end_time=1;
    return;
end

found_start=0;
n=0;
while found_start==0&&~feof(fid)
    int_read=fread(fid,BLCK_SIZE,'uint16');
    idx_dg=find(int_read==hex2dec('FD02'));
    if ~isempty(idx_dg)
        found_start=1;
        idx_start=2*(BLCK_SIZE*n+idx_dg(1)-1);
    end
    n=n+1;
end

fseek(fid,0,'eof');
found_end=0;
n=0;
pos=ftell(fid); 
while found_end==0&&pos>=BLCK_SIZE
    fseek(fid,-BLCK_SIZE*2,'cof');
    int_read=fread(fid,BLCK_SIZE,'uint16');
    idx_dg=find(int_read==hex2dec('FD02'));
    
    if ~isempty(idx_dg)
        found_end=1;
        idx_end=pos-(BLCK_SIZE-idx_dg(1)+1)*2;
    end
    fseek(fid,-BLCK_SIZE*2,'cof');
    pos=ftell(fid);
    n=n+1;
end

%
start_time=0;
end_time=1;

if~isempty(idx_start)

    fseek(fid,idx_start,'bof'); 
    fread(fid,6,'uint16');
    time=fread(fid,7,'uint16');
    
    
    start_time=datenum(time(1:6)')+time(end)/100/60/60/24;
end

if~isempty(idx_end)
    
    fseek(fid,idx_end,'bof'); 
    fread(fid,6,'uint16');
    time=fread(fid,7,'uint16');
    
    end_time=datenum(time(1:6)')+time(end)/100/60/60/24;
end

fclose(fid);

end

