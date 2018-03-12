/* GENERAL INTRODUCTION AND NOTES:

* This text file creates the content tables of the acoustic database in psql.
* It follows as much as possible the ICES metadata convention, augmented for NIWA needs.
* One-to-many relationships will be formalized using a foreign key in the table on the many side referencing the corresponding entry in the table on the one side.
* A table starting in "t_" is a "regular" table for real entities.
* A table starting in "v_" is a look-up table for a controlled vocabulary, usually to follow ICES metadata convention and follows below template:

CREATE TABLE v_XXX
(	
	v_XXX_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	XXX		TEXT -- Description following controlled vocabulary (modified from ICES)
);

with a foreign key in the parent table following the template:
FOREIGN KEY (XXX) REFERENCES v_XXX(v_XXX_id)

* A table starting in "j_" is a join table to manage many-to-many relationships. Convention: j_XXX_YYY is the join table to manage many-to-many relationship between tables t_XXX and t_YYY, and follows below template:

CREATE TABLE j_XXX_YYY
(
	j_XXX_YYY_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
	XXX_id    		INT,
	YYY_id      		INT,
	XXX_YYY_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (XXX_id) REFERENCES t_XXX(t_XXX_id),
	FOREIGN KEY (YYY_id) REFERENCES t_YYY(t_YYY_id)
);

* The database is organized in three general groups of tables:
1. A group of tables related to the MISSION
2. A group of tables related to the INSTRUMENT
3. A group of tables related to the DATA

*/


/* MISSION GROUP

Introduction:
* As per ICES metadata conventions, we have a group of tables to describe the project, vessel, voyages, etc.

Tables:
* A "mission" table describing each mission/project for which acoustic data were collected;
* A "cruise" table describing each cruise/voyage/trip during which acoustic data were collected;
* A "ship" table describing each ship/vessel from which acoustic data were collected;
* A "mooring" table describing each mooring from which acoustic data were collected;

Controlled vocabulary tables:
* v_mission_platform controlled vocabulary table for mission_platform_name attribute in t_mission.
* v_ship_type controlled vocabulary table for ship_type_name attribute in t_ship.

Rules:
* Any data file will reference ONE entry in a "mission" table.
* Any data file acquired from a ship will reference ONE entry in the "ship" table AND ONE entry in the "cruise" table.
* Any data file acquired from a mooring will reference ONE entry in the "mooring" table. 

Join tables:
* One join table to manage the mission, cruise, ship and mooring relationships?

Notes:
* The "mission", "ship", "cruise" and "mooring" tables follow exactly the ICES categories with the same name. Only serial primary keys were added.
*/
CREATE TABLE v_mission_platform
(	
	v_mission_platform_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	mission_platform	TEXT -- Platform type following controlled vocabulary (modified from ICES)
);

INSERT INTO v_mission_platform (mission_platform) VALUES ('Ship, research'),('Ship, fishing'),('Ship, other'),('Buoy, moored'),('Buoy, drifting'),('Glider'),('Underwater vehicle, autonomous, motorized'),('Underwater vehicle, towed'),('Underwater vehicle, autonomous, glider');

CREATE TABLE v_ship_type
(	
	v_ship_type_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	ship_type	TEXT -- Describe type of ship that is hosting the acoustic instrumentation following controlled vocabulary (modified from ICES)
);

INSERT INTO v_ship_type (ship_type) VALUES ('Research'),('Fishing'),('Other');

