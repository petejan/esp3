% CREATE TABLE t_navigation
% (
% 	navigation_pkey		SERIAL PRIMARY KEY,
%
% 	navigation_time		TIMESTAMP,	--
% 	navigation_latitude	FLOAT,		--
% 	navigation_longitude	FLOAT,		--
% 	navigation_depth 	FLOAT,		--
% 	navigation_file_key	INT,		-- Identifier of file for which this navigation data record is relevant
%
% 	navigation_comments	TEXT,	 	-- Free text field for relevant information not captured by other attributes
%
% 	FOREIGN KEY (navigation_file_key) REFERENCES t_file(file_pkey),
% 	UNIQUE(navigation_time,navigation_latitude,navigation_longitude) ON CONFLICT REPLACE
% );
% COMMENT ON TABLE t_navigation is 'Acoustic data file navigation';


function add_nav_to_t_navigation(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'navigation_file_key',nan,@isnumeric);
addParameter(p,'navigation_time',0,@isnumeric);
addParameter(p,'navigation_latitude',0,@isnumeric);
addParameter(p,'navigation_longitude',0,@isnumeric);
addParameter(p,'navigation_depth',0,@isnumeric);
addParameter(p,'navigation_comments',[]);
addParameter(p,'force_update',0,@isnumeric);

parse(p,ac_db_filename,varargin{:});

if all(p.Results.navigation_latitude==0)||isempty(p.Results.navigation_latitude)
    return;
end

nb_points=numel(p.Results.navigation_time);



fields={'navigation_file_key' 'navigation_time' 'navigation_latitude' 'navigation_longitude' 'navigation_depth' 'navigation_comments'};


for ifi=1:numel(fields)
    if ~isempty(p.Results.(fields{ifi}))
        if numel(p.Results.(fields{ifi}))==nb_points
            struct_in.(fields{ifi})=p.Results.(fields{ifi})(:);
        else
            if ischar(p.Results.(fields{ifi}))
                struct_in.(fields{ifi})=repmat({p.Results.(fields{ifi})},nb_points,1);
            else
                struct_in.(fields{ifi})=repmat(p.Results.(fields{ifi}),nb_points,1);
            end
        end
    end
end


struct_in.navigation_longitude(struct_in.navigation_longitude>180)=struct_in.navigation_longitude(struct_in.navigation_longitude>180)-360;


if isempty(p.Results.navigation_comments)
    struct_in.navigation_comments=repmat({''},nb_points,1);
end

id_nan=isnan(p.Results.navigation_latitude);

if any(id_nan)
    fields=fieldnames(struct_in);
    for ifi=1:numel(fields)
        struct_in.(fields{ifi})(id_nan)=[];
    end
end

f_ids=unique(struct_in.navigation_file_key);



id_keep=[];

% f=figure();
% ax=axes(f);
% plot(ax,struct_in.navigation_longitude,struct_in.navigation_latitude,'.');
% hold(ax,'on');
% grid(ax,'on');
for ifi=1:numel(f_ids)
    id_f=find(struct_in.navigation_file_key==f_ids(ifi));
    
    if p.Results.force_update==0
        [~,~,~,~,~,t_end]=get_first_last_pos_from_t_navigation(ac_db_filename,f_ids(ifi));
        if ~isempty(t_end)
            if (struct_in.navigation_time(id_f(end))-datenum(t_end))*24*60*60<5
                
                continue;
            end
        end
    end
    [~,~,id_tmp]=DouglasPeucker(struct_in.navigation_longitude(id_f),struct_in.navigation_latitude(id_f),1e-6*5,0,1e3,0);
    
    id_keep=union(id_f(id_tmp),id_keep);
end

if isempty(id_keep)
disp('Navigation table already up to date')
    return;
end

fields=fieldnames(struct_in);
for ifi=1:numel(fields)
    struct_in.(fields{ifi})=struct_in.(fields{ifi})(id_keep);
end

% plot(ax,struct_in.navigation_longitude,struct_in.navigation_latitude,'x');

if~isdeployed()
    fprintf('Number of points: %.0f\nReduced Number of points in navigation table:%.0f\n',numel(p.Results.navigation_time),numel(id_keep))
end

struct_in.navigation_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_in.navigation_time),'un',0);

t=struct2table(struct_in);
try
    dbconn=sqlite(ac_db_filename,'connect');
    dbconn.insert('t_navigation',fieldnames(struct_in),t);
    dbconn.close();
catch err
    disp(err.message);
    warning('add_nav_to_t_navigation:Error while executing sql query');
end