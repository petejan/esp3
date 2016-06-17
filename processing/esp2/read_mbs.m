function [header, data] = read_mbs(filename)

% Read in the output of an ESP2 mbs run
% Sections that are currently loaded are:
%  - the vertical abscf region summary
%  - the vertical abscf transect summary
%  - the region vbscf for all vertical and horizontal slices
%
% function [header, data] = read_mbs(mbs_output_file)

% By Gavin Macaulay, October 2001
% $Id: read_mbs.m 7200 2015-05-17 23:07:18Z ladroity $
%
% - Added stratum summary output (just for snapshot, stratum, no_transects) - used in star_weights.m
% Stephane Gauthier, October 2006
% $Id: read_mbs.m 7200 2015-05-17 23:07:18Z ladroity $

% - Added transect summary output - used in mbs_result.m
% Johannes Oeffner, August 2012

[fid, message] = fopen(filename);

if fid == -1
    disp(message)
    return
end

% read in the first 14 lines - these contain various header bits.
for i = 1:13
    line = fgetl(fid);
    [t,r]=strtok(line, ':');
    if strcmp(t,'number_of_regions')
        header.num_regions = str2double(r(3:length(r)));
    end
    if strcmp(t,'number_of_transects')
        header.num_transects = str2double(r(3:length(r)));
    end
    if strcmp(t,'title')
        header.title = r(3:length(r));
    end
    if strcmp(t,'voyage')
        header.voyage = r(3:length(r));
    end
    if strcmp(t,'author')
        header.author = r(3:length(r));
    end
    if strcmp(t,'main_species')
        header.main_species = r(3:length(r));
    end
    if strcmp(t,'areas')
        header.areas = r(3:length(r));
    end
    if strcmp(t,'created')
        header.created = r(3:length(r));
    end
    if strcmp(t,'comments')
        header.comments = r(3:length(r));
    end
    if strcmp(t,'mbs_revision')
        header.mbs_revision = r(3:length(r));
    end
    if strcmp(t,'mbs_filename')
        header.mbs_filename = r(3:length(r));
    end
    if strcmp(t,'number_of_strata')
        header.num_strata = str2double(r(3:length(r)));
    end
    if strcmp(t,'number_of_transects')
        header.num_transects = str2double(r(3:length(r)));
    end

end

%header

% now find the section we want and read it in.
% At the moment we are only interested in the vertical abscf region summary

line = fgetl(fid);

while ~feof(fid)
    if strncmp(line, '# Region Summary (abscf', 22) == 1 
        data.region = read_region_sliced(header, fid);
    elseif strncmp(line, '# Sliced Transect Summary', 25) == 1 
        data.transect = read_transect_sliced(header, fid);
    elseif strncmp(line, '# Region vbscf', 14) == 1
        data.region_detail = read_region_detail(header, fid);
    elseif strncmp(line, '# Stratum Summary', 17) == 1
        data.stratum = read_stratum(header, fid);
    elseif strncmp(line, '# Transect Summary', 13) == 1
        data.transect_summary = read_transect_summary(header, fid);    
    elseif strncmp(line, '# Region Summary', 13) == 1
        data.region_summary = read_region_summary(header, fid);    
     end
    line = fgetl(fid);
end

fclose(fid);

function data = read_region_sliced(header, fid)

% skip the local header line
line = fgetl(fid);
if header.num_regions==0
    data=[];
    return;
end

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_regions
        line = fgetl(fid);
        all_words = words(line,',');
        data(i).snapshot = str2double(all_words(1,:));
        data(i).stratum = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).transect = str2double(all_words(3,:));
        data(i).filename = all_words(4,:);
        data(i).region_id = str2double(all_words(5,:));
        data(i).num_vert_slices = str2double(all_words(6,:));
        % there should now be 2*num_vert_slices left in all_words OR
        % 4*num_vert_slices, depending on what version of esp2 was used
        % to generate the output. We detect this automatically and populate
        % the lat/long is we have the data.
        k = 1;
        if size(all_words,1) < 4*data(i).num_vert_slices % we don't have lat/long values
            for j = 1 : data(i).num_vert_slices
                data(i).transmit_start(k) = str2double(all_words(7+2*(j-1),:));
                data(i).column_abscf(k)    = str2double(all_words(7+2*(j-1)+1,:));
                data(i).lat(k)      = NaN;
                data(i).long(k)     = NaN;
                k = k + 1;
            end
        else % we have lat/long values
            for j = 1 : data(i).num_vert_slices
                data(i).transmit_start(k) = str2double(all_words(7+4*(j-1),:));
                data(i).lat(k)      = str2double(all_words(7+4*(j-1)+1,:));
                data(i).long(k)     = str2double(all_words(7+4*(j-1)+2,:));
                data(i).column_abscf(k)    = str2double(all_words(7+4*(j-1)+3,:));
                k = k + 1;
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function data = read_transect_sliced(header, fid)