CREATE TABLE t_mission
(
	t_mission_id 			INTEGER PRIMARY KEY AUTOINCREMENT,
	mission_name 			TEXT, 		-- Name of mission (ICES)
	mission_abstract 		TEXT, 		-- Text description of the mission, its purpose, scientific objectives and area of operation (ICES)
	mission_start_date 		TIMESTAMP,	-- Start date and time of the mission (ICES)
	mission_end_date 		TIMESTAMP,	-- End date and time of the mission (ICES)
	principal_investigator 		TEXT,		-- Name of the principal investigator in charge of the mission (ICES)
	principal_investigator_email	TEXT,		-- Principal investigator e-mail address (ICES)
	institution 			TEXT,		-- Name of the institute, facility, or company where the original data were produced (ICES)
	data_centre 			TEXT,		-- Data centre in charge of the data management or party who distributed the resource (ICES)
	data_centre_email 		TEXT,		-- Data centre contact e-mail address (ICES)
	mission_id			TEXT, 		-- ID code of mission (ICES) 
	mission_platform	 	INT,		-- Platform type. See the lookup table v_mission_platform (modified from ICES)
	creator				TEXT,		-- Entity primarily responsible for making the resource (ICES)
	contributor			TEXT,		-- Entity responsible for making contributions to the resource (ICES)
	mission_comments		TEXT,		-- Free text fields for relevant information not captured by other attributes (ICES)
	FOREIGN KEY (mission_platform) REFERENCES v_mission_platform(v_mission_platform_id)
);

CREATE TABLE t_ship
(
	t_ship_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	ship_name 		TEXT, 	-- Name of the ship (ICES)
	ship_type		INT,	-- Describe type of ship that is hosting the acoustic instrumentation. See the lookup table v_ship_type (modified from ICES)
	ship_code		TEXT,	-- For example, in-house code associated with ship (ICES)
	ship_platform_code	TEXT, 	-- ICES database of known ships (ICES)
	ship_platform_class	TEXT,	-- ICES controlled vocabulary for platform class (ICES)
	ship_callsign		TEXT,	-- Ship call sign (ICES)
	ship_alt_callsign	TEXT,	-- Alternative call sign if the ship has more than one (ICES)
	ship_IMO		TEXT,	-- Ship's International Maritime Organization ship identification number (ICES)
	ship_operator		TEXT,	-- Name of organization of company which operates the ship (ICES)
	ship_length		FLOAT,	-- Overall length of the ship (m) (ICES)
	ship_breadth		FLOAT,	-- The width of the ship at its widest point (m) (ICES)
	ship_tonnage		FLOAT,	-- Gross tonnage of the ship (t) (ICES)
	ship_engine_power	FLOAT,	-- The total power available for ship propulsion (ICES)
	ship_noise_design	TEXT,	-- For example, ICES 209 compliant (Mitson, 1995). Otherwise description of noise performance of the ship (ICES)
	ship_aknowledgement	TEXT,	-- Any users (include re-packagers) of these data are required to clearly acknowledge the source of the material in this format (ICES)
	ship_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES)
	FOREIGN KEY (ship_type) REFERENCES v_ship_type(v_ship_type_id)
);

CREATE TABLE t_mooring
(
	t_mooring_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	mooring_description	TEXT,		-- Describe type of mooring that is hosting the acoustic instrumentation (ICES)
	mooring_depth		FLOAT,		-- Seabed depth at mooring site (ICES)
	mooring_northlimit	FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES)
	mooring_eastlimit	FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES)
	mooring_southlimit	FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES)
	mooring_westlimit	FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES)
	mooring_uplimit		FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES)
	mooring_downlimit	FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES)
	mooring_units		TEXT, 		-- The units of unlabelled numeric values of mooring_northlimit, mooring_eastlimit, mooring_southlimit, mooring_westlimit (ICES)
	mooring_zunits		TEXT,		-- The units of unlabelled numeric values of mooring_uplimit, mooring_downlimit (ICES)
	mooring_projection	TEXT,		-- The name of the projection used with any parameters required (ICES)
	mooring_deployment_date	TIMESTAMP,	-- Start time of mooring deployment (ICES)
	mooring_retrieval_date	TIMESTAMP,	-- ? (ICES)
	mooring_code		TEXT,		-- e.g. mooring ID (ICES)
	mooring_site_name	TEXT,		-- e.g. name of location where mooring is deployed (ICES)
	mooring_operator	TEXT,		-- Name of organisation which operates the mooring (ICES)
	mooring_mission_id	INT,		-- Mission for which this mooring was deployed
	mooring_comments	TEXT,		-- Free text field for relevant information not captured by other attributes (ICES)
	FOREIGN KEY (mooring_mission_id) REFERENCES t_mission(t_mission_id)
);

