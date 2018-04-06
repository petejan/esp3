% CREATE TABLE t_mission
% (
% 	mission_pkey 			SERIAL PRIMARY KEY,
% 	
% 	mission_name 			TEXT, 		-- Name of mission (ICES mission_name)
% 	mission_abstract 		TEXT, 		-- Text description of the mission, its purpose, scientific objectives and area of operation (ICES mission_abstract)
% 	mission_start_date 		TIMESTAMP,	-- Start date and time of the mission (ICES mission_start_date)
% 	mission_end_date 		TIMESTAMP,	-- End date and time of the mission (ICES mission_end_date)
% 	principal_investigator 		TEXT,		-- Name of the principal investigator in charge of the mission (ICES principal_investigator)
% 	principal_investigator_email	TEXT,		-- Principal investigator e-mail address (ICES principal_investigator_email)
% 	institution 			TEXT,		-- Name of the institute, facility, or company where the original data were produced (ICES institution)
% 	data_centre 			TEXT,		-- Data centre in charge of the data management or party who distributed the resource (ICES data_centre)
% 	data_centre_email 		TEXT,		-- Data centre contact e-mail address (ICES data_centre_email)
% 	mission_id			TEXT, 		-- ID code of mission (ICES mission_id) 
% 	creator				TEXT,		-- Entity primarily responsible for making the resource (ICES creator)
% 	contributor			TEXT,		-- Entity responsible for making contributions to the resource (ICES contributor)
% 	
% 	mission_comments		TEXT		-- Free text fields for relevant information not captured by other attributes (ICES mission_comments)
% );
% COMMENT ON TABLE t_mission is 'Mission or projects for which acoustic data were collected.';


function mission_pkey=add_mission_struct_to_t_mission(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'mission_struct',init_mission_struct(),@isstruct);

parse(p,ac_db_filename,varargin{:});

struct_in=p.Results.mission_struct;

struct_in.mission_start_date=cellfun(@(x) datestr(x,'yyyy-mm-dd'),num2cell(struct_in.mission_start_date),'un',0);

struct_in.mission_end_date=cellfun(@(x) datestr(x,'yyyy-mm-dd'),num2cell(struct_in.mission_end_date),'un',0);


fields=fieldnames(struct_in);


for ifi=1:numel(fields)
    if ischar(struct_in.(fields{ifi}))
        struct_in.(fields{ifi})={struct_in.(fields{ifi})};
    else
        struct_in.(fields{ifi})=struct_in.(fields{ifi});
    end
end

t=struct2table(struct_in);

dbconn=sqlite(ac_db_filename,'connect');  
dbconn.insert('t_mission',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'mission_comments');
[~,mission_pkey]=get_cols_from_table(ac_db_filename,'t_mission','input_struct',struct_in,'output_cols',{'mission_pkey'});

end