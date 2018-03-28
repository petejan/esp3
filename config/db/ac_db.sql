/* GENERAL INTRODUCTION AND NOTES:

* This text file is the SQL script that, when executed with psql, creates the content tables of the acoustic database.
* It follows as much as possible the ICES metadata convention, augmented for NIWA/MPI needs.

* The database is organized in three general groups of tables:
1. A group of tables related to the LOGISTICS: mission, deployment, ship, and cruise.
2. A group of tables related to the INSTRUMENTS: transducer, transceivers, setup, calibration, software, ancillary
3. A group of tables related to the DATA: file, parameters, transect, navigation.

* Following NIWA convention, all tables start with the prefix "t_"
* The primary key for all tables is an auto-incrementing SERIAL attribute bearing the name of the table, without the prefix but with the suffix "_pkey" (i.e attribute "XXX_pkey" for table "t_XXX")
* The main tables are those with a single word (e.g. t_XXX).
* One-to-many relationships are formalized using a foreign key in the table on the "many" side referencing the primary key in the table on the "one" side. As in:

FOREIGN KEY (YYY_ZZZ_key) REFERENCES t_XXX(XXX_pkey)

* A table starting with the word "vocabulary" (e.g. t_vocabulary_XXX) is a look-up table for controlled vocabulary for an attribute in a regular table. It follows the template:

CREATE TABLE t_vocabulary_XXX
(	
	vocabulary_XXX_pkey	SERIAL PRIMARY KEY,
	XXX			TEXT -- Description following controlled vocabulary
);

with a foreign key in the parent table following the template:
FOREIGN KEY (YYY_ZZZ_key) REFERENCES t_vocabulary_XXX(vocabulary_XXX_pkey)

* A table with two words (e.g. t_XXX_YYY) is a "join" table to manage many-to-many relationships between two tables (t_XXX and t_YYY to follow the example). It follows the template:

CREATE TABLE t_XXX_YYY
(
	XXX_YYY_pkey 		SERIAL PRIMARY KEY,
	XXX_key    		INT,
	YYY_key      		INT,
	XXX_YYY_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (XXX_key) REFERENCES t_XXX(XXX_pkey),
	FOREIGN KEY (YYY_key) REFERENCES t_YYY(YYY_pkey)
);

*/
/* ----- LOGISTICS GROUP -----

Introduction:
* Group of tables to describe the project, vessel, voyages, etc.

Main tables:
* t_mission describing each mission/project for which acoustic data were collected;
* t_cruise describing each cruise/voyage/trip during which acoustic data were collected (hull, towed bodies, AOS, and all other manned platforms of platforms operated from a ship);
* t_ship describing each ship/vessel from which acoustic data were collected;
* t_deployment describing each deployment from which acoustic data were collected (mooring, buoy, motorized/unmotorized gliders, autonomous surface/underwater vehicles, and all other unmanned platforms not operated from a ship);

Controlled vocabulary tables:
* t_ship_type controlled vocabulary table for ship_type attribute in t_ship.
* t_deployment_type controlled vocabulary table for deployment_type attribute in t_deployment.

Join tables:
* t_mission_cruise to manage the many-many relationship between t_mission and t_cruise.
* t_mission_deployment to manage the many-many relationship between t_mission and t_deployment.

Rules:
* 1 ship is used in 0, 1 or several cruises
* 1 cruise uses 1 ship
* 1 cruise uses 0, 1, or several towbodies
* 1 towbody is used in 0, 1, or several cruises
* 1 cruise is used for 1 or several missions
* 1 mission makes use of 0, 1 or several cruises
* 1 mission makes use of 0, 1 or several deployments
* 1 deployment is used for 1 mission

Notes:
* All attributes from the ICES category "Mission" are found in table "t_mission", except for attribute "mission_platform_type" which is split between look-up tables "t_ship_type" and "t_deployment_type".
* All attributes from the ICES category "Ship" are found in table "t_ship".
", "cruise" and "deployment" tables follow exactly the ICES categories with the same name. Only serial primary keys were added.
*/