CREATE TABLE t_cruise
(
	t_cruise_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	cruise_name		TEXT,		-- Formal name of cruise as recorded by cruise documentation or institutional data centre (ICES)
	cruise_description	TEXT,		-- Free text field to describe the cruise (ICES)
	cruise_summary_report	TEXT,		-- Published or web-based references that links to the cruise report (ICES)
	cruise_area_description	TEXT,		-- List main areas of operation (ICES)
	cruise_start_date	TIMESTAMP, 	-- Start date of cruise (ICES)
	cruise_end_date		TIMESTAMP,	-- End date of cruise (ICES)
	cruise_id		TEXT, 		-- Cruise ID where one exists (ICES). Use NIWA voyage code here?
	cruise_northlimit	FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES)
	cruise_eastlimit	FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES)
	cruise_southlimit	FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES)
	cruise_westlimit	FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES)
	cruise_uplimit		FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES)
	cruise_downlimit	FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES)
	cruise_units		TEXT, 		-- The units of unlabelled numeric values of cruise_northlimit, cruise_eastlimit, cruise_southlimit, cruise_westlimit (ICES)
	cruise_zunits		TEXT,		-- The units of unlabelled numeric values of cruise_uplimit, cruise_downlimit (ICES)
	cruise_projection	TEXT,		-- The name of the projection used with any parameters required (ICES)
	cruise_start_port	TEXT,		-- Commonly used name for the port where cruise started (ICES)
	cruise_end_port		TEXT,		-- Commonly used name for the port where cruise ended (ICES)
	cruise_start_BODC_code	TEXT,		-- Name of port from where cruise started (ICES)
	cruise_end_BODC_code	TEXT,		-- Name of port from where cruise ended (ICES)
	cruise_ship_id		INT,		-- ID of ship used in cruise
	cruise_comments		TEXT,		-- Free text field for relevant information not captured by other attributes (ICES)
	FOREIGN KEY (cruise_ship_id) REFERENCES t_ship(t_ship_id)
);

CREATE TABLE j_mission_cruise
(
	j_mission_cruise_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
	mission_id    		INT,
	cruise_id      		INT,
	mission_cruise_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (mission_id) REFERENCES t_mission(t_mission_id),
	FOREIGN KEY (cruise_id) REFERENCES t_cruise(t_cruise_id)
);





