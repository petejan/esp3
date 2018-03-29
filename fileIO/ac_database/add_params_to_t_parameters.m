% CREATE TABLE t_parameters
% (
% 	parameters_pkey			SERIAL PRIMARY KEY,
% 	
% 	parameters_pulse_mode		TEXT, 	-- CW/FM
% 	parameters_pulse_length		FLOAT, 	-- in seconds? applies to both CW/FM
% 	parameters_pulse_shape		TEXT,	-- square, cosine, 10%_cosine etc. applies to both CW/FM
% 	parameters_FM_pulse_type	TEXT,	-- linear up-sweep, linear down-sweep, exponential up-sweep, exponential down-sweep, etc.
% 	parameters_frequency_min	INT, 	-- see pulse type to see if upsweep or downsweep
% 	parameters_frequency_max	INT, 	-- see pulse type to see if upsweep or downsweep
% 	parameters_power		INT, 	-- in W?
% 	
% 	parameters_comments		TEXT, 	-- Free text field for relevant information not captured by other attributes	
% 	
% );
% COMMENT ON TABLE t_parameters is 'Acoustic data acquisition parameters';

function parameters_pkey=add_params_to_t_parameters(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'parameters_pulse_mode','CW',@ischar);
addParameter(p,'parameters_pulse_length',0,@isnumeric);
addParameter(p,'parameters_pulse_slope',0,@isnumeric);
addParameter(p,'parameters_FM_pulse_type','',@ischar);
addParameter(p,'parameters_frequency_min',0,@isnumeric);
addParameter(p,'parameters_frequency_max',0,@isnumeric);
addParameter(p,'parameters_power',0,@isnumeric);
addParameter(p,'parameters_comments','',@ischar);

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
dbconn.insert('t_parameters',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'parameters_comments');
[~,parameters_pkey]=get_cols_from_table(ac_db_filename,'t_parameters','input_struct',struct_in,'output_cols',{'parameters_pkey'});





