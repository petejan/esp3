/* NIWA-MPI ACOUSTIC DATABASE GENERATION SCRIPT, version 0.1.4 (Ladroit, 09 Apr 2018, 9:00)

* This text file is the SQL script that, when executed with psql, creates the content tables of the acoustic database.
* It follows as much as possible the ICES metadata convention, augmented for NIWA-MPI needs.
* Authors: Alexandre Schimel, Yoann Ladroit, Brent Wood.

* The database is organized in three general groups of tables:
1. A group of tables related to the LOGISTICS: mission, deployment, ship.
2. A group of tables related to the INSTRUMENTS: transducer, transceivers, setup, calibration, software, ancillary
3. A group of tables related to the DATA: file, parameters, transect, navigation.

* Following NIWA convention, all tables start with the prefix "t_"
* The primary key for all tables is an auto-incrementing SERIAL attribute bearing the name of the table, without the prefix but with the suffix "_pkey" (i.e attribute "XXX_pkey" for table "t_XXX")
* The main tables are those with a single word (e.g. t_XXX).
* One-to-many relationships are formalized using a foreign key in the table on the "many" side referencing the primary key in the table on the "one" side. As in:

FOREIGN KEY (YYY_ZZZ_key) REFERENCES t_XXX(XXX_pkey)

* A table ending with the word "type" (e.g. t_XXX_type) is a look-up table for controlled vocabulary for an attribute in a regular table. It follows the template:

CREATE TABLE t_XXX_type
(	
	XXX_type_pkey	SERIAL PRIMARY KEY,
	XXX_type		TEXT -- Description following controlled vocabulary
);

with a foreign key in the parent table following the template:
FOREIGN KEY (XXX_key) REFERENCES t_XXX_type(XXX_type_pkey)

* A table with two words (e.g. t_XXX_YYY) is a "join" table to manage many-to-many relationships between two tables (t_XXX and t_YYY to follow the example). It follows the template:

CREATE TABLE t_XXX_YYY
(
	XXX_YYY_pkey 		SERIAL PRIMARY KEY,
	XXX_key    			INT,
	YYY_key      		INT,
	XXX_YYY_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (XXX_key) REFERENCES t_XXX(XXX_pkey),
	FOREIGN KEY (YYY_key) REFERENCES t_YYY(YYY_pkey)
);

*/

/* ----- LOGISTICS GROUP -----

Introduction:
* Group of tables describing the project, vessel, voyages, etc.

Main tables:
* t_mission describing each mission/project for which acoustic data were collected.
* t_ship describing each ship/vessel from which acoustic data were collected.
* t_deployment describing each deployment from which acoustic data were collected (cruise, mooring, buoy, motorized/unmotorized gliders, autonomous surface/underwater vehicles, etc.).

Rules between main tables:
* 1 mission makes use of 0, 1 or several deployments. 1 deployment is used for 1 or several missions.
* 1 ship is used in 0, 1 or several deployments. 1 deployment makes use of 0 or 1 ship.

Controlled vocabulary tables:
* t_ship_type controlled vocabulary table for type of ship (research, fishing, etc.)
* t_deployment_type controlled vocabulary table for type of deployment (cruise, mooring, glider, etc.)

Join tables:
* t_mission_deployment to manage the many-many relationship between t_mission and t_deployment.

Notes:
* All attributes from the ICES category "Mission" are found in table "t_mission", except for attribute "mission_platform_type" which is split between look-up tables "t_ship_type" and "t_deployment_type". This is because a mission may use several platforms.
* All attributes from the ICES category "Ship" are found in table "t_ship", with "t_ship_type" used a look-up table for the attribute ship_type.
* Table "t_deployment" combine the attributes of ICES categories "cruise" and "mooring", and can be used for other types of deployments (buoy, glider, etc.). Only attribute mooring_depth is missing from table t_deployment. 
*/