CREATE TABLE t_mission
(
	mission_pkey 			SERIAL PRIMARY KEY,
	
	mission_name 			TEXT, 		-- Name of mission (ICES mission_name)
	mission_abstract 		TEXT, 		-- Text description of the mission, its purpose, scientific objectives and area of operation (ICES mission_abstract)
	mission_start_date 		TIMESTAMP,	-- Start date and time of the mission (ICES mission_start_date)
	mission_end_date 		TIMESTAMP,	-- End date and time of the mission (ICES mission_end_date)
	principal_investigator 		TEXT,		-- Name of the principal investigator in charge of the mission (ICES principal_investigator)
	principal_investigator_email	TEXT,		-- Principal investigator e-mail address (ICES principal_investigator_email)
	institution 			TEXT,		-- Name of the institute, facility, or company where the original data were produced (ICES institution)
	data_centre 			TEXT,		-- Data centre in charge of the data management or party who distributed the resource (ICES data_centre)
	data_centre_email 		TEXT,		-- Data centre contact e-mail address (ICES data_centre_email)
	mission_id			TEXT, 		-- ID code of mission (ICES mission_id) 
	creator				TEXT,		-- Entity primarily responsible for making the resource (ICES creator)
	contributor			TEXT,		-- Entity responsible for making contributions to the resource (ICES contributor)
	
	mission_comments		TEXT		-- Free text fields for relevant information not captured by other attributes (ICES mission_comments)
);
COMMENT ON TABLE t_mission is 'Mission or projects for which acoustic data were collected.';

CREATE TABLE t_ship_type
(	
	ship_type_pkey	SERIAL PRIMARY KEY,
	ship_type		TEXT -- Describe type of ship that is hosting the acoustic instrumentation following controlled vocabulary (ICES ship_type and mission_platform)
);
COMMENT ON TABLE t_ship_type is 'Controlled vocabulary for ship_type attribute in t_cruise.';
INSERT INTO t_ship_type (ship_type) VALUES ('Ship, research'),('Ship, fishing'),('Ship, other');

CREATE TABLE t_ship
(
	ship_pkey		SERIAL PRIMARY KEY,
	
	ship_type_key		INT,	-- Describe type of ship that is hosting the acoustic instrumentation. See the lookup table t_ship_type (ICES ship_type and mission_platform)
	ship_name 		TEXT, 	-- Name of the ship (ICES ship_name)
	ship_code		TEXT,	-- For example, in-house code associated with ship (ICES ship_code). At NIWA, the three letters code (e.g. TAN for Tangaroa)
	ship_platform_code	TEXT, 	-- ICES database of known ships (ICES ship_platform_code)
	ship_platform_class	TEXT,	-- ICES controlled vocabulary for platform class (ICES ship_platform_class)
	ship_callsign		TEXT,	-- Ship call sign (ICES ship_callsign)
	ship_alt_callsign	TEXT,	-- Alternative call sign if the ship has more than one (ICES ship_alt_callsign)
	ship_IMO		TEXT,	-- Ship's International Maritime Organization ship identification number (ICES ship_IMO)
	ship_operator		TEXT,	-- Name of organization of company which operates the ship (ICES ship_opeartor)
	ship_length		FLOAT,	-- Overall length of the ship (m) (ICES ship_length)
	ship_breadth		FLOAT,	-- The width of the ship at its widest point (m) (ICES ship_breadth)
	ship_tonnage		FLOAT,	-- Gross tonnage of the ship (t) (ICES ship_tonnage)
	ship_engine_power	FLOAT,	-- The total power available for ship propulsion (ICES ship_engine_power)
	ship_noise_design	TEXT,	-- For example, ICES 209 compliant (Mitson, 1995). Otherwise description of noise performance of the ship (ICES ship_noise_design)
	ship_aknowledgement	TEXT,	-- Any users (include re-packagers) of these data are required to clearly acknowledge the source of the material in this format (ICES ship_aknowledgement)
	
	ship_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES ship_comments)

	FOREIGN KEY (ship_type_key) REFERENCES t_ship_type(ship_type_pkey)
);
COMMENT ON TABLE t_ship is 'Ships or vessels from which acoustic data were collected.';

