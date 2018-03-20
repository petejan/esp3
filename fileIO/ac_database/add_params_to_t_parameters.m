% CREATE TABLE t_parameters
% (
% 	t_parameters_id		INTEGER PRIMARY KEY AUTOINCREMENT,
% 	parameters_frequency	INT, 	--
% 	parameters_pulse_mode	TEXT, 	-- CW/FM
% 	parameters_pulse_length	FLOAT, 	--
% 	parameters_power	INT, 	--
% 	parameters_comments	TEXT 	-- Free text field for relevant information not captured by other attributes
% % );
% CREATE TABLE j_file_parameters
% (
% 	j_file_parameters_id 		INTEGER PRIMARY KEY AUTOINCREMENT,
% 	file_id      			INT,
% 	parameters_id    		INT,
% 	file_parameters_comments	TEXT, -- Free text field for relevant information not captured by other attributes
% 	FOREIGN KEY (file_id) REFERENCES t_file(t_file_id),
% 	FOREIGN KEY (parameters_id) REFERENCES t_parameters(t_parameters_id)
% );

function add_params_to_t_parameters(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'parameters_frequency',[],@isnumeric);
addParameter(p,'parameters_pulse_mode',[],@isnumeric);
addParameter(p,'parameters_pulse_length',[],@isnumeric);
addParameter(p,'parameters_power',[],@isnumeric);
addParameter(p,'parameters_comments',' ',@ischar);

parse(p,ac_db_filename,varargin{:});

fields=fieldnames(p.Results);

for ifi=1:numel(fields)
    if isempty(p.Results.(fields{ifi}))
        return;
    end
end

struct_in=p.Results;
struct_in=rmfield(struct_in,'ac_db_filename');
t=struct2table(struct_in);

dbconn=sqlite(ac_db_filename,'connect');  
dbconn.insert('t_parameters',fieldnames(struct_in),t);

dbconn.close();