/* INSTRUMENT GROUP

Introduction:
* Now some difference with ICES. 
* The ICES metadata convention suggests only an "instrument" table containing information for transducer, transceiver, and transducer mounting (location such as hull/towbody/aos/etc. or orientation such as downward/upward/etc.).
* This means such table would have a new entry every time we use a different transceiver/transducer combination or change something in the instruments or deploy them on another location.
* Instead, we will have separate tables for physical entities ("transducer", "transceiver") and "mounting" (acting as a look-up table), with the three combined having all attributes from the "instrument" category in the ICES metadata convention. 
* A script could be written to query those three tables to build one "instrument" table that follows exactly ICES.

Tables:
* A "transducer" table describing each (physical) transducer we possess;
* A "transceiver" table describing each (physical) transceiver we possess;
* A "mounting" table describing each instance of a new setup (or alteration of existing setup) of a transducer/transceiver combo;
* A "software" table describing each instance of a new software install on a new computer (or updating to new version);
* A "calibration" table describing each instance of calibration performed;
* An "ancillary instrument" table
 
Controlled vocabulary tables:
* v_transducer_beam_type controlled vocabulary table for transducer_beam_type attribute in t_transducer.
* v_transducer_location controlled vocabulary table for transducer_location attribute in t_mounting.
* v_transducer_orientation controlled vocabulary table for transducer_orientation attribute in t_mounting.

Rules:
* Any data file contain several channels, so will reference SEVERAL entries in "transducer" and "transceiver". How do we link the transducer and transceiver for any particular file?
* One entry in calibration will be one calibration effort, which is done on several transducers and transceiver. Join tables to setup.
 
Join tables:
*
 
Notes:
* Even though we split the ICES "instrument" category into three tables, we still refer "ICES" to those attributes that are exactly as in the "instrument" category
* The three tables are mostly composed of the ICES attributes in the "instrument" category. Main differences are the three serial primary keys, the comments attribute now split in three (one for each table).
* Frequency is a feature of a transducer/transceiver combination, and thus a single attribute in the ICES "instrument" category, but here split in two separate attributes in the "transducer" and "transceiver" tables.
* Depth in "mounting" is going to be a problem. That attribute in ICES category "instrument" is supposed to be "mean depth", but towbody/aos will have variable depth.
And even if located on 'Hull, keel' could very well have different depth values depending on where it's deployed. Perhaps we should move it to a data table (file? transect? ping?).
If we do so, then t_mounting becomes a more simple, more straightforward look-up table.
* For now, mounting, software and ancillary_instrument are linked to a ship ID, but what if it's a mooring install?

*/


CREATE TABLE v_transducer_beam_type
(
	v_transducer_beam_type_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	transducer_beam_type		TEXT -- For example "single-beam, split-aperture". Following controlled vocabulary (modified from ICES instrument_transducer_beam_type)
);

INSERT INTO v_transducer_beam_type (transducer_beam_type) VALUES ('Single-beam'),('Single-beam, split-aperture'),('Multibeam'),('Multibeam, split-aperture');

CREATE TABLE v_transducer_location_type
(
	v_transducer_location_type_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	transducer_location_type	TEXT -- Location of installed transducer. Following controlled vocabulary (modified from ICES instrument_transducer_location)
);

INSERT INTO v_transducer_location_type (transducer_location_type) VALUES ('Hull, keel'),('Hull, lowered keel'),('Hull, blister'),('Hull, gondola'),('Towed, shallow'),('Towed, deep'),('Towed, deep, trawlnet attached'),('Ship, pole');

CREATE TABLE v_transducer_orientation_type
(
	v_transducer_orientation_type_id	INTEGER PRIMARY KEY AUTOINCREMENT,
	transducer_orientation_type		TEXT -- Direction perpendicular to the face of the transducer. Following controlled vocabulary (modified from ICES instrument_transducer_orientation)
);

INSERT INTO v_transducer_orientation_type (transducer_orientation_type) VALUES ('Downward-looking'),('Upward-looking'),('Sideways-looking, forward'),('Sideways-looking, backward'),('Sideways-looking, port'),('Sideways-looking, starboard'),('Other');

CREATE TABLE t_transducer
(
	t_transducer_id			INTEGER PRIMARY KEY AUTOINCREMENT,
	transducer_manufacturer		TEXT,	-- Transducer manufacturer (modified from ICES instrument_transducer_manufacturer)
	transducer_model		TEXT,	-- Transducer model (modified from ICES instrument_transducer_model)
	transducer_beam_type		INT,	-- For example "single-beam, split-aperture". Following controlled vocabulary in v_transducer_beam_type (modified from ICES instrument_transducer_beam_type)
	transducer_serial 		TEXT,	-- Transducer serial number (modified from ICES instrument_transducer_serial)
	transducer_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transducer_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (modified from ICES instrument_frequency)
	transducer_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz
	transducer_psi			FLOAT,	-- Manufacturer specified transducer equivalent beam angle, expressed as 10*log10(psi), where psi has units of steradians (modified from ICES instrument_transducer_psi)
	transducer_beam_angle_major	FLOAT,	-- Major beam opening, also referred to athwartship angle (modified from ICES instrument_transducer_beam_angle_major)
	transducer_beam_angle_minor	FLOAT,	-- Minor beam opening, also referred to alongship angle (modified from ICES instrument_transducer_beam_angle_minor)
	transducer_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (modified from ICES instrument_comments)
	FOREIGN KEY (transducer_beam_type) REFERENCES v_transducer_beam_type(v_transducer_beam_type_id)
);