CREATE TABLE t_mission
(
	mission_pkey 					SERIAL PRIMARY KEY,
	
	mission_name 					TEXT, 		-- Name of mission (ICES mission_name)
	mission_abstract 				TEXT, 		-- Text description of the mission, its purpose, scientific objectives and area of operation (ICES mission_abstract)
	mission_start_date 				TIMESTAMP,	-- Start date and time of the mission (ICES mission_start_date)
	mission_end_date 				TIMESTAMP,	-- End date and time of the mission (ICES mission_end_date)
	principal_investigator			TEXT,		-- Name of the principal investigator in charge of the mission (ICES principal_investigator)
	principal_investigator_email	TEXT,		-- Principal investigator e-mail address (ICES principal_investigator_email)
	institution 					TEXT,		-- Name of the institute, facility, or company where the original data were produced (ICES institution)
	data_centre 					TEXT,		-- Data centre in charge of the data management or party who distributed the resource (ICES data_centre)
	data_centre_email 				TEXT,		-- Data centre contact e-mail address (ICES data_centre_email)
	mission_id						TEXT, 		-- ID code of mission (ICES mission_id) 
	creator							TEXT,		-- Entity primarily responsible for making the resource (ICES creator)
	contributor						TEXT,		-- Entity responsible for making contributions to the resource (ICES contributor)
	
	mission_comments				TEXT,		-- Free text fields for relevant information not captured by other attributes (ICES mission_comments)
	
	UNIQUE (mission_name) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_mission is 'Missions or projects for which acoustic data were collected.';


CREATE TABLE t_ship_type
(	
	ship_type_pkey	SERIAL PRIMARY KEY,
	ship_type		TEXT -- Describe type of ship that is hosting the acoustic instrumentation (ICES ship_type and mission_platform)
);
COMMENT ON TABLE t_ship_type is 'Controlled vocabulary for ship_type attribute in t_cruise.';
INSERT INTO t_ship_type (ship_type) VALUES ('Ship, research'),('Ship, fishing'),('Ship, other');


CREATE TABLE t_ship
(
	ship_pkey			SERIAL PRIMARY KEY,
	
	ship_name 			TEXT, 	-- Name of the ship (ICES ship_name)
	ship_type_key		INT,	-- Describe type of ship that is hosting the acoustic instrumentation. See controlled vocabulary table t_ship_type (ICES ship_type and mission_platform)
	ship_code			TEXT,	-- For example, in-house code associated with ship (ICES ship_code). At NIWA, the three letters code (e.g. TAN for Tangaroa)
	ship_platform_code	TEXT, 	-- ICES database of known ships (ICES ship_platform_code)
	ship_platform_class	TEXT,	-- ICES controlled vocabulary for platform class (ICES ship_platform_class)
	ship_callsign		TEXT,	-- Ship call sign (ICES ship_callsign)
	ship_alt_callsign	TEXT,	-- Alternative call sign if the ship has more than one (ICES ship_alt_callsign)
	ship_IMO			INT,	-- Ship's International Maritime Organization ship identification number (ICES ship_IMO)
	ship_operator		TEXT,	-- Name of organization of company which operates the ship (ICES ship_opeartor)
	ship_length			FLOAT,	-- Overall length of the ship (m) (ICES ship_length)
	ship_breadth		FLOAT,	-- The width of the ship at its widest point (m) (ICES ship_breadth)
	ship_draft			FLOAT,	-- The draft of the ship
	ship_tonnage		FLOAT,	-- Gross tonnage of the ship (t) (ICES ship_tonnage)
	ship_engine_power	FLOAT,	-- The total power available for ship propulsion (ICES ship_engine_power)
	ship_noise_design	TEXT,	-- For example, ICES 209 compliant (Mitson, 1995). Otherwise description of noise performance of the ship (ICES ship_noise_design)
	ship_aknowledgement	TEXT,	-- Any users (include re-packagers) of these data are required to clearly acknowledge the source of the material in this format (ICES ship_aknowledgement)
	
	ship_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES ship_comments)
	
	UNIQUE (ship_IMO,ship_type_key,ship_name) ON CONFLICT IGNORE
	FOREIGN KEY (ship_type_key) REFERENCES t_ship_type(ship_type_pkey)
);
COMMENT ON TABLE t_ship is 'Ships or vessels from which acoustic data were collected.';


CREATE TABLE t_deployment_type
(	
	deployment_type_pkey	SERIAL PRIMARY KEY,
	deployment_type		TEXT -- Describe type of deployment platform that is hosting the acoustic instrumentation (ICES mission_platform)
);
COMMENT ON TABLE t_deployment_type is 'Controlled vocabulary for deployment_type attribute in t_deployment.';
INSERT INTO t_deployment_type (deployment_type) VALUES  ('Ship') ,('Buoy, moored'),('Buoy, drifting'),('Glider'),('Underwater vehicle, autonomous, motorized'),('Underwater vehicle, autonomous, glider'); -- Another ICES entry is possible ('Underwater vehicle, towed') but we remove it here as towed bodies (and AOS) fall under the cruise category


