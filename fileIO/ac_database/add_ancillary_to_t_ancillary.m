% CREATE TABLE t_ancillary
% (
% 	ancillary_pkey		SERIAL PRIMARY KEY,
% 	
% 	ancillary_type		TEXT,	--
% 	ancillary_manufacturer	TEXT,	-- 
% 	ancillary_model		TEXT,	-- 
% 	ancillary_serial 	TEXT,	-- 
% 	ancillary_firmware 	TEXT,	-- 
% 		
% 	ancillary_comments	TEXT	-- 
% );
% COMMENT ON TABLE t_ancillary is 'Any other instruments - GPS, pitch roll sensor, anemometer, etc.';
% 


function ancillary_pkey=add_ancillary_to_t_ancillary(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'ancillary_type','',@ischar);
addParameter(p,'ancillary_manufacturer','',@ischar);
addParameter(p,'ancillary_model','',@ischar);
addParameter(p,'ancillary_serial','',@ischar);
addParameter(p,'ancillary_firmware','',@ischar);
addParameter(p,'ancillary_comments','',@ischar);

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

t=struct2table(struct_in);

dbconn=sqlite(ac_db_filename,'connect');  
dbconn.insert('t_ancillary',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'ancillary_comments');
[~,ancillary_pkey]=get_cols_from_table(ac_db_filename,'t_ancillary','input_struct',struct_in,'output_cols',{'ancillary_pkey'});

end