CREATE TABLE t_transceiver
(
	t_transceiver_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	transceiver_manufacturer	TEXT,	-- Transceiver manufacturer (modified from ICES instrument_transceiver_manufacturer)
	transceiver_model		TEXT,	-- Transceiver model (modified from ICES instrument_transceiver_model)
	transceiver_serial 		TEXT,	-- Transceiver serial number (modified from ICES instrument_transceiver_serial)
	transceiver_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
	transceiver_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (modified from ICES instrument_frequency)
	transceiver_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz	
	transceiver_firmware 		TEXT,	-- Transceiver firmware version (modified from ICES instrument_transceiver_firmware)
	transceiver_comments		TEXT	-- Free text field for relevant information not captured by other attributes (modified from ICES instrument_comments)
);

CREATE TABLE t_mounting
(	
	t_mounting_id				INTEGER PRIMARY KEY AUTOINCREMENT,
	mounting_date				TIMESTAMP, 	-- Date of mounting or mounting alteration
	mounting_ship_id			INT,		-- If mounted on ship (location_type = hull), specify which ship as location values become relevant
	mounting_transceiver_id			INT,		-- Link to transceiver ID for this mounting
	mounting_transducer_id			INT,		-- Link to transducer ID for this mounting
	mounting_transducer_location_type	INT, 		-- Location of installed transducer. Following controlled vocabulary in v_transducer_location (modified from ICES instrument_transducer_location)
	mounting_transducer_location_x		FLOAT, 		-- 
	mounting_transducer_location_y		FLOAT, 		-- 
	mounting_transducer_location_z		FLOAT, 		-- 
	mounting_transducer_depth		TEXT,		-- Mean depth of transducer face beneath the water surface (modified from ICES instrument_transducer_depth)
	mounting_transducer_orientation_type	INT,		-- Direction perpendicular to the face of the transducer. Following controlled vocabulary in v_transducer_orientation (modified from ICES instrument_transducer_orientation)
	mounting_transducer_orientation_vx	FLOAT,		-- 
	mounting_transducer_orientation_vy	FLOAT,		-- 
	mounting_transducer_orientation_vz	FLOAT,		-- 
	mounting_comments			TEXT,		-- Free text field for relevant information not captured by other attributes (modified from ICES instrument_comments)
	FOREIGN KEY (mounting_ship_id) REFERENCES t_ship(t_ship_id),
	FOREIGN KEY (mounting_transceiver_id) REFERENCES t_transceiver(t_transceiver_id),
	FOREIGN KEY (mounting_transducer_id) REFERENCES t_transducer(t_transducer_id),
	FOREIGN KEY (mounting_transducer_location_type) REFERENCES v_transducer_location_type(v_transducer_location_type_id),
	FOREIGN KEY (mounting_transducer_orientation_type) REFERENCES v_transducer_orientation_type(v_transducer_orientation_type_id)
);