CREATE TABLE t_cruise
(
	cruise_pkey			SERIAL PRIMARY KEY,

	-- Cruise link to ship
	cruise_ship_key			INT,		-- ID of ship used in cruise

	-- Basic info on cruise/deployment
	cruise_name			TEXT,		-- Formal name of cruise as recorded by cruise documentation or institutional data centre (ICES cruise_name)
	cruise_id			TEXT, 		-- Cruise ID where one exists (ICES cruise_id). Use NIWA voyage code here.
	cruise_description		TEXT,		-- Free text field to describe the cruise (ICES cruise_description)
	cruise_area_description		TEXT,		-- List main areas of operation (ICES cruise_area_description)
	cruise_operator			TEXT,		-- Name of organisation which operates the cruise (No ICES attribute for this normally, but inspired from mooring_operator)
	cruise_summary_report		TEXT,		-- Published or web-based references that links to the cruise report (ICES cruise_summary_report)
	cruise_start_date		TIMESTAMP,	-- Start date of cruise (ICES cruise_start_date)
	cruise_end_date			TIMESTAMP,	-- End date of cruise (ICES cruise_end_date)

	-- ICES geographic info on cruise/deployment
	cruise_northlimit		FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES cruise_northlimit)
	cruise_eastlimit		FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES cruise_eastlimit)
	cruise_southlimit		FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES cruise_southlimit)
	cruise_westlimit		FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES cruise_westlimit)
	cruise_uplimit			FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES cruise_uplimit)
	cruise_downlimit		FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES cruise_downlimit)
	cruise_units			TEXT, 		-- The units of unlabelled numeric values of cruise_northlimit, cruise_eastlimit, cruise_southlimit, cruise_westlimit (ICES cruise_units)
	cruise_zunits			TEXT,		-- The units of unlabelled numeric values of cruise_uplimit, cruise_downlimit (ICES cruise_zunits)
	cruise_projection		TEXT,		-- The name of the projection used with any parameters required (ICES cruise_projection)

	-- Additional specific ICES requirements for cruise
	cruise_start_port		TEXT,		-- Commonly used name for the port where cruise started (ICES cruise_start_port)
	cruise_end_port			TEXT,		-- Commonly used name for the port where cruise ended (ICES cruise_end_port)
	cruise_start_BODC_code		TEXT,		-- Name of port from where cruise started (ICES cruise_start_BODC_code)
	cruise_end_BODC_code		TEXT,		-- Name of port from where cruise ended (ICES cruise_end_BODC_code)
	
	cruise_comments			TEXT,		-- Free text field for relevant information not captured by other attributes (ICES cruise_comments)

	FOREIGN KEY (cruise_ship_key) REFERENCES t_ship(ship_pkey)
);
COMMENT ON TABLE t_cruise is 'describes each cruise/voyage/trip during which acoustic data were collected.';

CREATE TABLE t_deployment_type
(	
	deployment_type_pkey	SERIAL PRIMARY KEY,
	deployment_type		TEXT -- Describe type of deployment platform that is hosting the acoustic instrumentation following controlled vocabulary (ICES mission_platform)
);
COMMENT ON TABLE t_deployment_type is 'Controlled vocabulary for deployment_type attribute in t_deployment.';
INSERT INTO t_deployment_type (deployment_type) VALUES ('Buoy, moored'),('Buoy, drifting'),('Glider'),('Underwater vehicle, autonomous, motorized'),('Underwater vehicle, autonomous, glider'); -- Another ICES entry is possible ('Underwater vehicle, towed') but we remove it here as towed bodies (and AOS) fall under the cruise category

CREATE TABLE t_deployment
(
	deployment_pkey			SERIAL PRIMARY KEY,

	-- Deployment platform type (see ICES mission_platform)
	deployment_type_key		INT,		-- Describe type of deployment platform that is hosting the acoustic instrumentation. See the lookup table t_deployment_type (ICES mission_platform)

	-- Basic info on cruise/deployment
	deployment_name			TEXT, 		-- Formal name of deployment as recorded by deployment documentation or institutional data centre (No ICES attribute for this normally, but inspired from cruise_name)
	deployment_id			TEXT, 		-- Deployment ID where one exists (ICES mooring_code)
	deployment_description		TEXT,		-- Free text field to describe the deployment (ICES mooring_description)
	deployment_area_description	TEXT,		-- List main areas of operation (ICES mooring_site_name)
	deployment_operator		TEXT,		-- Name of organisation which operates the deployment (ICES mooring_operator)
	deployment_summary_report	TEXT,		-- Published or web-based references that links to the deployment report (No ICES attribute for this normally, but inspired from cruise_summary_report)
	deployment_start_date		TIMESTAMP, 	-- Start date of deployment (ICES mooring_deployment_date)                
	deployment_end_date		TIMESTAMP,	-- End date of deployment (ICES mooring_retrieval_date)

	-- ICES geographic info on cruise/deployment
	deployment_northlimit		FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES mooring_northlimit)
	deployment_eastlimit		FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES mooring_eastlimit)
	deployment_southlimit		FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES mooring_southlimit)
	deployment_westlimit		FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES mooring_westlimit)
	deployment_uplimit		FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES mooring_uplimit)
	deployment_downlimit		FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES mooring_downlimit)
	deployment_units		TEXT, 		-- The units of unlabelled numeric values of deployment_northlimit, deployment_eastlimit, deployment_southlimit, deployment_westlimit (ICES mooring_units)
	deployment_zunits		TEXT,		-- The units of unlabelled numeric values of deployment_uplimit, deployment_downlimit (ICES mooring_zunits)
	deployment_projection		TEXT,		-- The name of the projection used with any parameters required (ICES mooring_projection)

       -- Additional specific ICES requirements for deployment
	                                                                                                                                                                                                                                                                                                        	
	deployment_comments		TEXT,		-- Free text field for relevant information not captured by other attributes (ICES mooring_comments)

	FOREIGN KEY (deployment_type_key) REFERENCES t_deployment_type(deployment_type_pkey)
);
COMMENT ON TABLE t_deployment is 'Non-cruise deployment (mooring, drifting buoy, glider, etc.) from which acoustic data were collected.';

