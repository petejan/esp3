function [lat_min,lat_max,lon_min,lon_max]=get_lat_lon_min_max_from_file_pkey(ac_db_filename,file_pkeys)
lat_min=-90;
lat_max=90;
lon_min=-180;
lon_max=180;
output_vals=[];
str_cell=cellfun(@num2str,num2cell(file_pkeys),'un',0);

sql_query=sprintf(['SELECT MIN(navigation_latitude),MAX(navigation_latitude),MIN(navigation_longitude),MAX(navigation_longitude)'....
'from t_navigation where navigation_file_key IN (%s)'],...
     strjoin(str_cell(:),','));
try
    dbconn=connect_to_db(ac_db_filename);
    output_vals=dbconn.fetch(sql_query);
    dbconn.close();
catch err
    disp(err.message);
    warning('get_lat_lon_min_max_from_file_pkey:Error while executing sql query');
end

if ~isempty(output_vals)
    lat_min=output_vals{1,1};
    lat_max=output_vals{1,2};
    lon_min=output_vals{1,3};
    lon_max=output_vals{1,4};   
end