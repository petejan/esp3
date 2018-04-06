% CREATE TABLE t_transceiver
% (
% 	transceiver_pkey 		SERIAL PRIMARY KEY,
% 	transceiver_manufacturer	TEXT,	-- Transceiver manufacturer (ICES instrument_transceiver_manufacturer)
% 	transceiver_model		TEXT,	-- Transceiver model (ICES instrument_transceiver_model)
% 	transceiver_serial 		TEXT,	-- Transceiver serial number (ICES instrument_transceiver_serial)
% 	transceiver_frequency_lower	INT,	-- For wide-band systems, lower bound of frequency range in kHz
% 	transceiver_frequency_nominal	INT,	-- Frequency of the transceiver/transceiver combination in kHz (ICES instrument_frequency)
% 	transceiver_frequency_upper	INT,	-- For wide-band systems, upper bound of frequency range in kHz	
% 	transceiver_firmware 		TEXT,	-- Transceiver firmware version (ICES instrument_transceiver_firmware)
% 	transceiver_comments		TEXT,	-- Free text field for relevant information not captured by other attributes (ICES instrument_comments)
%  UNIQUE(transceiver_model,transceiver_serial) ON CONFLICT IGNORE
%);
% COMMENT ON TABLE t_transceiver is 'describes each (physical) transceiver.';



function transceiver_pkey=add_transceiver_to_t_transceiver(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'transceiver_manufacturer','',@ischar);
addParameter(p,'transceiver_model','',@ischar);     
addParameter(p,'transceiver_serial','',@ischar);
addParameter(p,'transceiver_frequency_lower',[],@isnumeric);
addParameter(p,'transceiver_frequency_nominal',[],@isnumeric);
addParameter(p,'transceiver_frequency_upper',[],@isnumeric);
addParameter(p,'transceiver_firmware','',@ischar);
addParameter(p,'transceiver_comments','',@ischar);

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
dbconn.insert('t_transceiver',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'transceiver_comments');
[~,transceiver_pkey]=get_cols_from_table(ac_db_filename,'t_transceiver','input_struct',struct_in,'output_cols',{'transceiver_pkey'});