CREATE TABLE t_mission_cruise
(
	mission_cruise_pkey 	SERIAL PRIMARY KEY,
	
	mission_key    		INT,
	cruise_key     		INT,

	mission_cruise_comments	TEXT, -- Free text field for relevant information not captured by other attributes

	FOREIGN KEY (mission_key) REFERENCES t_mission(mission_pkey),
	FOREIGN KEY (cruise_key) REFERENCES t_cruise(cruise_pkey)
);
COMMENT ON TABLE t_mission_cruise is 'Join table to manage the many-many relationship between t_mission and t_cruise.';

CREATE TABLE t_mission_deployment
(
	mission_deployment_pkey 	SERIAL PRIMARY KEY,

	mission_key    			INT,
	deployment_key     		INT,

	mission_deployment_comments	TEXT, -- Free text field for relevant information not captured by other attributes

	FOREIGN KEY (mission_key) REFERENCES t_mission(mission_pkey),
	FOREIGN KEY (deployment_key) REFERENCES t_deployment(deployment_pkey)
);
COMMENT ON TABLE t_mission_deployment is 'Join table to manage the many-many relationship between t_mission and t_deployment.';




/* ----- INSTRUMENTS GROUP -----

Introduction:
* Now some difference with ICES. 
* The ICES metadata convention suggests only an "instrument" table containing information for transducer, transceiver, and transducer setup (location such as hull/towbody/aos/etc. or orientation such as downward/upward/etc.).
* This means such table would have a new entry every time we use a different transceiver/transducer combination or change something in the instruments or deploy them on another location.
* Instead, we will have separate tables for physical entities ("transducer", "transceiver") and "setup" (acting as a look-up table), with the three combined having all attributes from the "instrument" category in the ICES metadata convention. 
* A script could be written to query those three tables to build one "instrument" table that follows exactly ICES.

Tables:
* A "transducer" table describing each (physical) transducer we possess;
* A "transceiver" table describing each (physical) transceiver we possess;
* A "setup" table describing each instance of a new setup (or alteration of existing setup) of a transducer/transceiver combo;
* A "software" table describing each instance of a new software install on a new computer (or updating to new version);
* A "calibration" table describing each instance of calibration performed;
* An "ancillary instrument" table
 
Controlled vocabulary tables:
* t_transducer_beam_type controlled vocabulary table for transducer_beam_type attribute in t_transducer.
* t_transducer_location_type controlled vocabulary table for transducer_location attribute in t_setup.
* t_transducer_orientation_type controlled vocabulary table for transducer_orientation attribute in t_setup.

Rules:
* Any data file contain several channels, so will reference SEVERAL entries in "transducer" and "transceiver". How do we link the transducer and transceiver for any particular file?
* One entry in calibration will be one calibration effort, which is done on several transducers and transceiver. Join tables to setup.
 
Join tables:
*
 
Notes:
* Even though we split the ICES "instrument" category into three tables, we still refer "ICES" to those attributes that are exactly as in the "instrument" category
* The three tables are mostly composed of the ICES attributes in the "instrument" category. Main differences are the three serial primary keys, the comments attribute now split in three (one for each table).
* Frequency is a feature of a transducer/transceiver combination, and thus a single attribute in the ICES "instrument" category, but here split in two separate attributes in the "transducer" and "transceiver" tables.
* Depth in "setup" is going to be a problem. That attribute in ICES category "instrument" is supposed to be "mean depth", but towbody/aos will have variable depth.
And even if located on 'Hull, keel' could very well have different depth values depending on where it's deployed. Perhaps we should move it to a data table (file? transect? ping?).
If we do so, then t_setup becomes a more simple, more straightforward look-up table.
* For now, setup, software and ancillary are linked to a ship ID, but what if it's a mooring install?

*/


