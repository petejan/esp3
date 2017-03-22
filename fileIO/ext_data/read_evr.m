%% read_evr.m
%
% Read in the 2D region export format file from Echoview. Returns the
% region data in a array of structures. 
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |filename|: TODO
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2015-12-XX: updated with more output in the struct to get more informations (Yoann Ladroit)
% * 2013-09-XX: adjusted (Johannes Oeffner)
% * 2012-08-XX: added lines to read detection settings and all notes lines (Johannes Oeffner)
% * 2009-03-XX: first version (Gavin Macaulay)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Gavin Macaulay, Johannes Oeffner, Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function reg = read_evr(filename)

%%% open file
fid = fopen(filename);
if fid == -1
   disp(['Unable to open file: ' filename])
   return
end

%%% Read the header lines
version = fgetl(fid); % version header line
line = fgetl(fid); % number of regions line
num_regions = sscanf(line, '%d');
junk = fgetl(fid); % blank line

%%% Read the region definitions
for i = 1:num_regions
    info_str = fgetl(fid); % region info line 13 4 16 0 3 -1 1 20101110 2207462930  64.8681 20101110 2208104020  79.0708
    info_cell=textscan(info_str,'%d %d %d %d %d %d %d %s %s %f %s %s %f');
    info.ver=info_cell{1};
    info.nb_points=info_cell{2};
    info.reg_id=info_cell{3};
    info.r_type=info_cell{5};
    if info_cell{7}==1
        bbox.time_start=datenum([char(info_cell{8}) char(info_cell{9})], 'yyyymmddHHMMSSFFF');
        bbox.depth_start=info_cell{10};
        bbox.time_end=datenum([char(info_cell{11}) char(info_cell{12})], 'yyyymmddHHMMSSFFF');
        bbox.depth_end=info_cell{13};
    else
        bbox.time_start=nan;
        bbox.depth_start=nan;
        bbox.time_end=nan;
        bbox.depth_end=nan;
    end
    
    n = str2double(fgetl(fid)); % number of notes lines to follow
    notes = '';
    for j = 1:n
        tmp = fgetl(fid); % region notes
        notes = char(notes, tmp);
    end
    
    n = str2num(fgetl(fid)); % number of detetction setting lines to follow
    detection = '';
    for j = 1:n
        tmp = fgetl(fid); % region detection
        detection = char(detection, tmp);
    end
    
    class = fgetl(fid); % region classification
    vertices_line = fgetl(fid); % region vertices and type
    name = fgetl(fid); % region name
    junk = fgetl(fid); % blank line
    
    % parse out the vertices and type
    vertices_line = deblank(vertices_line);
    % get the region shape type
    shapetype = str2num(vertices_line(end-1:end));
    % extract the region type
    type = str2num(vertices_line(end-1:end));
    % trim off the region type
    vertices_line = vertices_line(1:end-2);
    % extract the vertix triplets
    vertices = reshape(sscanf(vertices_line, '%d %d %f'), 3, [])';
    % convert the date and time columns into a single datenum
    d = num2str(vertices(:,1));
%     t = num2str(vertices(:,2));
    t = [];
    for k = 1:size(vertices,1);
        t = horzcat(t, num2str(sprintf('%010d\n',vertices(k,2))));  % I added this in because some times that started at midnight 00 created errors (Johannes)
    end    
    timestamp = datenum(str2num(d(:,1:4)), str2num(d(:,5:6)), str2num(d(:,7:8)), ...
        str2num(t(:,1:2)), str2num(t(:,3:4)), str2num(t(:,5:end))/10000);
    % put it all into a structure
    reg(i) = struct('name', name,'info',info,'bbox',bbox, 'classification', class, 'notes', notes, ...
        'detectionsettings', detection, 'shapetype', shapetype, 'timestamp', timestamp, 'depth', vertices(:,3), ...
        'type', type);
end

fclose(fid);