CREATE TABLE t_deployment
(
	deployment_pkey			SERIAL PRIMARY KEY,

	-- Deployment platform type (see ICES mission_platform)
	deployment_type_key			INT,		-- Describe type of deployment platform that is hosting the acoustic instrumentation. See controlled vocabulary table t_deployment_type (ICES mission_platform)
	
	-- Deployment link to ship if deployment_type_key refers to ship
	deployment_ship_key	    	INT,		-- If this deployment is a cruise, reference here the pkey of ship used

	-- Basic info
	deployment_name				TEXT, 		-- Formal name of deployment as recorded by deployment documentation or institutional data centre (ICES cruise_name)
	deployment_id				TEXT, 		-- Deployment ID where one exists (ICES mooring_code and cruise_id). NOTE: used for NIWA trip code for trawl database.
	deployment_description		TEXT,		-- Free text field to describe the deployment (ICES mooring_description and cruise_description)
	deployment_area_description	TEXT,		-- List main areas of operation (ICES mooring_site_name and cruise_area_description)
	deployment_operator			TEXT,		-- Name of organisation which operates the deployment (ICES mooring_operator)
	deployment_summary_report	TEXT,		-- Published or web-based references that links to the deployment report (ICES cruise_summary_report)
	deployment_start_date		TIMESTAMP, 	-- Start date of deployment (ICES mooring_deployment_date and cruise_start_date)                
	deployment_end_date			TIMESTAMP,	-- End date of deployment (ICES mooring_retrieval_date and cruise_end_date)

	-- Geographic info
	deployment_northlimit		FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES mooring_northlimit and cruise_northlimit)
	deployment_eastlimit		FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES mooring_eastlimit and cruise_eastlimit)
	deployment_southlimit		FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES mooring_southlimit and cruise_southlimit)
	deployment_westlimit		FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES mooring_westlimit and cruise_westlimit)
	deployment_uplimit			FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES mooring_uplimit and cruise_uplimit)
	deployment_downlimit		FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES mooring_downlimit and cruise_downlimit)
	deployment_units			TEXT, 		-- The units of unlabelled numeric values of deployment_northlimit, deployment_eastlimit, deployment_southlimit, deployment_westlimit (ICES mooring_units and cruise_units)
	deployment_zunits			TEXT,		-- The units of unlabelled numeric values of deployment_uplimit, deployment_downlimit (ICES mooring_zunits and cruise_zunits)
	deployment_projection		TEXT,		-- The name of the projection used with any parameters required (ICES mooring_projection and cruise_projection)

    -- Additional specific ICES requirements for cruise
	deployment_start_port		TEXT,		-- Commonly used name for the port where cruise started (ICES cruise_start_port)
	deployment_end_port			TEXT,		-- Commonly used name for the port where cruise ended (ICES cruise_end_port)
	deployment_start_BODC_code	TEXT,		-- Name of port from where cruise started (ICES cruise_start_BODC_code)
	deployment_end_BODC_code	TEXT,		-- Name of port from where cruise ended (ICES cruise_end_BODC_code)                 
	
	deployment_comments			TEXT,		-- Free text field for relevant information not captured by other attributes (ICES mooring_comments and cruise_comments)

	FOREIGN KEY (deployment_type_key) REFERENCES t_deployment_type(deployment_type_pkey)
	FOREIGN KEY (deployment_ship_key) REFERENCES t_ship(ship_pkey)
	UNIQUE (deployment_type_key,deployment_ship_key,deployment_id,deployment_operator,deployment_start_date,deployment_end_date,deployment_start_BODC_code,deployment_end_BODC_code) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_deployment is 'Individual deployments of 1 or several acoustic instruments (cruise, mooring deployment, drifting buoy, glider, autonomous vehicle, etc.) with which acoustic data were collected.';