CREATE TABLE t_transducer_beam_type
(
	transducer_beam_type_pkey	SERIAL PRIMARY KEY,
	transducer_beam_type		TEXT -- For example "single-beam, split-aperture". Following controlled vocabulary (ICES instrument_transducer_beam_type)
);
COMMENT ON TABLE t_transducer_beam_type is 'lookup table for transducer_beam_type attribute in t_transducer';
INSERT INTO t_transducer_beam_type (transducer_beam_type) VALUES ('Single-beam'),('Single-beam, split-aperture'),('Multibeam'),('Multibeam, split-aperture');

CREATE TABLE t_transducer
(
	transducer_pkey			SERIAL PRIMARY KEY,
	
	transducer_manufacturer		TEXT,	-- Transducer manufacturer (ICES instrument_transducer_manufacturer)
	transducer_model		TEXT,	-- Transducer model (ICES instrument_transducer_model)
	transducer_beam_type_key	INT,	-- For example "single-beam, split-aperture". Following controlled vocabulary in v_transducer_beam_type (ICES instrument_transducer_beam_type)
	transducer_serial 		TEXT,	-- Transducer serial number (ICES instrument_transducer_serial)
	transducer_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transducer_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
	transducer_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz
	transducer_psi			FLOAT,	-- Manufacturer specified transducer equivalent beam angle, expressed as 10*log10(psi), where psi has units of steradians (ICES instrument_transducer_psi)
	transducer_beam_angle_major	FLOAT,	-- Major beam opening, also referred to athwartship angle (ICES instrument_transducer_beam_angle_major)
	transducer_beam_angle_minor	FLOAT,	-- Minor beam opening, also referred to alongship angle (ICES instrument_transducer_beam_angle_minor)

	transducer_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)

	FOREIGN KEY (transducer_beam_type_key) REFERENCES t_transducer_beam_type(transducer_beam_type_pkey)
	UNIQUE(transducer_model,transducer_serial) ON CONFLICT IGNORE
	
);
COMMENT ON TABLE t_transducer is 'describes each (physical) transducer.';

CREATE TABLE t_transceiver
(
	transceiver_pkey 		SERIAL PRIMARY KEY,
	transceiver_manufacturer	TEXT,	-- Transceiver manufacturer (ICES instrument_transceiver_manufacturer)
	transceiver_model		TEXT,	-- Transceiver model (ICES instrument_transceiver_model)
	transceiver_serial 		TEXT,	-- Transceiver serial number (ICES instrument_transceiver_serial)
	transceiver_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transceiver_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
	transceiver_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz	
	transceiver_firmware 		TEXT,	-- Transceiver firmware version (ICES instrument_transceiver_firmware)
	transceiver_comments		TEXT	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
);
COMMENT ON TABLE t_transceiver is 'describes each (physical) transceiver.';

CREATE TABLE t_calibration
(
	calibration_pkey 		SERIAL PRIMARY KEY,
	
	calibration_date		TIMESTAMP,	-- Date of calibration (ICES)
	calibration_acquisition_method	TEXT,		-- Describe the method used to acquire calibration data (ICES)
	calibration_processing_method	TEXT, 		-- Describe method of processing that was used to generate calibration offsets (ICES)
	calibration_accuracy_estimate	TEXT, 		-- Estimate of calibration accuracy. Include a description and units so that it is clear what this estimate means (ICES)
	calibration_report		TEXT, 		-- URL or references to external documents which give a full account of calibration processing and results may be appropriate (ICES)
	
	calibration_comments		TEXT		-- Free text field for relevant information not captured by other attributes (ICES)
);
COMMENT ON TABLE t_calibration is 'Instances of calibration of a given setup.';

CREATE TABLE t_cruise_or_deployment
(
	cruise_or_deployment_pkey	SERIAL PRIMARY KEY,
	cruise_or_deployment		TEXT -- Cruise or Deployment
);
COMMENT ON TABLE t_cruise_or_deployment is 'lookup table for cruise_or_deployment attribute in t_setup';
INSERT INTO t_cruise_or_deployment (cruise_or_deployment) VALUES ('Cruise'),('Deployment');

CREATE TABLE t_platform_type
(
	platform_type_pkey	SERIAL PRIMARY KEY,
	platform_type		TEXT -- Hull, Towbody or AOS. NIWA vocabulary, doubles up a bit with ICES transducer_location_type
);
COMMENT ON TABLE t_platform_type is 'lookup table for platform_type attribute in t_setup.';
INSERT INTO t_platform_type (platform_type) VALUES ('Hull'),('Towbody'),('AOS');

