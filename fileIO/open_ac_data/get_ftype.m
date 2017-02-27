function ftype=get_ftype(filename)
ftype='';
if exist(filename,'file')>0
    
    [~,fname,end_file]=fileparts(filename);
    
    if strcmp(end_file,'.lst')
        ftype='fcv30';
       return; 
    end
    
    fid = fopen(filename, 'r');
    if fid==-1
        warning('Cannot open file');
        return;
    end
    fread(fid,1, 'int32', 'l');
    [dgType, ~] =read_dgHeader(fid,0);
    fclose(fid);
    switch dgType
        case 'XML0'
            ftype='EK80';
        case 'CON0'
            ftype='EK60';
        otherwise
            fid = fopen(filename, 'r','b');
            dgType=fread(fid,1,'uint16');
            fclose(fid);
            if hex2dec('FD02')==dgType
                ftype='asl';
            else
                if fname(1)=='d'&&isempty(end_file)
                     ftype='dfile';
                else
                    ftype='unknown';
                end
            end
            
    end
end


end