CREATE TABLE t_mission_deployment
(
	mission_deployment_pkey 	SERIAL PRIMARY KEY,

	mission_key    				INT,
	deployment_key     			INT,

	mission_deployment_comments	TEXT, -- Free text field for relevant information not captured by other attributes

	FOREIGN KEY (mission_key) REFERENCES t_mission(mission_pkey)
	FOREIGN KEY (deployment_key) REFERENCES t_deployment(deployment_pkey)
	UNIQUE (mission_key,mission_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_mission_deployment is 'Join table to manage the many-many relationship between t_mission and t_deployment.';



/* ----- INSTRUMENTS GROUP -----

Introduction:
* Group of tables describing the acoustic instruments (transducer, transceiver), the related information (calibration, parameters) and their setups on platform (location, orientation)

Main tables:
* t_transducer describing each (physical) transducer (sonar head);
* t_transceiver describing each (physical) transceiver (GPT);
* t_calibration describing each calibration session;
* t_parameters describing each set of acquisition parameters;
* t_setup describing each individual combination of the above tables, as well as location/orientation;
 
Rules between main tables:
* 1 setup makes use of 1 transducer. 1 transducer can be used used in 0, 1 or several setups.
* 1 setup makes use of 1 transceiver. 1 transceiver can be used used in 0, 1 or several setups.
* 1 setup makes use of 1 calibration. 1 calibration can be used used in 0, 1 or several setups.
* 1 setup makes use of 1 parameters set. 1 parameters set can be used used in 0, 1 or several setups.
* 1 setup is used for 0, 1 or several deployments. 1 deployment makes use of 0, 1 or several setups.

Controlled vocabulary tables:
* t_transducer_beam_type controlled vocabulary type of sonar (split-beam, single-beam, etc.)
* t_platform_type controlled vocabulary table for transducer location as per NIWA vocabulary (Hull, Towbody or AOS)
* t_transducer_location_type controlled vocabulary table for transducer location as per ICES vocabulary ('Hull, keel'; 'Hull, lowered keel';'Towed, shallow';etc.)
* t_transducer_orientation_type controlled vocabulary table for transducer orientation as per ICES vocabulary .

Join tables:
* t_deployment_setup to manage the many-many relationship between t_deployment and t_setup.

Notes:
* The ICES metadata convention suggests only an "instrument" table containing information for transducer, transceiver, and transducer setup (location such as hull, towbody, AOS, etc. or orientation such as downward/upward/etc.).
* This means such table would have a new entry every time we use a different transceiver/transducer combination or change something in the instruments or deploy them on another location.
* Our rendition of this is the table "t_setup", which lists the individual combinations of 1 transducer and 1 transceiver, on 1 platform/location, with 1 orientation, 1 appropriate calibration and 1 set of acquisition parameters, to which one channel in an acoustic file can be uniquely linked.
* The tables "t_transducer" and "t_transceiver" contains all attributes of ICES category "instrument", except "instrument_transducer_location", "instrument_transducer_depth" and "instrument_transducer_orientation" which are features of the setup and thus can be found in "t_setup".
* Frequency is a feature of a transducer/transceiver combination, and thus a single attribute in the ICES "instrument" category, but here split in two separate attributes in the "t_transducer" and "t_transceiver" tables (frequency_nominal).
* Also, attributes were added for lower and upper bounds of frequency ranges for wide-band systems.
* setup_transducer_depth in t_setup is a mean depth for the setup (single value). Good for hull systems, moorings, drifting buoys or autonomous surface vehicles. Not for systems traveling up and down the water-column (towbody, AOS, glider, etc.).
*/


CREATE TABLE t_transducer_beam_type
(
	transducer_beam_type_pkey	SERIAL PRIMARY KEY,
	transducer_beam_type		TEXT -- For example "single-beam, split-aperture" (ICES instrument_transducer_beam_type)
);
COMMENT ON TABLE t_transducer_beam_type is 'Controlled vocabulary for transducer_beam_type attribute in t_transducer';
INSERT INTO t_transducer_beam_type (transducer_beam_type) VALUES ('Single-beam'),('Single-beam, split-aperture'),('Multibeam'),('Multibeam, split-aperture');


CREATE TABLE t_transducer
(
	transducer_pkey					SERIAL PRIMARY KEY,
	
	transducer_manufacturer			TEXT,	-- Transducer manufacturer (ICES instrument_transducer_manufacturer)
	transducer_model				TEXT,	-- Transducer model (ICES instrument_transducer_model)
	transducer_beam_type_key		INT,	-- For example "single-beam, split-aperture". See controlled vocabulary table t_transducer_beam_type (ICES instrument_transducer_beam_type)
	transducer_serial 				TEXT,	-- Transducer serial number (ICES instrument_transducer_serial)
	transducer_frequency_lower		INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transducer_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
	transducer_frequency_upper		INT,	-- For wide-band systems, upper bound of frequency range in kHz
	transducer_psi					FLOAT,	-- Manufacturer specified transducer equivalent beam angle, expressed as 10*log10(psi), where psi has units of steradians (ICES instrument_transducer_psi)
	transducer_beam_angle_major		FLOAT,	-- Major beam opening, also referred to athwartship angle (ICES instrument_transducer_beam_angle_major)
	transducer_beam_angle_minor		FLOAT,	-- Minor beam opening, also referred to alongship angle (ICES instrument_transducer_beam_angle_minor)

	transducer_comments				TEXT,	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)

	FOREIGN KEY (transducer_beam_type_key) REFERENCES t_transducer_beam_type(transducer_beam_type_pkey)
	UNIQUE (transducer_model,transducer_serial,transducer_frequency_nominal) ON CONFLICT IGNORE	
);
COMMENT ON TABLE t_transducer is 'Transducers (sonar heads).';


CREATE TABLE t_transceiver
(
	transceiver_pkey 				SERIAL PRIMARY KEY,
	
	transceiver_manufacturer		TEXT,	-- Transceiver manufacturer (ICES instrument_transceiver_manufacturer)
	transceiver_model				TEXT,	-- Transceiver model (ICES instrument_transceiver_model)
	transceiver_serial 				TEXT,	-- Transceiver serial number (ICES instrument_transceiver_serial)
	transceiver_frequency_lower		INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transceiver_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
	transceiver_frequency_upper		INT,	-- For wide-band systems, upper bound of frequency range in kHz	
	transceiver_firmware 			TEXT,	-- Transceiver firmware version (ICES instrument_transceiver_firmware)
	
	transceiver_comments			TEXT,	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
	
	UNIQUE (transceiver_model,transceiver_serial,transceiver_frequency_nominal) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_transceiver is 'Transceivers (GPT).';


CREATE TABLE t_calibration
(
	calibration_pkey 				SERIAL PRIMARY KEY,
	
	calibration_date				TIMESTAMP,	-- Date of calibration (ICES calibration_date)
	calibration_acquisition_method	TEXT,		-- Describe the method used to acquire calibration data (ICES calibration_acquisition_method)
	calibration_processing_method	TEXT, 		-- Describe method of processing that was used to generate calibration offsets (ICES calibration_processing_method)
	calibration_accuracy_estimate	TEXT, 		-- Estimate of calibration accuracy. Include a description and units so that it is clear what this estimate means (ICES calibration_accuracy_estimate)
	calibration_report				TEXT, 		-- URL or references to external documents which give a full account of calibration processing and results may be appropriate (ICES calibration_report)
	
	calibration_comments			TEXT,		-- Free text field for relevant information not captured by other attributes (ICES calibration_comments)
	
	UNIQUE (calibration_date,calibration_acquisition_method,calibration_processing_method,calibration_accuracy_estimate,calibration_report) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_calibration is 'Calibration sessions';


CREATE TABLE t_parameters
(
	parameters_pkey				SERIAL PRIMARY KEY,
	
	parameters_pulse_mode		TEXT, 	-- CW/FM
	parameters_pulse_length		FLOAT, 	-- in seconds? applies to both CW/FM
	parameters_pulse_slope		FLOAT,	-- pulse slope. applies to both CW/FM
	parameters_FM_pulse_type	TEXT,	-- linear up-sweep, linear down-sweep, exponential up-sweep, exponential down-sweep, etc.
	parameters_frequency_min	INT, 	-- see pulse type to see if upsweep or downsweep
	parameters_frequency_max	INT, 	-- see pulse type to see if upsweep or downsweep
	parameters_power			FLOAT, 	-- in W
	
	parameters_comments			TEXT, 	-- Free text field for relevant information not captured by other attributes
	
	UNIQUE (parameters_pulse_mode,parameters_pulse_length,parameters_pulse_slope,parameters_FM_pulse_type,parameters_frequency_min,parameters_frequency_max,parameters_power) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_parameters is 'Acquisition parameters';


CREATE TABLE t_platform_type
(
	platform_type_pkey	SERIAL PRIMARY KEY,
	platform_type		TEXT -- Location of installed transducer following NIWA vocabulary (Hull, Towbody or AOS). Doubles up a bit with t_transducer_location_type which reflects ICES instrument_transducer_location
);
COMMENT ON TABLE t_platform_type is 'Controlled vocabulary for platform_type attribute in t_setup.';
INSERT INTO t_platform_type (platform_type) VALUES ('Hull'),('Towbody'),('AOS');


CREATE TABLE t_transducer_location_type
(
	transducer_location_type_pkey	SERIAL PRIMARY KEY,
	transducer_location_type		TEXT -- Location of installed transducer following ICES vocabulary (ICES instrument_transducer_location)
);
COMMENT ON TABLE t_transducer_location_type is 'Controlled vocabulary for transducer_location_type attribute in t_setup.';
INSERT INTO t_transducer_location_type (transducer_location_type) VALUES ('Hull, keel'),('Hull, lowered keel'),('Hull, blister'),('Hull, gondola'),('Towed, shallow'),('Towed, deep'),('Towed, deep, trawlnet attached'),('Ship, pole');


CREATE TABLE t_transducer_orientation_type
(
	transducer_orientation_type_pkey	SERIAL PRIMARY KEY,
	transducer_orientation_type			TEXT -- Direction perpendicular to the face of the transducer (ICES instrument_transducer_orientation)
);
COMMENT ON TABLE t_transducer_orientation_type is 'Controlled vocabulary for transducer_orientation attribute in t_setup.';
INSERT INTO t_transducer_orientation_type (transducer_orientation_type) VALUES ('Downward-looking'),('Upward-looking'),('Sideways-looking, forward'),('Sideways-looking, backward'),('Sideways-looking, port'),('Sideways-looking, starboard'),('Other');


CREATE TABLE t_setup
(
	setup_pkey								SERIAL PRIMARY KEY,

	-- What instruments
	setup_transceiver_key					INT,		-- Refers to attribute transceiver_pkey in t_transceiver
	setup_transducer_key					INT,		-- Refers to attribute transducer_pkey in t_transducer

	-- Location and orientation of instruments
	setup_platform_type_key					INT, 		-- Location of installed transducer following NIWA vocabulary (Hull, Towbody or AOS). See controlled vocabulary table t_platform_type
	setup_transducer_location_type_key		INT, 		-- Location of installed transducer following ICES vocabulary ('Hull, keel'; 'Hull, lowered keel';'Towed, shallow';etc.). See controlled vocabulary table t_transducer_location_type (ICES instrument_transducer_location)
	setup_transducer_location_x				FLOAT, 		-- 
	setup_transducer_location_y				FLOAT, 		-- 
	setup_transducer_location_z				FLOAT, 		-- 
	setup_transducer_depth					FLOAT,		-- Mean depth of transducer face beneath the water surface (ICES instrument_transducer_depth)
	setup_transducer_orientation_type_key 	INT,		-- Direction perpendicular to the face of the transducer. See controlled vocabulary table t_transducer_orientation_type (ICES instrument_transducer_orientation)
	setup_transducer_orientation_vx			FLOAT,		-- 
	setup_transducer_orientation_vy			FLOAT,		-- 
	setup_transducer_orientation_vz			FLOAT,		-- 

	-- Calibration
	setup_calibration_key					INT, 		-- Refers to attribute calibration_pkey in t_calibration
	
	-- Acquisition parameters
	setup_parameters_key					INT, 		-- Refers to attribute parameters_pkey in t_parameters
	
	setup_comments							TEXT,		-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
	
	FOREIGN KEY (setup_platform_type_key) REFERENCES t_platform_type(platform_type_pkey),
	FOREIGN KEY (setup_transceiver_key) REFERENCES t_transceiver(transceiver_pkey),
	FOREIGN KEY (setup_transducer_key) REFERENCES t_transducer(transducer_pkey),
	FOREIGN KEY (setup_transducer_location_type_key) REFERENCES t_transducer_location_type(transducer_location_type_pkey),
	FOREIGN KEY (setup_transducer_orientation_type_key) REFERENCES t_transducer_orientation_type(transducer_orientation_type_pkey),
	FOREIGN KEY (setup_calibration_key) REFERENCES t_calibration(calibration_pkey)
	FOREIGN KEY (setup_parameters_key) REFERENCES t_parameters(parameters_pkey)
	UNIQUE (setup_platform_type_key,setup_transceiver_key,setup_transducer_key,setup_calibration_key,setup_parameters_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_setup is 'Individual combinations of 1 transducer and 1 transceiver, on 1 platform/location, with 1 orientation, 1 appropriate calibration and 1 set of acquisition parameters, to which one channel in an acoustic file can be uniquely linked.';


CREATE TABLE t_deployment_setup
(
	deployment_setup_pkey 		SERIAL PRIMARY KEY,
	
	deployment_key      		INT,
	setup_key    				INT,
	
	deployment_setup_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (deployment_key) REFERENCES t_deployment(deployment_pkey),
	FOREIGN KEY (setup_key) REFERENCES t_setup(setup_pkey)
	UNIQUE (deployment_key,setup_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_deployment_setup is 'Join table to manage the many-many relationship between t_deployment_setup and t_setup.';




/* ----- DATA GROUP -----

Introduction:
* Group of tables for acoustic data and related information (software, navigation, etc.)

Main tables:
* t_software describing each instance of a new software install on a new computer (or updating to new version);
* t_file describing each acoustic data file
* t_navigation describing simplified acoustic data file navigation
* t_transect describing each acoustic data transect
* t_ancillary describing any other instruments - GPS, pitch roll sensor, anemometer, etc.

Rules between main tables:
* 1 file was acquired with 1 software. 1 software is used to acquire 0, 1 or several files.
* 1 file has several navigation entries. 1 navigation entry is valid for 1 file.
* 1 file can contain 0, 1 or several transects. 1 transect can span 1 or several files.
* 1 file contain data from 0, 1, or several ancillary instruments. 1 ancillary instrument can have data in 0, 1 or several files. 
* 1 file contains 1 or several channels, aka relate to 1 or several setups. 1 setup results in 0, 1 or several files.

Every file instance contains SEVERAL channels, so need for a join table between t_file and t_setup.
* One transect can be on several files, while one file can contains several transects, so need for a join table between t_file and t_transect.

Join tables:
* t_file_transect to manage the many-many relationship between t_file and t_transect.
* t_file_ancillary to manage the many-many relationship between t_file and t_ancillary.
* t_file_setup to manage the many-many relationship between t_file and t_setup.

Notes:
* The ICES metadata convention category "transect" only contains info about time (start/end) and space (XYZ) bounds for a "transect", and then "data" and "dataset" for the metadata of what looks like a final, processed data.
* What we needed was one table listing the individual files recorded, and one table listing the "set of consecutive pings to be processed together whether they're a subset of the pings in one file, or span several consecutive files", which we called "transect" to follow ICES, even though it might be confusing with our past use of "transect" as a transect number field.
* By listing which transects are in which files, the t_file_transect join table allows identifying the files that span a given transect. Then use the start and end times in relevant transect/files to find the exact bounds of transect data.
* transect_id in ICES category transect was removed as it doubles up with transect_pkey
* ICES category transect has geographic information (northlimit, eastlimit, etc.) that isn't used as attribute here, as all necessary information can be retrieved from t_navigation
*/

CREATE TABLE t_software
(
	software_pkey			SERIAL PRIMARY KEY,
	
	software_manufacturer	TEXT,		--
	software_name			TEXT,		--
	software_version		TEXT,		--
	software_host			TEXT,		--
	software_install_date	TIMESTAMP,	--

	software_comments		TEXT,		-- Free text field for relevant information not captured by other attributes 
	
	UNIQUE (software_manufacturer,software_name,software_version,software_host,software_install_date) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_software is 'Instances of new software install on a new computer (or updating to new version).';


CREATE TABLE t_file
(
	file_pkey   		SERIAL PRIMARY KEY,
	
	file_name			TEXT,	 	--
	file_path			TEXT, 		--
	file_start_time		TIMESTAMP,	--
	file_end_time		TIMESTAMP,	--
	file_software_key	INT, 		-- Software used to record the file
	
	file_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (file_software_key) REFERENCES t_software(software_pkey),
	UNIQUE (file_path,file_name) ON CONFLICT REPLACE,
    CHECK (file_end_time>=file_start_time) ON CONFLICT FAIL
);
COMMENT ON TABLE t_file is 'Acoustic data files';


CREATE TABLE t_navigation
(
	navigation_pkey			SERIAL PRIMARY KEY,
	
	navigation_time			TIMESTAMP,	--
	navigation_latitude		FLOAT,		--
	navigation_longitude	FLOAT,		--
	navigation_depth 		FLOAT,		--
	navigation_file_key		INT,		-- Identifier of file for which this navigation data record is relevant
	
	navigation_comments		TEXT,	 	-- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (navigation_file_key) REFERENCES t_file(file_pkey),
	UNIQUE (navigation_time,navigation_file_key) ON CONFLICT REPLACE
);
COMMENT ON TABLE t_navigation is 'Simplified acoustic data file navigation';


CREATE TABLE t_transect
(
	transect_pkey    			SERIAL PRIMARY KEY, -- NOTE: can be used for ICES transect_id
	
	-- ICES basics
	transect_name				TEXT, 		-- Name of the transect (ICES transect_name)
	transect_description		TEXT,		-- Description of the transect, its purpose, and main activity (ICES transect_description). NOTE: will be the same as "transect_type" for now
	transect_related_activity	TEXT,		-- Describe related activities that may occur on the transect (ICES transect_related_activity). NOTE: should be "linked" to the transect_station
	transect_start_time			TIMESTAMP,	-- Start time of the transect (ICES transect_start_time)
	transect_end_time			TIMESTAMP,	-- End time of the transect (ICES transect_end_time)
	
	-- Formalized info attributes NIWA-MPI actually need. Not in ICES
	transect_snapshot			INT, 		-- To identify time repeats. Typically for statistical purposes, in acoustic surveys
	transect_stratum			TEXT, 		-- To identify geographically different areas. Typically for statistical purposes, in trawl surveys 
	transect_station			TEXT, 		-- To identify separate targets. Typically station numbers in trawl survey, or marks in acoustic surveys 
	transect_type				TEXT, 		-- To identify categorically different data purposes, e.g. transit/steam/trawl/junk/test/etc. 
	transect_number				INT, 		-- To identify separate transects in a same snapshot/stratum/station/type

	transect_comments			TEXT,		-- Free text field for relevant information not captured by other attributes (ICES transect_comments)	
	
	UNIQUE (transect_snapshot,transect_stratum,transect_type,transect_number,transect_start_time,transect_end_time) ON CONFLICT REPLACE,
	CHECK (transect_end_time>=transect_start_time) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_transect is 'Acoustic data transects';


CREATE TABLE t_ancillary
(
	ancillary_pkey			SERIAL PRIMARY KEY,
	
	ancillary_type			TEXT,	--
	ancillary_manufacturer	TEXT,	-- 
	ancillary_model			TEXT,	-- 
	ancillary_serial 		TEXT,	-- 
	ancillary_firmware 		TEXT,	-- 
		
	ancillary_comments		TEXT,	-- Free text field for relevant information not captured by other attributes 
	
	UNIQUE (ancillary_type,ancillary_manufacturer,ancillary_model,ancillary_serial) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_ancillary is 'Any other instruments - GPS, pitch roll sensor, anemometer, etc.';


CREATE TABLE t_file_transect
(
	file_transect_pkey 	SERIAL PRIMARY KEY,
	
	file_key      		INT,
	transect_key    	INT,
	
	file_transect_comments	TEXT, -- Free text field for relevant information not captured by other attributes	
	
	FOREIGN KEY (file_key) REFERENCES t_file(file_pkey),
	FOREIGN KEY (transect_key) REFERENCES t_transect(transect_pkey),
	UNIQUE (file_key,transect_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_file_transect is 'Join table to manage the many-many relationship between t_file and t_transect.';


CREATE TABLE t_file_setup
(
	file_setup_pkey 	SERIAL PRIMARY KEY,
	
	file_key      		INT,
	setup_key    		INT,
	
	file_setup_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (file_key) REFERENCES t_file(file_pkey),
	FOREIGN KEY (setup_key) REFERENCES t_setup(setup_pkey)
	UNIQUE (file_key,setup_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_file_setup is 'Join table to manage the many-many relationship between t_file and t_setup.';


CREATE TABLE t_file_ancillary
(
	file_ancillary_pkey 	SERIAL PRIMARY KEY,
	
	file_key      			INT,
	ancillary_key    		INT,
	file_ancillary_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (file_key) REFERENCES t_file(file_pkey),
	FOREIGN KEY (ancillary_key) REFERENCES t_ancillary(ancillary_pkey)
	UNIQUE (file_key,ancillary_key) ON CONFLICT IGNORE
);
COMMENT ON TABLE t_file_ancillary is 'Join table to manage the many-many relationship between t_file and t_ancillary.';

/* ----- PRAGMAS ----- */
PRAGMA recursive_triggers = "1";
PRAGMA foreign_keys = "1";

/* ----- TRIGGERS -----  */
to help for many to many relationships

/* CREATE TRIGGER t_transect_after_insert_trigger 
AFTER INSERT ON t_transect 
BEGIN
	INSERT INTO t_file_transect ( transect_key, file_key )
	SELECT t.transect_pkey, f.file_pkey
		FROM t_transect t INNER JOIN t_file f ON NOT f.file_start_time>t.transect_end_time AND NOT f.file_end_time<t.transect_start_time
		WHERE t.transect_pkey = NEW.transect_pkey;
END;  */

CREATE TRIGGER t_transect_after_insert_trigger 
AFTER INSERT ON t_transect 
BEGIN
	INSERT INTO t_file_transect ( transect_key, file_key )
	SELECT t.transect_pkey, f.file_pkey
		FROM t_transect t, t_file f
		WHERE NOT f.file_start_time>t.transect_end_time AND NOT f.file_end_time<t.transect_start_time AND t.transect_pkey = NEW.transect_pkey;
END; 

CREATE TRIGGER t_transect_after_delete_trigger 
AFTER DELETE ON t_transect 
BEGIN
	DELETE FROM t_file_transect
	WHERE transect_key = OLD.transect_pkey;
END; 

CREATE TRIGGER t_file_after_delete_trigger 
AFTER DELETE ON t_file 
BEGIN
	DELETE FROM t_file_setup
		WHERE file_key = OLD.file_pkey;
	DELETE FROM t_file_transect
		WHERE file_key = OLD.file_pkey;
	DELETE FROM t_file_ancillary
		WHERE file_key = OLD.file_pkey;
	DELETE FROM t_navigation
		WHERE navigation_file_key = OLD.file_pkey;
END;

CREATE TRIGGER t_deployment_after_delete_trigger 
AFTER DELETE ON t_deployment 
BEGIN
	DELETE FROM t_mission_deployment
		WHERE deployment_key = OLD.deployment_pkey;
END;


