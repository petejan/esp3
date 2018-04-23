function transect_pkeys=add_transects_to_t_transect(ac_db_filename,ac_db_struct,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'ac_db_struct',@isstruct);

parse(p,ac_db_filename,ac_db_struct,varargin{:});


% CREATE TABLE t_transect
% (
% 	transect_pkey    		SERIAL PRIMARY KEY,
%
% 	transect_name			TEXT, 		-- Name of the transect (ICES)
% 	transect_description		TEXT,		-- Description of the transect, its purpose, and main activity (ICES)
% 	transect_related_activity	TEXT,		-- Describe related activities that may occur on the transect (ICES)
% 	transect_start_time		TIMESTAMP,	-- Start time of the transect  (ICES)
% 	transect_end_time		TIMESTAMP,	-- End time of the transect  (ICES)
%
% 	-- Those are the formalized info attributes we actually need. Not in ICES
% 	transect_snapshot		INT, 		-- To identify time repeats. Typically for statistical purposes, in acoustic surveys
% 	transect_stratum		TEXT, 		-- To identify geographically different areas. Typically for statistical purposes, in trawl surveys
% 	transect_station		TEXT, 		-- To identify separate targets. Typically station numbers in trawl survey, or marks in acoustic surveys
% 	transect_type			TEXT, 		-- To identify categorically different data purposes, e.g. transit/steam/trawl/junk/test/etc.
% 	transect_number			INT, 		-- To identify separate transects in a same snapshot/stratum/station/type
%
% 	-- last ICES field, the usual comments
% 	transect_comments		TEXT,		-- Free text field for relevant information not captured by other attributes (ICES)
% 	UNIQUE(transect_snapshot,transect_stratum,transect_station,transect_type,transect_number) ON CONFLICT REPLACE,
% 	CHECK (transect_end_time>=transect_start_time)
% );
% COMMENT ON TABLE t_transect is 'Acoustic data transects';


transect_pkeys=[];
if isempty(ac_db_struct.transect_snapshot)
    return;
end

t=struct2table(ac_db_struct);

datainsert_perso(ac_db_filename,'t_transect',fieldnames(ac_db_struct),t);


[~,transect_pkeys]=get_cols_from_table(ac_db_filename,'t_transect',...
    'input_struct',ac_db_struct,...
    'output_cols',{'transect_pkey'});

end