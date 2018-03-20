

function t_file_id=get_file_id_from_ac_db(ac_db_filename,files,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'files',@(x) ischar(x)||iscell(x));

parse(p,ac_db_filename,files,varargin{:});


if ~iscell(files)
    files={files};
end

nb_files=length(files);

t_file_id=nan(1,nb_files);
dbconn=sqlite(ac_db_filename,'connect');  

 [~,f_tmp,e_tmp]=cellfun(@fileparts,files,'un',0);
for ifi=1:nb_files        
    t_file_id_tmp=dbconn.fetch(sprintf('select t_file_id from t_file where file_name is "%s"',[f_tmp{ifi} e_tmp{ifi}]));
    if ~isempty(t_file_id_tmp)
        t_file_id(ifi)=t_file_id_tmp{1};
    end
end
dbconn.close();