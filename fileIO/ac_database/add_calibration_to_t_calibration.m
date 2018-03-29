% CREATE TABLE t_calibration
% (
% 	calibration_pkey 		SERIAL PRIMARY KEY,
% 	
% 	calibration_date		TIMESTAMP,	-- Date of calibration (ICES)
% 	calibration_acquisition_method	TEXT,		-- Describe the method used to acquire calibration data (ICES)
% 	calibration_processing_method	TEXT, 		-- Describe method of processing that was used to generate calibration offsets (ICES)
% 	calibration_accuracy_estimate	TEXT, 		-- Estimate of calibration accuracy. Include a description and units so that it is clear what this estimate means (ICES)
% 	calibration_report		TEXT, 		-- URL or references to external documents which give a full account of calibration processing and results may be appropriate (ICES)
% 	
% 	calibration_comments		TEXT		-- Free text field for relevant information not captured by other attributes (ICES)
% );
% COMMENT ON TABLE t_calibration is 'Instances of calibration of a given setup.';

function calibration_pkey=add_calibration_to_t_calibration(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'calibration_date','',@ischar);
addParameter(p,'calibration_acquisition_method','',@ischar);
addParameter(p,'calibration_processing_method','',@ischar);
addParameter(p,'calibration_accuracy_estimate','',@ischar);
addParameter(p,'calibration_report','',@ischar);
addParameter(p,'calibration_comments','',@ischar);

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
dbconn.insert('t_calibration',fieldnames(struct_in),t);

dbconn.close();

struct_in=rmfield(struct_in,'calibration_comments');
[~,calibration_pkey]=get_cols_from_table(ac_db_filename,'t_calibration','input_struct',struct_in,'output_cols',{'calibration_pkey'});
