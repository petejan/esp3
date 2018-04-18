function [lat_start,lon_start,t_start,lat_end,lon_end,t_end]=get_first_last_pos_from_t_navigation(ac_db_filename,navigation_file_key)

lat_start=[];
lon_start=[];
t_start=[];
lat_end=[];
lon_end=[];
t_end=[];

query_first=sprintf('SELECT navigation_latitude,navigation_longitude,navigation_time FROM t_navigation WHERE navigation_file_key=%d ORDER BY navigation_time ASC LIMIT 1',navigation_file_key);
query_last=sprintf('SELECT navigation_latitude,navigation_longitude,navigation_time FROM t_navigation  WHERE navigation_file_key=%d ORDER BY navigation_time DESC LIMIT 1',navigation_file_key);

dbconn=connect_to_db(ac_db_filename);  
data_first=dbconn.fetch(query_first);
data_last=dbconn.fetch(query_last);
dbconn.close();

if ~isempty(data_first)
    lat_start=data_first{1};
    lon_start=data_first{2};
    t_start=data_first{3};
end

if ~isempty(data_last)
    lat_end=data_last{1};
    lon_end=data_last{2};
    t_end=data_last{3};
end
