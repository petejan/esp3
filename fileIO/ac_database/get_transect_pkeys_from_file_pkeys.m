function t_pkeys=get_transect_pkeys_from_file_pkeys(ac_db_filename,f_pkeys,varargin)

p = inputParser;
addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'f_pkeys',@(x) isnumeric(x));
parse(p,ac_db_filename,f_pkeys,varargin{:});

if isempty(f_fpkeys)
    t_pkeys=[];
    return;
end

dbconn=connect_to_db(ac_db_filename);
sql_query=sprintf('SELECT transect_key FROM t_file_transect WHERE file_key IN (%s)',strjoin(cellfun(@num2str,num2cell(f_pkeys),'un',0),','));
t_pkeys=dbconn.fetch(sql_query);
dbconn.close();