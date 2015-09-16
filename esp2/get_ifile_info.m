function ifileInfo = get_ifile_info(filePath, fileNumber)
% Reads in data from an i-file and return all available info

%     \_________/       written by Johannes Oeffner
%         \ \           in April 2013
%        \   \
%       \ <>< \         Fisheries Acoustics
%      \<>< <><\        NIWA - National Institute of Water & Atmospheric Research

if (nargin < 2)
    error('insufficient number of arguments');
end

if ~isempty(strfind(computer,'WIN'))
    if filePath(end)~= '\'
        filePath = [filePath '\'];
    end
else
    if filePath(end)~= '/'
        filePath = [filePath '/'];
    end
        filePath = [getDataRootDir filePath];
end


if  ischar(fileNumber)
        %if a d-,n- or t- file was specified instead of an i-file use the corresponding i-file
        tok = fileNumber(end-7);
        num = fileNumber((end-6):end);
        if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
            fileNumber(end-7) = 'i';
        end
else
        
        fileNumber = sprintf('i%07d', fileNumber);
end
    
    
        
file = fullfile(filePath,fileNumber);


fid = fopen(file);
if fid == -1
    warning(['File not found or permission denied for ' file]);
    ifileInfo = [];
    return
end

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if strfind(tline,'snapshot')
        ifileInfo.snapshot =  str2num(tline(11:end));
    end
    if strfind(tline,'stratum')
        ifileInfo.stratum = tline(10:end);
        if ~isempty(str2num(ifileInfo.stratum))
            ifileInfo.stratum = str2num(ifileInfo.stratum);
        end
    end
    if strfind(tline,'transect:')
        ifileInfo.transect = tline(11:end);
        if ~isempty(str2num(ifileInfo.transect))
            ifileInfo.transect = str2num(ifileInfo.transect);
        end
    end
    if strfind(tline,'start_date')
        ifileInfo.start_date = datenum(tline(17:end));
    end
    
    if strfind(tline,'start: GMT')
        nz = datevec(ifileInfo.start_date);
        gmt = datevec(tline(13:end));
        tmp = [nz(1) nz(2) nz(3) gmt(4) gmt(5) gmt(6)];
        offset = abs(nz(4)-tmp(4));
        ifileInfo.start_date_gmt = datenum(nz - [0 0 0 offset 0 0 ]);
    end
    
    if strfind(tline,'start: LAT:')
        ifileInfo.start_lat = tline(13:25);
        ifileInfo.start_long = tline(35:end);
    end
    
    if strfind(tline,'finish: LAT:')
        ifileInfo.finish_lat = tline(14:26);
        ifileInfo.finish_long = tline(36:end);
    end
    
    if strfind(tline,'finish_date')
        ifileInfo.finish_date = datenum(tline(17:end));
    end
    
    if strfind(tline,'finish: GMT')
        nz = datevec(ifileInfo.finish_date);
        gmt = datevec(tline(14:end));
        tmp = [nz(1) nz(2) nz(3) gmt(4) gmt(5) gmt(6)];
        offset = abs(nz(4)-tmp(4));
        ifileInfo.finish_date_gmt = datenum(nz - [0 0 0 offset 0 0 ]);
    end
    
    
    if strfind(tline,'# convertEk60ToCrest')
        e = strfind(tline,'raw');
        ifileInfo.rawFileName = tline(e-26:e+2);
    end
    
    if strfind(tline,'towbody')
        ifileInfo.towbody =  str2num(tline(11:end));
    end
    
end

if ~isfield(ifileInfo, 'rawFileName');
    ifileInfo.rawFileName = 'rawfile not in Ifile';
end
fclose(fid);