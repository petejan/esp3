

function gps_data_cl_cell=get_gps_data_cl_from_t_navigation(ac_db_filename,files,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'files',@(x) ischar(x)||iscell(x));

parse(p,ac_db_filename,files,varargin{:});

if ~iscell(files)
    files={files};
end

gps_data_cl_cell=cell(1,numel(files));

dbconn=connect_to_db(ac_db_filename);  

[~,f_tmp,e_tmp]=cellfun(@fileparts,files,'un',0);
filenames=cellfun(@strcat,f_tmp,e_tmp,'un',0);

sql_query=sprintf('SELECT file_pkey,file_name FROM t_file WHERE file_name IN ("%s")',strjoin(filenames,'","'));
output=dbconn.fetch(sql_query);
if ~isempty(output)
    file_pkeys=(output(:,1));
    file_pkeys_vec=cell2mat(output(:,1));
    filenames_out=output(:,2);    
else
    dbconn.close();
    return;
end

if ~isempty(file_pkeys)
    sql_query=sprintf('SELECT navigation_latitude,navigation_longitude,navigation_time,navigation_file_key FROM t_navigation WHERE navigation_file_key IN (%s)',strjoin(cellfun(@num2str,file_pkeys,'un',0),','));
    gps_data_f=dbconn.fetch(sql_query);
    if ~isempty(gps_data_f)
        lat=cell2mat(gps_data_f(:,1));
        lon=cell2mat(gps_data_f(:,2));
        time=datenum(cell2mat(gps_data_f(:,3)),'yyyy-mm-dd HH:MM:SS');
        keys=cell2mat(gps_data_f(:,4));
        idx_rem=isnan(lat);
        lat(idx_rem)=[];
        lon(idx_rem)=[];
        time(idx_rem)=[];
        keys(idx_rem)=[];
        u_keys=unique(keys);
        for i=1:numel(u_keys)
            file=filenames_out{file_pkeys_vec==u_keys(i)};
            idx=u_keys(i)==keys;
            ifi=strcmpi(file,filenames);
            gps_data_cl_cell{ifi}=gps_data_cl('Lat',lat(idx),...,...
                'Long',lon(idx),...
                'Time',time(idx));
        end
        
    end
end

dbconn.close();