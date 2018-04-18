% CREATE TABLE t_file
% (
% 	file_pkey   		SERIAL PRIMARY KEY,
% 	
% 	file_name		TEXT,	 	--
% 	file_path		TEXT, 		--
% 	file_start_time		TIMESTAMP,	--
% 	file_end_time		TIMESTAMP,	--
% 	file_software_key	INT, 		-- Software used to record the file

% 	file_comments		TEXT, 		-- Free text field for relevant information not captured by other attributes
% 	
% 	FOREIGN KEY (file_software_key) REFERENCES t_software(software_pkey),
% 	UNIQUE(file_path,file_name,file_end_time) ON CONFLICT REPLACE,
%     CHECK (file_end_time>=file_start_time))
% );
% COMMENT ON TABLE t_file is 'Acoustic data files';
function file_pkeys=add_files_to_t_file(ac_db_filename,files,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addRequired(p,'files',@(x) ischar(x)||iscell(x));
addParameter(p,'file_path',[]);
addParameter(p,'file_software_key',[]);
addParameter(p,'file_comments',[]);
addParameter(p,'file_start_time',[]);
addParameter(p,'file_end_time',[]);

parse(p,ac_db_filename,files,varargin{:});

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
        if isempty(p.Results.file_start_time)||isempty(isempty(p.Results.file_end_time))
            fprintf('Getting Start and End Date from file %s (%i/%i)\n',files{i},i,nb_files);
            [start_date,end_date,~]=start_end_time_from_file(files{i});
            if start_date>0
                struct_in.file_start_time{i}=start_date;
                struct_in.file_end_time{i}=end_date;
            else
                idx_rem=union(idx_rem,i);
            end                      
        else 
            struct_in.file_start_time{i}=p.Results.file_start_time(i);
            struct_in.file_end_time{i}=p.Results.file_end_time(i);
        end
        [~,file_tmp,ext_tmp]=fileparts(files{i});
        struct_in.file_name{i}=[file_tmp ext_tmp];
        if struct_in.file_start_time{i}>struct_in.file_end_time{i}
            idx_rem=union(idx_rem,i);
        end
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
        elseif ischar(p.Results.(fields{ifi}))
            struct_in.(fields{ifi})=repmat({p.Results.(fields{ifi})},numel(struct_in.file_name),1);            
        elseif isnumeric(p.Results.(fields{ifi}))&&numel(p.Results.(fields{ifi}))==1
            struct_in.(fields{ifi})=repmat(p.Results.(fields{ifi}),numel(struct_in.file_name),1);
        end                
    end
end

if iscell(struct_in.file_start_time)
    struct_in.file_start_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),struct_in.file_start_time,'un',0);
    struct_in.file_end_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),struct_in.file_end_time,'un',0);
else
    struct_in.file_start_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_in.file_start_time),'un',0);
    struct_in.file_end_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_in.file_end_time),'un',0);
end

% t=struct2table(struct_in);
% dbconn=connect_to_db(ac_db_filename);  
% dbconn.insert('t_file',fieldnames(struct_in),t);
% 
% sql_query=sprintf('SELECT file_pkey FROM t_file WHERE file_name IN ("%s") AND file_path IN ("%s")',strjoin(struct_in.file_name,'","'),strjoin(struct_in.file_path,'","'));
% file_pkeys=dbconn.fetch(sql_query);
% dbconn.close();

% struct_in_minus_key=rmfield(struct_in,{'file_comments'});
struct_in_minus_key=struct_in;
file_pkeys=insert_data_controlled(ac_db_filename,'t_file',struct_in,struct_in_minus_key,'file_pkey');


if istable(file_pkeys)
    tmp=table2struct(file_pkeys,'ToScalar',true);
    file_pkeys=tmp.file_pkey;
end

if iscell(file_pkeys)
    file_pkeys=cell2mat(file_pkeys);
end

end