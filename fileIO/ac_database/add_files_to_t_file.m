function file_pkeys=add_files_to_t_file(ac_db_filename,files,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'files',@(x) ischar(x)||iscell(x));
addParameter(p,'file_path',[]);
addParameter(p,'file_software_id',[]);
addParameter(p,'file_cruise_key',[]);
addParameter(p,'file_deployment_key',[]);
addParameter(p,'file_comments',[]);

parse(p,ac_db_filename,files,varargin{:});

% CREATE TABLE t_file
% (
% 	file_pkey   		SERIAL PRIMARY KEY,
% 	
% 	file_name		TEXT,	 	--
% 	file_path		TEXT, 		--
% 	file_start_time		TIMESTAMP,	--
% 	file_end_time		TIMESTAMP,	--
% 	file_software_key	INT, 		-- Software used to record the file
% 	file_cruise_key		INT, 		-- Cruise during which this file was recorded
% 	file_deployment_key	INT, 		-- Cruise during which this file was recorded
% 	
% 	file_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes
% 	
% 	FOREIGN KEY (file_software_key) REFERENCES t_software(software_pkey),
% 	FOREIGN KEY (file_cruise_key) REFERENCES t_cruise(cruise_pkey),
% 	FOREIGN KEY (file_deployment_key) REFERENCES t_deployment(deployment_pkey).
% 	UNIQUE(file_path,file_name,file_end_time) ON CONFLICT REPLACE,
%     CHECK (file_end_time>=file_start_time))
% );
% COMMENT ON TABLE t_file is 'Acoustic data files';

if ~iscell(files)
    files={files};
end

nb_files=length(files);
struct_in.file_start_time=cell(nb_files,1);
struct_in.file_end_time=cell(nb_files,1);
struct_in.file_name=cell(nb_files,1);

idx_rem=[];
for i=1:nb_files
    try
        fprintf('Getting Start and End Date from file %s (%i/%i)\n',files{i},i,nb_files);
        [start_date,end_date,~]=start_end_time_from_file(files{i});
        if start_date>0
            struct_in.file_start_time{i}=datestr(start_date,'yyyy-mm-dd HH:MM:SS');
            struct_in.file_end_time{i}=datestr(end_date,'yyyy-mm-dd HH:MM:SS');
        else
            idx_rem=union(idx_rem,i);
        end   
        [~,file_tmp,ext_tmp]=fileparts(files{i});
        struct_in.file_name{i}=[file_tmp ext_tmp];
    catch 
        idx_rem=union(idx_rem,i);
        fprintf('Error getting Start time for %s\n',files{i});
    end
end

struct_in.file_name(idx_rem)=[];
struct_in.file_start_time(idx_rem)=[];
struct_in.file_end_time(idx_rem)=[];

fields=fieldnames(p.Results);
for ifi=1:numel(fields)
    if ~isempty(p.Results.(fields{ifi}))&&~ismember(fields{ifi},{'ac_db_filename' 'files'})
        if iscell(p.Results.(fields{ifi}))
            struct_in.(fields{ifi})=p.Results.(fields{ifi});
            struct_in.(fields{ifi})(idx_rem)=[];            
        else
            struct_in.(fields{ifi})=repmat({p.Results.(fields{ifi})},numel(struct_in.file_name),1);
        end                
    end
end

t=struct2table(struct_in);
dbconn=sqlite(ac_db_filename,'connect');  
dbconn.insert('t_file',fieldnames(struct_in),t);
sql_query=sprintf('SELECT file_pkey FROM t_file WHERE file_name IN ("%s")',strjoin(struct_in.file_name,'","'));
file_pkeys=dbconn.fetch(sql_query);
dbconn.close();

end