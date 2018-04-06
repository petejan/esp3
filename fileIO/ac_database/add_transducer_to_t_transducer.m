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


function transducer_pkey=add_transducer_to_t_transducer(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'transducer_manufacturer','',@ischar);
addParameter(p,'transducer_model','',@ischar);
addParameter(p,'transducer_beam_type_key',[],@isnumeric);
addParameter(p,'transducer_serial','',@ischar);
addParameter(p,'transducer_frequency_lower',[],@isnumeric);
addParameter(p,'transducer_frequency_nominal',[],@isnumeric);
addParameter(p,'transducer_frequency_upper',[],@isnumeric);
addParameter(p,'transducer_psi',[],@isnumeric);
addParameter(p,'transducer_beam_angle_major',[],@isnumeric);
addParameter(p,'transducer_beam_angle_minor',[],@isnumeric);
addParameter(p,'transducer_comments','',@ischar);

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
dbconn.insert('t_transducer',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'transducer_comments');
[~,transducer_pkey]=get_cols_from_table(ac_db_filename,'t_transducer','input_struct',struct_in,'output_cols',{'transducer_pkey'});