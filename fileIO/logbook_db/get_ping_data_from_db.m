function gps_data=get_ping_data_from_db(filenames)

if isempty(filenames)
    gps_data={[]};
    return;
end

if~iscell(filenames)
    filenames ={filenames};
end

idata=1;

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
        freq=dbconn.fetch(sprintf('select Frequency  from ping_data where Filename is "%s%s" limit 1',file,ext));
    catch
        freq=[];
    end
    if ~isempty(freq)
        freq=freq{1};
    else
        continue;
    end
    
    if isfolder(filenames{ip})
        gps_data_f=dbconn.fetch('select Lat,Long,Time from ping_data');
    else
        gps_data_f=dbconn.fetch(sprintf('select Lat,Long,Time from ping_data where Filename is "%s%s" and Frequency=%.0f',file,ext,freq));
    end
    
    if ~isempty(gps_data_f)       
        lat=cell2mat(gps_data_f(:,1));
        lon=cell2mat(gps_data_f(:,2));
        time=datenum(cell2mat(gps_data_f(:,3)),'yyyy-mm-dd HH:MM:SS');
        idx_nan=isnan(lat);
        gps_data{ip}=gps_data_cl('Lat',lat(~idx_nan),...,...
            'Long',lon(~idx_nan),...
            'Time',time(~idx_nan));
    end
    idata=idata+1;
    
end
end