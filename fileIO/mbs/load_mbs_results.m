function mbs = load_mbs_results(filename)

mbs=mbs_cl();
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
        mbs.Header.title = r(3:length(r));
    end
    if strcmp(t,'voyage')
        mbs.Header.voyage = r(3:length(r));
    end
    if strcmp(t,'author')
        mbs.Header.author = r(3:length(r));
    end
    if strcmp(t,'main_species')
        mbs.Header.main_species = r(3:length(r));
    end
    if strcmp(t,'areas')
        mbs.Header.areas = r(3:length(r));
    end
    if strcmp(t,'created')
        mbs.Header.created = r(3:length(r));
    end
    if strcmp(t,'comments')
        mbs.Header.comments = r(3:length(r));
    end
    if strcmp(t,'mbs_revision')
        header.mbs_revision = r(3:length(r));
    end
    if strcmp(t,'mbs_filename')
        mbs.Header.MbsId = r(3:length(r));
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
        mbs.Output.regionSumAbscf.Data = read_region_sliced(header, fid);
    elseif strncmp(line, '# Sliced Transect Summary', 25) == 1
        mbs.Output.slicedTransectSum.Data = read_transect_sliced(header, fid);
    elseif strncmp(line, '# Region vbscf', 14) == 1
        mbs.Output.regionSumVbscf.Data = read_region_detail(header, fid);
    elseif strncmp(line, '# Stratum Summary', 17) == 1
        mbs.Output.stratumSum.Data = read_stratum(header, fid);
    elseif strncmp(line, '# Transect Summary', 13) == 1
        mbs.Output.transectSum.Data = read_transect_summary(header, fid);
    elseif strncmp(line, '# Region Summary', 13) == 1
        mbs.Output.regionSum.Data = read_region_summary(header, fid);
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
        
        if isempty(line)
            continue;
        end
        
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end;
       
        data{i,1} = str2double(all_words(1,:));
        data{i,2} = strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3} = str2double(all_words(3,:));
        data{i,4} = all_words(4,:);
        data{i,5} = str2double(all_words(5,:));
        data{i,6} = str2double(all_words(6,:));
        % there should now be 2*num_vert_slices left in all_words OR
        % 4*num_vert_slices, depending on what version of esp2 was used
        % to generate the output. We detect this automatically and populate
        % the lat/long is we have the data.
        k = 1;
        if size(all_words,1) < 4*data{i,6} % we don't have lat/long values
            for j = 1 : data{i,6}
                data{i,7}(k) = str2double(all_words(7+2*(j-1),:));
                data{i,10}(k) = str2double(all_words(7+2*(j-1)+1,:));
                data{i,8}(k) = NaN;
                data{i,9} (k)= NaN;
                k = k + 1;
            end
        else % we have lat/long values
            for j = 1 : data{i,6}
                data{i,7}(k) = str2double(all_words(7+4*(j-1),:));
                data{i,8}(k) = str2double(all_words(7+4*(j-1)+1,:));
                data{i,9}(k) = str2double(all_words(7+4*(j-1)+2,:));
                data{i,10}(k)= str2double(all_words(7+4*(j-1)+3,:));
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
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end
        data{i,1}= str2double(all_words(1,:));
        data{i,2}= strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3}= str2double(all_words(3,:));
        data{i,4} = str2double(all_words(4,:));
        data{i,5} = str2double(all_words(5,:));
        % there should now be 3*num_vert_slices left in all_words (lat,
        % long, abscf)
        k = 1;
        for j = 1:data{i,5}
            data{i,6}(k)   = str2double(all_words(6+3*(j-1),:));
            data{i,7}(k)  = str2double(all_words(6+3*(j-1)+1,:));
            data{i,8}(k) = str2double(all_words(6+3*(j-1)+2,:));
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
        
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end
        
        data{i,1} = str2double(all_words(1,:));
        data{i,2} = strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3} = str2double(all_words(3,:));
        data{i,4} = all_words(4,:);
        data{i,5} = str2double(all_words(5,:));
        data{i,6} = str2double(all_words(6,:));
        data{i,7} = str2double(all_words(7,:));
        data{i,8} = str2double(all_words(8,:));
        % there should now be num_h_slices * num_v_slices left in all_words
        ii = 1;
        for j = 1 : data{i,6}
            for k = 1 : data{i,7}
                data{i,9}(k) = str2double(all_words(8 + ii,:));
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
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end
        data{i,1} = str2double(all_words(1,:));
        data{i,2} = strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3} = str2double(all_words(3,:));
        data{i,4} = str2double(all_words(4,:));
        data{i,5} = str2double(all_words(5,:));
        data{i,6} = str2double(all_words(6,:));
        data{i,7} = str2double(all_words(7,:));
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
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end
        data{i,1}   = str2double(all_words(1,:));
        data{i,2}    = strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3}   = str2double(all_words(3,:));
        data{i,4}    = str2double(all_words(4,:));
        data{i,5}  = str2double(all_words(5,:));
        data{i,6}  = str2double(all_words(6,:));
        data{i,7}  = str2double(all_words(7,:));
        data{i,8}  = str2double(all_words(8,:));
        data{i,9}  = str2double(all_words(9,:));
        data{i,10}  = str2double(all_words(10,:));
        data{i,11}  = str2double(all_words(11,:));
        data{i,12}  = str2double(all_words(12,:));
        data{i,13}  = str2double(all_words(13,:));
        
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
        line=strrep(line,'NaN','');
        all_words = words(line,',');
        if isempty(all_words)
            return;
        end
        %all_words=strsplit(line,',');

        data{i,1}   = str2double(all_words(1,:));
        data{i,2}  = strcat(all_words(2,:)); % strcat removes trailing spaces
        data{i,3}  = str2double(all_words(3,:));
        data{i,4}  = strcat(all_words(4,:));
        data{i,5}  = str2double(all_words(5,:));
        data{i,6}  = strcat(all_words(6,:));
        data{i,7}  = str2double(all_words(7,:));
        data{i,8}  = str2double(all_words(8,:));
        data{i,9} = str2double(all_words(9,:));
        data{i,10}  = str2double(all_words(10,:));
        data{i,11}  = str2double(all_words(11,:));
        data{i,12}  = str2double(all_words(12,:));
        data{i,13}  = str2double(all_words(13,:));
        data{i,14}  = str2double(all_words(14,:));
        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