CREATE TABLE t_transducer_location_type
(
	transducer_location_type_pkey	SERIAL PRIMARY KEY,
	transducer_location_type	TEXT -- Location of installed transducer. Following controlled vocabulary (ICES instrument_transducer_location)
);
COMMENT ON TABLE t_transducer_location_type is 'lookup table for transducer_location_type attribute in t_setup.';
INSERT INTO t_transducer_location_type (transducer_location_type) VALUES ('Hull, keel'),('Hull, lowered keel'),('Hull, blister'),('Hull, gondola'),('Towed, shallow'),('Towed, deep'),('Towed, deep, trawlnet attached'),('Ship, pole');

CREATE TABLE t_transducer_orientation_type
(
	transducer_orientation_type_pkey	SERIAL PRIMARY KEY,
	transducer_orientation_type		TEXT -- Direction perpendicular to the face of the transducer. Following controlled vocabulary (ICES instrument_transducer_orientation)
);
COMMENT ON TABLE t_transducer_orientation_type is 'lookup table for transducer_orientation attribute in t_setup.';
INSERT INTO t_transducer_orientation_type (transducer_orientation_type) VALUES ('Downward-looking'),('Upward-looking'),('Sideways-looking, forward'),('Sideways-looking, backward'),('Sideways-looking, port'),('Sideways-looking, starboard'),('Other');

CREATE TABLE t_setup
(
	setup_pkey				SERIAL PRIMARY KEY,

	-- Cruise or Deployment switch
	setup_cruise_or_deployment_key		INT, 		

	-- If cruise...
	setup_cruise_key			INT, 		-- Refers to attribute cruise_pkey in t_cruise
	setup_platform_type_key			INT, 		-- Hull, Towbody or AOS
	
	-- If deployment...
	setup_deployment_key			INT, 		-- Refers to attribute deployment_pkey in t_deployment

	-- Keys to instrument combo
	setup_transceiver_key			INT,		-- Link to transceiver pkey for this setup
	setup_transducer_key			INT,		-- Link to transducer pkey for this setup

	-- Installation and orientation
	setup_transducer_location_type_key	INT, 		-- Location of installed transducer. Following controlled vocabulary in v_transducer_location (ICES instrument_transducer_location)
	setup_transducer_location_x		FLOAT, 		-- 
	setup_transducer_location_y		FLOAT, 		-- 
	setup_transducer_location_z		FLOAT, 		-- 
	setup_transducer_depth			TEXT,		-- Mean depth of transducer face beneath the water surface (ICES instrument_transducer_depth)
	setup_transducer_orientation_type_key 	INT,		-- Direction perpendicular to the face of the transducer. Following controlled vocabulary in v_transducer_orientation (ICES instrument_transducer_orientation)
	setup_transducer_orientation_vx		FLOAT,		-- 
	setup_transducer_orientation_vy		FLOAT,		-- 
	setup_transducer_orientation_vz		FLOAT,		-- 

	-- Calibration
	setup_calibration_key			INT, 		--
	
	setup_comments				TEXT,		-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)

	FOREIGN KEY (setup_cruise_or_deployment_key) REFERENCES t_cruise_or_deployment(cruise_or_deployment_pkey),
	FOREIGN KEY (setup_platform_type_key) REFERENCES t_platform_type(platform_type_pkey),
	FOREIGN KEY (setup_transceiver_key) REFERENCES t_transceiver(transceiver_pkey),
	FOREIGN KEY (setup_transducer_key) REFERENCES t_transducer(transducer_pkey),
	FOREIGN KEY (setup_transducer_location_type_key) REFERENCES t_transducer_location_type(transducer_location_type_pkey),
	FOREIGN KEY (setup_transducer_orientation_type_key) REFERENCES t_transducer_orientation_type(transducer_orientation_type_pkey),
	FOREIGN KEY (setup_calibration_key) REFERENCES t_calibration(calibration_pkey)
);
COMMENT ON TABLE t_setup is 'Each setup (or alteration of existing setup) of a transducer/transceiver combination.';

CREATE TABLE t_software
(
	software_pkey		SERIAL PRIMARY KEY,
	
	software_manufacturer	TEXT,
	software_name		TEXT,
	software_version	TEXT,
	software_host		TEXT,
	software_install_date	TIMESTAMP,
	software_platform_type	INT, 		-- Ship or Mooring or ?
	software_platform_key	INT,		-- References the pkey from the appropriate platform table. e.g. if XXX_platform_type = "ship", then XXX_platform_key is the pkey in t_ship
	
	software_comments	TEXT
);
COMMENT ON TABLE t_software is 'Instances of new software install on a new computer (or updating to new version).';