CREATE TABLE t_calibration
(
	t_calibration_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	calibration_date		TIMESTAMP,	-- Date of calibration (ICES)
	calibration_acquisition_method	TEXT,		-- Describe the method used to acquire calibration data (ICES)
	calibration_processing_method	TEXT, 		-- Describe method of processing that was used to generate calibration offsets (ICES)
	calibration_accuracy_estimate	TEXT, 		-- Estimate of calibration accuracy. Include a description and units so that it is clear what this estimate means (ICES)
	calibration_report		TEXT, 		-- URL or references to external documents which give a full account of calibration processing and results may be appropriate (ICES)
	calibration_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes (ICES)
	calibration_mounting_id		INT,		-- Links to mounting ID
	FOREIGN KEY (calibration_mounting_id) REFERENCES t_mounting(t_mounting_id)
);

CREATE TABLE t_software
(
	t_software_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	software_manufacturer	TEXT,
	software_name		TEXT,
	software_version	TEXT,
	software_host		TEXT,
	software_install_date	TIMESTAMP,
	software_ship_id	INT,		-- If installed on ship, specify which ship
	software_comments	TEXT,
	FOREIGN KEY (software_ship_id) REFERENCES t_ship(t_ship_id)
);

CREATE TABLE t_ancillary_instrument -- Modified from ICES category "Ancillary instrumentation"
(
	t_ancillary_instrument_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	ancillary_instrument_type		TEXT,	--
	ancillary_instrument_manufacturer	TEXT,	-- 
	ancillary_instrument_model		TEXT,	-- 
	ancillary_instrument_serial 		TEXT,	-- 
	ancillary_instrument_firmware 		TEXT,	-- 
	ancillary_instrument_ship_id		INT,	-- If installed on ship, specify which ship
	ancillary_instrument_comments		TEXT,	-- 
	FOREIGN KEY (ancillary_instrument_ship_id) REFERENCES t_ship(t_ship_id)
);




/* DATA GROUP

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
* Every file instance contains SEVERAL channels, so need for a join table between t_file and t_mounting.
* One transect can be on several files, while one file can contains several transects, so need for a join table between t_file and t_transect.

Join tables:
* 

Notes:
* Linking t_file and t_trip (and t_ship) is a many-to-one relationship so foreign key use possible. Although if acquired from a mooring, it is possible to have NO trip or ship associated to a file...
* By listing which transects are in which files, the t_file_transect join table allows extraction the identification of relevant files for a given transect. Then use the start and end times in relevant transect/files to find the exact bounds of transect data.
*/


CREATE TABLE t_file
(
	t_file_id    		INTEGER PRIMARY KEY AUTOINCREMENT,
	file_name		TEXT,	 	--
	file_path		TEXT, 		--
	file_start_time		TIMESTAMP,	--
	file_end_time		TIMESTAMP,	--
	file_software_id	INT, 		-- Software used to record the file
	file_cruise_id		INT, 		-- Cruise during which this file was recorded
	file_mooring_id		INT, 		-- Cruise during which this file was recorded
	file_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (file_software_id) REFERENCES t_software(t_software_id),
	FOREIGN KEY (file_cruise_id) REFERENCES t_cruise(t_cruise_id),
	FOREIGN KEY (file_mooring_id) REFERENCES t_mooring(t_mooring_id)
);

