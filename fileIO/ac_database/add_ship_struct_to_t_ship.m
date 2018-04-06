% CREATE TABLE t_ship
% (
% 	ship_pkey		SERIAL PRIMARY KEY,
% 	
% 	ship_type_key		INT,	-- Describe type of ship that is hosting the acoustic instrumentation. See the lookup table t_ship_type (ICES ship_type and mission_platform)
% 	ship_name 		TEXT, 	-- Name of the ship (ICES ship_name)
% 	ship_code		TEXT,	-- For example, in-house code associated with ship (ICES ship_code). At NIWA, the three letters code (e.g. TAN for Tangaroa)
% 	ship_platform_code	TEXT, 	-- ICES database of known ships (ICES ship_platform_code)
% 	ship_platform_class	TEXT,	-- ICES controlled vocabulary for platform class (ICES ship_platform_class)
% 	ship_callsign		TEXT,	-- Ship call sign (ICES ship_callsign)
% 	ship_alt_callsign	TEXT,	-- Alternative call sign if the ship has more than one (ICES ship_alt_callsign)
% 	ship_IMO		TEXT,	-- Ship's International Maritime Organization ship identification number (ICES ship_IMO)
% 	ship_operator		TEXT,	-- Name of organization of company which operates the ship (ICES ship_opeartor)
% 	ship_length		FLOAT,	-- Overall length of the ship (m) (ICES ship_length)
% 	ship_breadth		FLOAT,	-- The width of the ship at its widest point (m) (ICES ship_breadth)
%   ship_draft          FLOAT,  -- The draft of the ship
% 	ship_tonnage		FLOAT,	-- Gross tonnage of the ship (t) (ICES ship_tonnage)
% 	ship_engine_power	FLOAT,	-- The total power available for ship propulsion (ICES ship_engine_power)
% 	ship_noise_design	TEXT,	-- For example, ICES 209 compliant (Mitson, 1995). Otherwise description of noise performance of the ship (ICES ship_noise_design)
% 	ship_aknowledgement	TEXT,	-- Any users (include re-packagers) of these data are required to clearly acknowledge the source of the material in this format (ICES ship_aknowledgement)
% 	
% 	ship_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES ship_comments)
% 	
% 	
% 	UNIQUE(ship_IMO,ship_type_key,ship_name) ON CONFLICT IGNORE
% 	FOREIGN KEY (ship_type_key) REFERENCES t_ship_type(ship_type_pkey)
% );
% COMMENT ON TABLE t_ship is 'Ships or vessels from which acoustic data were collected.';
function ship_pkey=add_ship_struct_to_t_ship(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'ship_struct',init_ship_struct(1),@isstruct);

parse(p,ac_db_filename,varargin{:});

struct_in=p.Results.ship_struct;

fields=fieldnames(struct_in);

for ifi=1:numel(fields)
    if ischar(struct_in.(fields{ifi}))
        struct_in.(fields{ifi})={struct_in.(fields{ifi})};
    end
end

t=struct2table(struct_in);

dbconn=sqlite(ac_db_filename,'connect');  
%dbconn = database(ac_db_filename,'username','pwd','org.sqlite.JDBC','URL');
dbconn.insert('t_ship',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'ship_comments');

[~,ship_pkey]=get_cols_from_table(ac_db_filename,'t_ship','input_struct',struct_in,'output_cols',{'ship_pkey'});

end