CREATE TABLE t_ancillary
(
	ancillary_pkey		SERIAL PRIMARY KEY,
	
	ancillary_type		TEXT,	--
	ancillary_manufacturer	TEXT,	-- 
	ancillary_model		TEXT,	-- 
	ancillary_serial 	TEXT,	-- 
	ancillary_firmware 	TEXT,	-- 
	ancillary_platform_type	INT, 	-- Ship or Mooring or ?
	ancillary_platform_key	INT,	-- References the pkey from the appropriate platform table. e.g. if XXX_platform_type = "ship", then XXX_platform_key is the pkey in t_ship
	
	ancillary_comments	TEXT	-- 
);
COMMENT ON TABLE t_ancillary is 'Any other instruments - GPS, pitch roll sensor, anemometer, etc.';



/* ----- DATA GROUP -----

Introduction:
* The ICES metadata convention category "transect" only contains info about time (start/end) and space (XYZ) bounds for a "transect", and then "data" and "dataset" for the metadata of what looks like a final, processed data.
* What we need is one table listing the individual files recorded, and one table listing the "set of consecutive pings to be processed together whether they're a subset of the pings in one file, or span several consecutive files", which we should probably call "transect" to follow ICES, even though it might be confusing with our past use of "Transect" as a transect number field.
* We also need a table to manage the many-to-many relationships between files and transect

Tables:
* 

Controlled vocabulary tables:
* 

Rules:
* Every file instance was acquired with ONE software install, so direct link to t_software through foreign key.
* Every file instance contains SEVERAL channels, so need for a join table between t_file and t_setup.
* One transect can be on several files, while one file can contains several transects, so need for a join table between t_file and t_transect.

Join tables:
* 

Notes:
* Linking t_file and t_trip (and t_ship) is a many-to-one relationship so foreign key use possible. Although if acquired from a mooring, it is possible to have NO trip or ship associated to a file...
* By listing which transects are in which files, the t_file_transect join table allows extraction the identification of relevant files for a given transect. Then use the start and end times in relevant transect/files to find the exact bounds of transect data.
*/

CREATE TABLE t_file
(
	file_pkey   		SERIAL PRIMARY KEY,
	
	file_name		TEXT,	 	--
	file_path		TEXT, 		--
	file_start_time		TIMESTAMP,	--
	file_end_time		TIMESTAMP,	--
	file_software_key	INT, 		-- Software used to record the file
	file_cruise_key		INT, 		-- Cruise during which this file was recorded
	file_deployment_key	INT, 		-- Cruise during which this file was recorded
	
	file_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (file_software_key) REFERENCES t_software(software_pkey),
	FOREIGN KEY (file_cruise_key) REFERENCES t_cruise(cruise_pkey),
	FOREIGN KEY (file_deployment_key) REFERENCES t_deployment(deployment_pkey),	
	UNIQUE(file_path,file_name) ON CONFLICT REPLACE,
	
    CHECK (file_end_time>=file_start_time)
);
COMMENT ON TABLE t_file is 'Acoustic data files';


CREATE TABLE t_transect
(
	transect_pkey    		SERIAL PRIMARY KEY,
	
	transect_name			TEXT, 		-- Name of the transect (ICES)
	--transect_id			TEXT,		-- Identifier for the transect (ICES)/removed, same as transect_pkey
	transect_description		TEXT,		-- Description of the transect, its purpose, and main activity (ICES)/will be the same as "transect_type" for now
	transect_related_activity	TEXT,		-- Describe related activities that may occur on the transect (ICES)/should be "linked" to the transect_station
	transect_start_time		TIMESTAMP,	-- Start time of the transect  (ICES)
	transect_end_time		TIMESTAMP,	-- End time of the transect  (ICES)
	--transect_northlimit		FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES)
	--transect_eastlimit		FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES)
	--transect_southlimit		FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES)
	--transect_westlimit		FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES)
	--transect_uplimit		FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES)
	--transect_downlimit		FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES)
	--transect_units  		TEXT, 		-- The units of unlabelled numeric values of all latitude, longitude and north/east/south/westlimit attributes (ICES)
	--transect_zunits 		TEXT,		-- The units of unlabelled numeric values of all depth and up/downlimit attributes(ICES)
	--transect_projection 		TEXT,		-- The name of the projection used with any parameters required (ICES)
	
	-- Those are the formalized info attributes we actually need. Not in ICES
	transect_snapshot		INT, 		-- To identify time repeats. Typically for statistical purposes, in acoustic surveys
	transect_stratum		TEXT, 		-- To identify geographically different areas. Typically for statistical purposes, in trawl surveys 
	transect_station		TEXT, 		-- To identify separate targets. Typically station numbers in trawl survey, or marks in acoustic surveys 
	transect_type			TEXT, 		-- To identify categorically different data purposes, e.g. transit/steam/trawl/junk/test/etc. 
	transect_number			INT, 		-- To identify separate transects in a same snapshot/stratum/station/type

	-- last ICES field, the usual comments
	transect_comments		TEXT,		-- Free text field for relevant information not captured by other attributes (ICES)	
	UNIQUE(transect_snapshot,transect_stratum,transect_type,transect_number,transect_start_time,transect_end_time) ON CONFLICT REPLACE,
	CHECK (transect_end_time>=transect_start_time)
);
COMMENT ON TABLE t_transect is 'Acoustic data transects';

