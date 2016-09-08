function [header,config]=read_EK80_config(filename)
timeOffset=0;
HEADER_LEN=12;
fid = fopen(filename, 'r');
len=fread(fid, 1, 'int32', 'l');

[dgType, ~] =read_dgHeader(fid,timeOffset);

switch (dgType)
    case 'XML0'
        
        t_line=(fread(fid,len-HEADER_LEN,'*char','l'))';
        t_line=deblank(t_line);
        
        fread(fid, 1, 'int32', 'l');
        [header,config,~]=read_xml0(t_line);
            
    otherwise
        
        disp(dgType);
        disp('First Datagram is not XML0... EK60 file?');
        header=-1;
        config=-1;
        fclose(fid);
        return;
end

fclose(fid);

