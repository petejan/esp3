

function file_pkeys=get_file_pkeys_from_ac_db(ac_db_filename,files,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'files',@(x) ischar(x)||iscell(x));

parse(p,ac_db_filename,files,varargin{:});

if ~iscell(files)
    files={files};
end

dbconn=sqlite(ac_db_filename,'connect');  

[~,f_tmp,e_tmp]=cellfun(@fileparts,files,'un',0);
filenames=cellfun(@strcat,f_tmp,e_tmp,'un',0);
sql_query=sprintf('SELECT file_pkey FROM t_file WHERE file_name IN ("%s")',strjoin(filenames,'","'));
file_pkeys=dbconn.fetch(sql_query);

dbconn.close();

end