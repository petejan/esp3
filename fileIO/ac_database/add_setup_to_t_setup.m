% CREATE TABLE t_setup
% (
% 	setup_pkey				SERIAL PRIMARY KEY,
% 
% 	-- Cruise or Deployment switch
% 	setup_cruise_or_deployment_key		INT, 		
% 
% 	-- If cruise...
% 	setup_cruise_key			INT, 		-- Refers to attribute cruise_pkey in t_cruise
% 	setup_platform_type_key			INT, 		-- Hull, Towbody or AOS
% 	
% 	-- If deployment...
% 	setup_deployment_key			INT, 		-- Refers to attribute deployment_pkey in t_deployment
% 
% 	-- Keys to instrument combo
% 	setup_transceiver_key			INT,		-- Link to transceiver pkey for this setup
% 	setup_transducer_key			INT,		-- Link to transducer pkey for this setup
% 
% 	-- Installation and orientation
% 	setup_transducer_location_type_key	INT, 		-- Location of installed transducer. Following controlled vocabulary in v_transducer_location (ICES instrument_transducer_location)
% 	setup_transducer_location_x		FLOAT, 		-- 
% 	setup_transducer_location_y		FLOAT, 		-- 
% 	setup_transducer_location_z		FLOAT, 		-- 
% 	setup_transducer_depth			TEXT,		-- Mean depth of transducer face beneath the water surface (ICES instrument_transducer_depth)
% 	setup_transducer_orientation_type_key 	INT,		-- Direction perpendicular to the face of the transducer. Following controlled vocabulary in v_transducer_orientation (ICES instrument_transducer_orientation)
% 	setup_transducer_orientation_vx		FLOAT,		-- 
% 	setup_transducer_orientation_vy		FLOAT,		-- 
% 	setup_transducer_orientation_vz		FLOAT,		-- 
% 
% 	-- Calibration
% 	setup_calibration_key			INT, 		--
% 	--Parameters
% 	setup_parameters_key			INT, 		--
% 	
% 	setup_comments				TEXT,		-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
% 
% 	FOREIGN KEY (setup_cruise_or_deployment_key) REFERENCES t_cruise_or_deployment(cruise_or_deployment_pkey),
% 	FOREIGN KEY (setup_platform_type_key) REFERENCES t_platform_type(platform_type_pkey),
% 	FOREIGN KEY (setup_transceiver_key) REFERENCES t_transceiver(transceiver_pkey),
% 	FOREIGN KEY (setup_transducer_key) REFERENCES t_transducer(transducer_pkey),
% 	FOREIGN KEY (setup_transducer_location_type_key) REFERENCES t_transducer_location_type(transducer_location_type_pkey),
% 	FOREIGN KEY (setup_transducer_orientation_type_key) REFERENCES t_transducer_orientation_type(transducer_orientation_type_pkey),
% 	FOREIGN KEY (setup_calibration_key) REFERENCES t_calibration(calibration_pkey)
% 	FOREIGN KEY (setup_parameters_key) REFERENCES t_parameters(parameters_pkey)
% 	UNIQUE(setup_cruise_or_deployment_key,setup_cruise_key,setup_platform_type_key,setup_deployment_key,setup_transceiver_key,setup_transducer_key,setup_calibration_key,setup_parameters_key) ON CONFLICT IGNORE
% );
% COMMENT ON TABLE t_setup is 'Each setup (or alteration of existing setup) of a transducer/transceiver combination.';

function setup_pkey=add_setup_to_t_setup(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'setup_platform_type_key',0,@isnumeric);
addParameter(p,'setup_deployment_key',0,@isnumeric);
addParameter(p,'setup_calibration_key',0,@isnumeric);
addParameter(p,'setup_parameters_key',0,@isnumeric);

addParameter(p,'setup_transducer_key',0,@isnumeric);
addParameter(p,'setup_transceiver_key',0,@isnumeric);

addParameter(p,'setup_transducer_location_type_key',0,@isnumeric);
addParameter(p,'setup_transducer_location_x',0,@isnumeric);
addParameter(p,'setup_transducer_location_y',0,@isnumeric);
addParameter(p,'setup_transducer_location_z',0,@isnumeric);
addParameter(p,'setup_transducer_location_depth',0,@isnumeric);

addParameter(p,'setup_transducer_orientation_type_key',0,@isnumeric);
addParameter(p,'setup_transducer_orientation_vx',0,@isnumeric);
addParameter(p,'setup_transducer_orientation_vy',0,@isnumeric);
addParameter(p,'setup_transducer_orientation_vz',0,@isnumeric);

addParameter(p,'setup_comments','',@ischar);

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
dbconn.insert('t_setup',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'parameters_comments');
[~,setup_pkey]=get_cols_from_table(ac_db_filename,'t_setup','input_struct',struct_in,'output_cols',{'setup_pkey'});



