function gps_data=get_gps_data_from_db(filenames)

if isempty(filenames)
    gps_data={[]};
    return;
end

if~iscell(filenames)
    filenames ={filenames};
end


gps_data=cell(1,length(filenames));

for ip=1:length(filenames)
    
    if isfolder(filenames{ip})
        path_f=filenames{ip};
    else
        [path_f,file,ext]=fileparts(filenames{ip});
    end
    db_file=fullfile(path_f,'echo_logbook.db');
    
    if ~(exist(db_file,'file')==2)
        continue;
    end
    
    dbconn=sqlite(db_file,'connect');
    try
        if isfolder(filenames{ip})
            gps_data_f=dbconn.fetch('select Lat,Long,Time from gps_data');
        else
            gps_data_f=dbconn.fetch(sprintf('select Lat,Long,Time from gps_data where Filename like "%s%s"',file,ext));
        end
    catch
        gps_data_f=[];
    end
    if ~isempty(gps_data_f)
        gps_data_a=cellfun(@strsplit,gps_data_f,'un',0);
        lat=cell2mat(cellfun(@str2double,gps_data_a(:,1)','un',0));
        lon=cell2mat(cellfun(@str2double,gps_data_a(:,2)','un',0));
        time=cell2mat(cellfun(@(x) datenum(x,'yyyymmddHHMMSSFFF'),gps_data_a(:,3),'un',0))';
        idx_nan=isnan(lat);
        gps_data{ip}=gps_data_cl('Lat',lat(~idx_nan),...,...
            'Long',lon(~idx_nan),...
            'Time',time(~idx_nan));
    end
     close(dbconn);
end
end