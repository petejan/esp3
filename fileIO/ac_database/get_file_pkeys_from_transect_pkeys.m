function f_pkeys=get_file_pkeys_from_transect_pkeys(ac_db_filename,t_pkeys,varargin)

p = inputParser;
addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'t_pkeys',@(x) isnumeric(x));
parse(p,ac_db_filename,t_pkeys,varargin{:});

if isempty(f_fpkeys)
    f_pkeys=[];
    return;
end

dbconn=sqlite(ac_db_filename,'connect');
sql_query=sprintf('SELECT file_key FROM t_file_transect WHERE transect_key IN (%s)',strjoin(cellfun(@num2str,num2cell(t_pkeys),'un',0),','));
f_pkeys=dbconn.fetch(sql_query);
dbconn.close();