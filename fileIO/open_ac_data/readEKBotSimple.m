function [bottom, frequencies] = readEKBotSimple(filename)


%  open file for reading
fid = fopen(filename, 'r');
if (fid==-1)
    [~, name, ext] = fileparts(filename);
    bottom = -1; frequencies=-1;
    warning('Could not open out file: %s%s',name,ext);
    return;
end

%  read configuration datagram (file header)
[~, frequencies] = readEKRaw_ReadHeader(fid);
bottom=[];

nPings=1;
%  read entire file, processing individual datagrams
while (true)
    %  check if we're at the end of the file
    fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end
    
    %  read datagram header
    [dgType, dgTime]=readEK60Header_v2(fid);
    
    %  process datagrams by type
    switch dgType
        
        case 'BOT0'
            
            
            %  Read BOT datagram
            transceivercount = fread(fid, 1, 'int32', 'l');
            depth = fread(fid, transceivercount, 'float64', 'l');
            
            
            %  store data assuming there are transceivercount depths per datagram.
            bottom.number(nPings) = nPings;
            bottom.time(nPings) = datenum(1601, 1, 1, 0, 0, dgTime);
            bottom.depth(:,nPings) = depth;
            nPings = nPings + 1;
            
            
            
        otherwise
            %  Skip unknown datagram - print warning message
            warning('readEKRaw:IOError', strcat('Unknown datagram ''', ...
                dgheader.datagramtype,''' in file'));
            
    end
    
    %  datagram length is repeated...
    fread(fid, 1, 'int32', 'l');
end

%  close file.
fclose(fid);
