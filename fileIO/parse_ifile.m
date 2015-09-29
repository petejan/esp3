
function ifileInfo=parse_ifile(path,ifile)

if  ischar(ifile)
    %if a d-,n- or t- file was specified instead of an i-file use the corresponding i-file
    tok = ifile(end-7);
    num = ifile((end-6):end);
    if (tok == 'd' || tok == 'n' || tok == 't') && ~isempty(str2double(num))
        ifile(end-7) = 'i';
    end
else
    ifile = sprintf('i%07d', ifile);
end


parameters_search={'version','compression','snapshot','stratum','transect',....
    'start_date','LAT','HDG','GMT','finish_date',....
    'depth_factor','system_calibration','angle_factor','angle_factor_alongship','angle_factor_athwartship','transmit_pulse_length',...
    'absorption_coefficient','sound_speed','TVG_type','TVG','transducer_id','sounder_type',...
    'convertEk60ToCrest',...
    'es60_zero_error_ping_num','es60error_method','es60error_offset','es60error_min_std','es60error_min_mean','es60error_min_GOF'};

ifileInfo=struct('version','','compression','','snapshot',nan,'stratum','','transect',nan,....
    'start_date',nan,'finish_date',nan,'Lat',[nan nan],'Lon',[nan nan],'HDG',[nan nan],'SOG',[nan nan],'GMT',[nan nan],....%2x1vector [start end]
    'depth_factor',nan,'system_calibration',nan,'angle_factor',nan,'angle_factor_alongship',nan,'angle_factor_athwartship',nan,'transmit_pulse_length',nan,...
    'absorption_coefficient',nan,'sound_speed',nan,'TVG_type',nan,'TVG','','transducer_id','','sounder_type','',...
    'channel',nan,'Cal_crest',nan,'rawFileName','','rawSubDir','','G0',nan,'SACORRECT',nan,...
    'es60_zero_error_ping_num',nan,'es60error_method',nan,'es60error_offset',nan,'es60error_min_std',nan,'es60error_min_mean',nan,'es60error_min_GOF',nan);

fid=fopen(fullfile(path,ifile),'r');

if fid == -1
    warning(['Unable to open file ' ifile]);
    return;
end

tline = fgetl(fid);
while 1
    if feof(fid)
        break;
    end
    for i=1:length(parameters_search)
        idx_str=strfind(tline,parameters_search{i});
        if ~isempty(idx_str)
            switch parameters_search{i}
                case 'start_date'
                    idx_dots=strfind(tline,':');
                    ifileInfo.start_date = datenum(strtrim(tline(idx_dots(1)+6:end)));
                case 'LAT'
                    if strfind(tline,'start');
                        [ifileInfo.Lat(1),ifileInfo.Lon(1)]=parse_lat_long(tline);
                    else
                        [ifileInfo.Lat(2),ifileInfo.Lon(2)]=parse_lat_long(tline);
                    end
                case 'HDG'
                    if strfind(tline,'start');
                        [ifileInfo.HDG(1),ifileInfo.SOG(1)]=parse_HDG_SOG(tline);
                    else
                        [ifileInfo.HDG(2),ifileInfo.SOG(2)]=parse_HDG_SOG(tline);
                    end
                case 'GMT'
                    idx_dots=strfind(tline,':');
                    if strfind(tline,'start');
                        nz = datevec(ifileInfo.start_date);
                        gmt = datevec(tline(idx_dots(2)+1:end));
                        tmp = [nz(1) nz(2) nz(3) gmt(4) gmt(5) gmt(6)];
                        offset = abs(nz(4)-tmp(4));
                        ifileInfo.GMT(1) = datenum(nz - [0 0 0 offset 0 0 ]);
                    else
                        nz = datevec(ifileInfo.finish_date);
                        gmt = datevec(tline(idx_dots(2)+1:end));
                        tmp = [nz(1) nz(2) nz(3) gmt(4) gmt(5) gmt(6)];
                        offset = abs(nz(4)-tmp(4));
                        ifileInfo.GMT(2) = datenum(nz - [0 0 0 offset 0 0 ]);
                    end
                case 'finish_date'
                    idx_dots=strfind(tline,':');
                    ifileInfo.finish_date = datenum(tline(idx_dots(1)+6:end));
                case 'convertEk60ToCrest'
                    
                    expr='(-r).*(\w+).*(raw)';
                    subline=regexp(tline,expr,'match');
                    if ~isempty(subline)
                        subline=subline{1};
                        idx_str=strfind(subline,' ');
                        idx_str_2=union(strfind(subline,'\'),strfind(subline,'/'));
                        
                        if ~isempty(idx_str)
                            ifileInfo.rawFileName = subline(idx_str_2(end)+1:end);
                        end
                        if ~isempty(idx_str_2)
                            ifileInfo.rawSubDir = subline(idx_str(end)+1:idx_str_2(end));
                        end
                    else
                        ifileInfo.rawSubDir=[];
                        ifileInfo.rawFileName=[];
                    end
                    
                    ifileInfo.G0=get_opt(tline,'-g');
                    ifileInfo.SACORRECT=get_opt(tline,'-s');
                    ifileInfo.Cal_crest=get_opt(tline,'-c');
                    ifileInfo.channel=get_opt(tline,'-o');
                    
                otherwise
                    idx_dots=strfind(tline,':');
                    if isempty(idx_dots)
                        idx_dots=strfind(tline,'=');
                    end
                    if isempty(idx_dots)
                        continue;
                    end
                    if ~isnan(str2double(tline(idx_dots(1)+1:end)))
                        ifileInfo.(parameters_search{i})=str2double(tline(idx_dots(1)+1:end));
                    else
                        ifileInfo.(parameters_search{i})=strtrim(tline(idx_dots(1)+1:end));
                    end
                    parameters_search(i)=[];
                    break;
            end
        end
    end
    tline = fgetl(fid);
    
end
fclose(fid);

end

function opt=get_opt(tline,opt_str)

idx_opt=strfind(tline,opt_str);
subline_opt=tline(idx_opt:end);
idx_opt=strfind(subline_opt,' ');
if length(idx_opt)>=2
    opt=str2double(subline_opt(idx_opt(1):idx_opt(2)));
elseif length(idx_opt)==1
    opt=str2double(subline_opt(idx_opt(1):end));
else
    opt=[];
end
end

function [lat,lon]=parse_lat_long(tline)
formatSpec='%s LAT: %f %f %s  LONG: %f %f %s ';
l_old=length(tline);
tline = strrep(tline, ' ', ',');
l_new=0;
while l_new<l_old
    l_old=length(tline);
    tline = strrep(tline, ',,', ',');
    l_new=length(tline);
end

out = textscan(tline,formatSpec,'delimiter',',');
switch out{4}{1}
    case 'S'
        lat=-(double(out{2}) + out{3} / 60);
    otherwise
        lat=(double(out{2}) + out{3} / 60);
end

switch out{7}{1}
    case 'E'
        lon=(double(out{5}) + out{6} / 60);
    otherwise
        lon=-(double(out{5}) + out{6} / 60);
end

end


function [hdg,sog]=parse_HDG_SOG(tline)
formatSpec='%s HDG: %f SOG: %f';
l_old=length(tline);
tline = strrep(tline, ' ', ',');
l_new=0;
while l_new<l_old
    l_old=length(tline);
    tline = strrep(tline, ',,', ',');
    l_new=length(tline);
end

out = textscan(tline,formatSpec,'delimiter',',');
hdg=out{2};
sog=out{3};
end




