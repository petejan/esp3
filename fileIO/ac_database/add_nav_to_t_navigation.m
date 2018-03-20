% CREATE TABLE t_navigation
% (
% 	t_navigation_id		INTEGER PRIMARY KEY AUTOINCREMENT,
% 	navigation_time		TIMESTAMP,	--
% 	navigation_latitude	FLOAT,		--
% 	navigation_longitude	FLOAT,		--
% 	navigation_depth 	FLOAT,		--
% 	navigation_file_id	INT,		-- Identifier of file for which this navigation data record is relevant
% 	navigation_comments	TEXT,	 	-- Free text field for relevant information not captured by other attributes
% 	FOREIGN KEY (navigation_file_id) REFERENCES t_file(t_file_id)
% );


function add_nav_to_t_navigation(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'navigation_file_id',nan,@isnumeric);
addParameter(p,'navigation_time',0,@isnumeric);
addParameter(p,'navigation_latitude',0,@isnumeric);
addParameter(p,'navigation_longitude',0,@isnumeric);
addParameter(p,'navigation_depth',0,@isnumeric);
addParameter(p,'navigation_comments',[]);

parse(p,ac_db_filename,varargin{:});

if all(p.Results.navigation_latitude==0)||isempty(p.Results.navigation_latitude)
    return; 
end

nb_points=numel(p.Results.navigation_time);



fields={'navigation_file_id' 'navigation_time' 'navigation_latitude' 'navigation_longitude' 'navigation_depth' 'navigation_comments'};


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

struct_in.navigation_time=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),num2cell(struct_in.navigation_time),'un',0);

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

f_ids=unique(struct_in.navigation_file_id);
id_keep=[];

% f=figure();
% ax=axes(f);
% plot(ax,struct_in.navigation_longitude,struct_in.navigation_latitude,'.');
% hold(ax,'on');
% grid(ax,'on');
for ifi=1:numel(f_ids)
    id_f=find(struct_in.navigation_file_id==f_ids(ifi));
    [~,~,id_tmp]=DouglasPeucker(struct_in.navigation_longitude(id_f),struct_in.navigation_latitude(id_f),1e-6*5,0,1e3,0);
    id_keep=union(id_f(id_tmp),id_keep);
end


    fields=fieldnames(struct_in);
    for ifi=1:numel(fields)
        struct_in.(fields{ifi})=struct_in.(fields{ifi})(id_keep);
    end

% plot(ax,struct_in.navigation_longitude,struct_in.navigation_latitude,'x');

if~isdeployed()
    fprintf('Number of points: %.0f\nReduced Number of points in navigation table:%.0f\n',numel(p.Results.navigation_time),numel(id_keep))
end

t=struct2table(struct_in);

dbconn=sqlite(ac_db_filename,'connect');  
dbconn.insert('t_navigation',fieldnames(struct_in),t);
dbconn.close();