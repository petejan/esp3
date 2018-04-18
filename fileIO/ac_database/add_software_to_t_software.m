% CREATE TABLE t_software
% (
% 	software_pkey		SERIAL PRIMARY KEY,
% 	
% 	software_manufacturer	TEXT,
% 	software_name		TEXT,
% 	software_version	TEXT,
% 	software_host		TEXT,
% 	software_install_date	TIMESTAMP,
% 
% 	software_comments	TEXT
% );

function software_pkey=add_software_to_t_software(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'software_manufacturer','',@ischar);
addParameter(p,'software_name','',@ischar);
addParameter(p,'software_version','',@ischar);
addParameter(p,'software_host','',@ischar);
addParameter(p,'software_install_date',0,@isnumeric);
addParameter(p,'software_comments','',@ischar);

parse(p,ac_db_filename,varargin{:});

struct_in=p.Results;
struct_in=rmfield(struct_in,'ac_db_filename');
fields=fieldnames(struct_in);

for ifi=1:numel(fields)
    if ischar(p.Results.(fields{ifi}))
        struct_in.(fields{ifi})={p.Results.(fields{ifi})};
    else
        struct_in.(fields{ifi})=p.Results.(fields{ifi});
    end
end

% t=struct2table(struct_in);
% 
% dbconn=connect_to_db(ac_db_filename);  
% dbconn.insert('t_software',fieldnames(struct_in),t);
% 
% dbconn.close();
struct_in.software_install_date=datestr(struct_in.software_install_date,'yyyy-mm-dd');
struct_in_minus_key=rmfield(struct_in,{'software_comments'});

software_pkey=insert_data_controlled(ac_db_filename,'t_software',struct_in,struct_in_minus_key,'software_pkey');

end