% skip the local header line
line = fgetl(fid);

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_transects
        line = fgetl(fid);
        all_words = words(line,',');
        data(i).snapshot   = str2double(all_words(1,:));
        data(i).stratum    = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).transect   = str2double(all_words(3,:));
        data(i).slicesize  = str2double(all_words(4,:));
        data(i).num_slices = str2double(all_words(5,:));
        % there should now be 3*num_vert_slices left in all_words (lat,
        % long, abscf)
        k = 1;
        for j = 1 : data(i).num_slices
            data(i).lat(k)   = str2double(all_words(6+3*(j-1),:));
            data(i).long(k)  = str2double(all_words(6+3*(j-1)+1,:));
            data(i).slice_abscf(k) = str2double(all_words(6+3*(j-1)+2,:));
            k = k + 1;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = read_region_detail(header, fid)

% skip the local header line
line = fgetl(fid);
if header.num_regions==0
    data=[];
    return;
end

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_regions
        line = fgetl(fid);
        all_words = words(line,',');
        data(i).snapshot = str2double(all_words(1,:));
        data(i).stratum = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).transect = str2double(all_words(3,:));
        data(i).filename = all_words(4,:);
        data(i).region_id = str2double(all_words(5,:));
        data(i).num_h_slices = str2double(all_words(6,:));
        data(i).num_v_slices = str2double(all_words(7,:));
        data(i).region_vbscf = str2double(all_words(8,:));
        % there should now be num_h_slices * num_v_slices left in all_words
        ii = 1;
        for j = 1 : data(i).num_h_slices
            for k = 1 : data(i).num_v_slices
                data(i).vbscf_values(j,k) = str2double(all_words(8 + ii,:));
                ii = ii + 1;
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = read_stratum(header, fid)

% skip the local header line
line = fgetl(fid);

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_strata
        line = fgetl(fid);
        all_words = words(line,',');
        data(i).snapshot = str2double(all_words(1,:));
        data(i).stratum = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).no_transects = str2double(all_words(3,:));
        data(i).abscf_mean = str2double(all_words(4,:));
        data(i).abscf_sd = str2double(all_words(5,:));
        data(i).abscf_wmean = str2double(all_words(6,:));
        data(i).abscf_var = str2double(all_words(7,:));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = read_transect_summary(header, fid)

% skip the local header line
line = fgetl(fid);

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_transects
        line = fgetl(fid);
        all_words = words(line,',');
        data(i).snapshot   = str2double(all_words(1,:));
        data(i).stratum    = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).transect   = str2double(all_words(3,:));
        data(i).dist       = str2double(all_words(4,:));
        data(i).vbscf  = str2double(all_words(5,:));
        data(i).abscf  = str2double(all_words(6,:));
        data(i).mean_d  = str2double(all_words(7,:));
        data(i).pings  = str2double(all_words(8,:));
        data(i).av_speed  = str2double(all_words(9,:));
        data(i).start_lat  = str2double(all_words(10,:));
        data(i).start_lon  = str2double(all_words(11,:));
        data(i).finish_lat  = str2double(all_words(12,:));
        data(i).finish_lon  = str2double(all_words(13,:));
     
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = read_region_summary(header, fid)

% skip the local header line
line = fgetl(fid);
if header.num_regions==0
    data=[];
    return;
end

if feof(fid)
    data = [];
else
    % read in and parse the data
    for i = 1: header.num_regions
        line = fgetl(fid);

        all_words = words(line,',');
        
        data(i).snapshot   = str2double(all_words(1,:));
        data(i).stratum    = strcat(all_words(2,:)); % strcat removes trailing spaces
        data(i).transect   = str2double(all_words(3,:));
        data(i).file       = strcat(all_words(4,:));
        data(i).region_id  = str2double(all_words(5,:));
        data(i).ref  = strcat(all_words(6,:));
        data(i).slice_size  = str2double(all_words(7,:));
        data(i).good_pings  = str2double(all_words(8,:));
        data(i).start_d  = str2double(all_words(9,:));
        data(i).mean_d  = str2double(all_words(10,:));
        data(i).finish_d  = str2double(all_words(11,:));
        data(i).av_speed  = str2double(all_words(12,:));
        data(i).vbscf  = str2double(all_words(13,:));
        data(i).abscf  = str2double(all_words(14,:));
     
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


