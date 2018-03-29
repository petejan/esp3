% CREATE TABLE t_transceiver
% (
% 	transceiver_pkey 		SERIAL PRIMARY KEY,
% 	transceiver_manufacturer	TEXT,	-- Transceiver manufacturer (ICES instrument_transceiver_manufacturer)
% 	transceiver_model		TEXT,	-- Transceiver model (ICES instrument_transceiver_model)
% 	transceiver_serial 		TEXT,	-- Transceiver serial number (ICES instrument_transceiver_serial)
% 	transceiver_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
% 	transceiver_frequency_nominal	INT,	-- Frequency of the transceiver/transducer combination in kHz (ICES instrument_frequency)
% 	transceiver_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz	
% 	transceiver_firmware 		TEXT,	-- Transceiver firmware version (ICES instrument_transceiver_firmware)
% 	transceiver_comments		TEXT	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
% );
% COMMENT ON TABLE t_transceiver is 'describes each (physical) transceiver.';