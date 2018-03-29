% 
% CREATE TABLE t_transducer
% (
% 	transducer_pkey			SERIAL PRIMARY KEY,
% 	
% 	transducer_manufacturer		TEXT,	-- Transducer manufacturer (ICES instrument_transducer_manufacturer)
% 	transducer_model		TEXT,	-- Transducer model (ICES instrument_transducer_model)
% 	transducer_beam_type_key	INT,	-- For example "single-beam, split-aperture". Following controlled vocabulary in v_transducer_beam_type (ICES instrument_transducer_beam_type)
% 	transducer_serial 		TEXT,	-- Transducer serial number (ICES instrument_transducer_serial)
% 	transducer_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
% 	transducer_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
% 	transducer_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz
% 	transducer_psi			FLOAT,	-- Manufacturer specified transducer equivalent beam angle, expressed as 10*log10(psi), where psi has units of steradians (ICES instrument_transducer_psi)
% 	transducer_beam_angle_major	FLOAT,	-- Major beam opening, also referred to athwartship angle (ICES instrument_transducer_beam_angle_major)
% 	transducer_beam_angle_minor	FLOAT,	-- Minor beam opening, also referred to alongship angle (ICES instrument_transducer_beam_angle_minor)
% 
% 	transducer_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
% 
% 	FOREIGN KEY (transducer_beam_type_key) REFERENCES t_transducer_beam_type(transducer_beam_type_pkey)
% 	UNIQUE(transducer_model,transducer_serial) ON CONFLICT IGNORE
% 	
% );
% COMMENT ON TABLE t_transducer is 'describes each (physical) transducer.';
% 