CREATE TABLE t_transect
(
	t_transect_id    		INTEGER PRIMARY KEY AUTOINCREMENT,
	transect_name			TEXT, 		-- Name of the transect (ICES)
	transect_id			TEXT,		-- Identifier for the transect (ICES)
	transect_description		TEXT,		-- Description of the transect, its purpose, and main activity (ICES)
	transect_related_activity	TEXT,		-- Describe related activities that may occur on the transect (ICES)
	transect_start_time		TIMESTAMP,	-- Start time of the transect  (ICES)
	transect_end_time		TIMESTAMP,	-- End time of the transect  (ICES)
	transect_northlimit		FLOAT,		-- The constant coordinate for the northernmost face or edge (ICES)
	transect_eastlimit		FLOAT,		-- The constant coordinate for the easternmost face or edge (ICES)
	transect_southlimit		FLOAT,		-- The constant coordinate for the southernmost face or edge (ICES)
	transect_westlimit		FLOAT,		-- The constant coordinate for the westernmost face or edge (ICES)
	transect_uplimit		FLOAT,		-- The constant coordinate for the uppermost face or edge in the vertical, z, dimension (ICES)
	transect_downlimit		FLOAT,		-- The constant coordinate for the lowermost face or edge in the vertical, z, dimension (ICES)
	transect_units  		TEXT, 		-- The units of unlabelled numeric values of all latitude, longitude and north/east/south/westlimit attributes (ICES)
	transect_zunits 		TEXT,		-- The units of unlabelled numeric values of all depth and up/downlimit attributes(ICES)
	transect_projection 		TEXT,		-- The name of the projection used with any parameters required (ICES)
	
	-- Those are the formalized info attributes we actually need. Not in ICES
	transect_snapshot		INT, 		-- To identify time repeats. Typically for statistical purposes, in acoustic surveys
	transect_stratum		TEXT, 		-- To identify geographically different areas. Typically for statistical purposes, in trawl surveys
	transect_station		TEXT, 		-- To identify separate targets. Typically station numbers in trawl survey, or marks in acoustic surveys
	transect_type			TEXT, 		-- To identify categorically different data purposes, e.g. transit/steam/trawl/junk/test/etc.
	transect_number			INT, 		-- To identify separate transects in a same snapshot/stratum/station/type

	-- last ICES field, the usual comments
	transect_comments		TEXT 		-- Free text field for relevant information not captured by other attributes (ICES)	
);

CREATE TABLE t_parameters
(
	t_parameters_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	parameters_frequency	INT, 	--
	parameters_pulse_mode	TEXT, 	-- CW/FM
	parameters_pulse_length	FLOAT, 	--
	parameters_power	INT, 	--
	parameters_comments	TEXT 	-- Free text field for relevant information not captured by other attributes	
);

CREATE TABLE t_navigation
(
	t_navigation_id		INTEGER PRIMARY KEY AUTOINCREMENT,
	navigation_time		TIMESTAMP,	--
	navigation_latitude	FLOAT,		--
	navigation_longitude	FLOAT,		--
	navigation_depth 	FLOAT,		--
	navigation_file_id	INT,		-- Identifier of file for which this navigation data record is relevant
	navigation_comments	TEXT,	 	-- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (navigation_file_id) REFERENCES t_file(t_file_id)
);

CREATE TABLE j_file_transect
(
	j_file_transect_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
	file_id      		INT,
	transect_id    		INT,
	file_transect_comments	TEXT, -- Free text field for relevant information not captured by other attributes	
	FOREIGN KEY (file_id) REFERENCES t_file(t_file_id),
	FOREIGN KEY (transect_id) REFERENCES t_transect(t_transect_id)
);

CREATE TABLE j_file_mounting
(
	j_file_mounting_id 	INTEGER PRIMARY KEY AUTOINCREMENT,
	file_id      		INT,
	mounting_id    		INT,
	file_mounting_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (file_id) REFERENCES t_file(t_file_id),
	FOREIGN KEY (mounting_id) REFERENCES t_mounting(t_mounting_id)
);

CREATE TABLE j_file_ancillary_instrument
(
	j_file_ancillary_instrument_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
	file_id      				INT,
	ancillary_instrument_id    		INT,
	file_ancillary_instrument_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (file_id) REFERENCES t_file(t_file_id),
	FOREIGN KEY (ancillary_instrument_id) REFERENCES t_ancillary_instrument(t_ancillary_instrument_id)
);

CREATE TABLE j_file_parameters
(
	j_file_parameters_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
	file_id      			INT,
	parameters_id    		INT,
	file_parameters_comments	TEXT, -- Free text field for relevant information not captured by other attributes
	FOREIGN KEY (file_id) REFERENCES t_file(t_file_id),
	FOREIGN KEY (parameters_id) REFERENCES t_parameters(t_parameters_id)
);