CREATE TABLE t_parameters
(
	parameters_pkey			SERIAL PRIMARY KEY,
	
	parameters_file_key		INT, 	-- File to which this parameters record applies
	parameters_pulse_mode		TEXT, 	-- CW/FM
	parameters_pulse_length		FLOAT, 	-- in seconds? applies to both CW/FM
	parameters_pulse_shape		TEXT,	-- square, cosine, 10%_cosine etc. applies to both CW/FM
	parameters_FM_pulse_type	TEXT,	-- linear up-sweep, linear down-sweep, exponential up-sweep, exponential down-sweep, etc.
	parameters_frequency_min	INT, 	-- see pulse type to see if upsweep or downsweep
	parameters_frequency_max	INT, 	-- see pulse type to see if upsweep or downsweep
	parameters_power		INT, 	-- in W?
	
	parameters_comments		TEXT, 	-- Free text field for relevant information not captured by other attributes	
	
	FOREIGN KEY (parameters_file_key) REFERENCES t_file(file_pkey)
);
COMMENT ON TABLE t_parameters is 'Acoustic data file parameters';

CREATE TABLE t_navigation
(
	navigation_pkey		SERIAL PRIMARY KEY,
	
	navigation_time		TIMESTAMP,	--
	navigation_latitude	FLOAT,		--
	navigation_longitude	FLOAT,		--
	navigation_depth 	FLOAT,		--
	navigation_file_key	INT,		-- Identifier of file for which this navigation data record is relevant
	
	navigation_comments	TEXT,	 	-- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (navigation_file_key) REFERENCES t_file(file_pkey),
	UNIQUE(navigation_time,navigation_file_key) ON CONFLICT REPLACE
);
COMMENT ON TABLE t_navigation is 'Acoustic data file navigation';

CREATE TABLE t_file_transect
(
	file_transect_pkey 	SERIAL PRIMARY KEY,
	
	file_key      		INT,
	transect_key    	INT,
	
	file_transect_comments	TEXT, -- Free text field for relevant information not captured by other attributes	
	
	FOREIGN KEY (file_key) REFERENCES t_file(file_pkey),
	FOREIGN KEY (transect_key) REFERENCES t_transect(transect_pkey),
	UNIQUE (file_key,transect_key) ON CONFLICT REPLACE
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
);
COMMENT ON TABLE t_file_setup is 'Join table to manage the many-many relationship between t_file and t_setup.';

CREATE TABLE t_file_ancillary
(
	file_ancillary_pkey 	SERIAL PRIMARY KEY,
	
	file_key      		INT,
	ancillary_key    	INT,
	file_ancillary_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	
	FOREIGN KEY (file_key) REFERENCES t_file(file_pkey),
	FOREIGN KEY (ancillary_key) REFERENCES t_ancillary(ancillary_pkey)
);
COMMENT ON TABLE t_file_ancillary is 'Join table to manage the many-many relationship between t_file and t_ancillary.';


--Create appropriate triggers
/* 
CREATE TRIGGER t_file_before_insert_trigger  BEFORE INSERT ON t_file
WHEN ((SELECT COUNT() FROM t_file f WHERE f.file_name IS NEW.file_name and f.file_end_time>=NEW.file_end_time)>0)
BEGIN
	 SELECT RAISE(FAIL, 'File already Exist') ;
 END;
 */

CREATE TRIGGER t_transect_after_insert_trigger 
AFTER INSERT ON t_transect 
BEGIN
	INSERT INTO t_file_transect ( transect_key, file_key )
	SELECT t.transect_pkey, f.file_pkey
		FROM t_transect t INNER JOIN t_file f ON NOT f.file_start_time>t.transect_end_time AND NOT f.file_end_time<t.transect_start_time
		WHERE t.transect_pkey = NEW.transect_pkey;
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
	DELETE FROM t_file_transect
	WHERE file_key = OLD.file_pkey;
END;
