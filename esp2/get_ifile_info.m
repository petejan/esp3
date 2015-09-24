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

ifileInfo.snapshot=[];
ifileInfo.stratum='';
ifileInfo.transect=[];

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if strfind(tline(1:nanmin(10,length(tline))),'snapshot')
        ifileInfo.snapshot =  tline(11:end);
        if ~isnan(str2double(ifileInfo.snapshot))
            ifileInfo.snapshot = str2double(ifileInfo.snapshot);
        end
    end
    if strfind(tline(1:nanmin(10,length(tline))),'stratum')
        ifileInfo.stratum = tline(10:end);
        if ~isnan(str2double(ifileInfo.stratum))
            ifileInfo.stratum = str2double(ifileInfo.stratum);
        end
    end
    if strfind(tline(1:nanmin(10,length(tline))),'transect:')
        ifileInfo.transect = tline(11:end);
        if ~isnan(str2double(ifileInfo.transect))
            ifileInfo.transect = str2double(ifileInfo.transect);
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

        expr='(-r).*(\w+).*(raw)';
        subline=regexp(tline,expr,'match');
        subline=subline{1};
        idx_str=strfind(subline,' ');        
        idx_str_2=union(strfind(subline,'\'),strfind(subline,'/'));   
        
        if ~isempty(idx_str)
            ifileInfo.rawFileName = subline(idx_str_2(end)+1:end);
        end
        if ~isempty(idx_str_2)
            ifileInfo.rawSubDir = subline(idx_str(end)+1:idx_str_2(end));
        end
        
        idx_go=strfind(tline,'-g ');
        subline_go=tline(idx_go:end);
        idx_go=strfind(subline_go,' ');
        if length(idx_go)>=2
            ifileInfo.G0=str2double(subline_go(idx_go(1):idx_go(2)));
        elseif length(idx_go)==1
            ifileInfo.G0=str2double(subline_go(idx_go(1):end));
        else
            ifileInfo.G0=[];
        end
        
        
        idx_sacorr=strfind(tline,'-s ');
        subline_sacorr=tline(idx_sacorr:end);
        idx_sacorr=strfind(subline_sacorr,' ');
        if length(idx_sacorr)>=2
            ifileInfo.SACORRECT=str2double(subline_sacorr(idx_sacorr(1):idx_sacorr(2)));
        elseif length(idx_sacorr)==1
            ifileInfo.SACORRECT=str2double(subline_sacorr(idx_sacorr(1):end));
        else
            ifileInfo.SACORRECT=[];
        end
        
        idx_cal_crest=strfind(tline,'-c ');
        subline_cal_crest=tline(idx_cal_crest:end);
        idx_cal_crest=strfind(subline_cal_crest,' ');
        if length(idx_cal_crest)>=2
            ifileInfo.Cal_crest=str2double(subline_cal_crest(idx_cal_crest(1):idx_cal_crest(2)));
        elseif length(idx_cal_crest)==1
            ifileInfo.Cal_crest=str2double(subline_cal_crest(idx_cal_crest(1):end));
        else
            ifileInfo.Cal_crest=[];
        end

        
   end
    
    if strfind(tline,'towbody')
        ifileInfo.towbody =  str2num(tline(11:end));
    end
    
end

if ~isfield(ifileInfo, 'rawFileName');
    ifileInfo.rawFileName = '';
    ifileInfo.rawSubDir = '';
end
fclose(fid);