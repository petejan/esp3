function results = regread(file)

%function results = regread(file)
%
%Reads in ESP2 format region files as 
%exported by ESP2. The results are returned as
%a nested Matlab structure. 
%
%Type: help esp2 for other functions

% check number and type of arguments
if nargin < 1
  error('Function requires one input argument');
elseif ~isstr(file)
  error('Input must be a string representing a filename');
end

fid = fopen(file);
if fid == -1
    disp(['Warning: File not found or permission denied for ' file]);
    results = struct([]);
    return
end

line = fgetl(fid); % read in header
results.header = line;
line = fgetl(fid); % read in version
results.version = line;
%There is currently no way of testing between
%Phase 3 and 4 region files, based on the version number
%so we don't
%But later we test to see if a vertical slice size was read.

line = fgetl(fid); % read in filename
results.filename = line;
line = fgetl(fid); % read in number of transmits
results.numtransmits = str2num(line);
line = fgetl(fid); % read in number of regions in this file
numregions = str2num(line);

for i = 1:numregions
   fgetl(fid);  %Skip RegionBegin
   %read in region ID
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).id = str2num(r(3:end));
   
   %read in shape and region data
   line = fgetl(fid);
   [t, r] = strtok(line, ':');
   [t, datastr] = strtok(r(2:end), ':');
   results.region(i).shape = t(2:end);
   datastr = datastr(3:end);
   regdata=sscanf(datastr,'%d%*c%g%*c',[2 inf]);
   results.region(i).bbox = regdata(:,1:2);
   results.region(i).vertices=regdata(:,3:end);
   
   %read in Region Type
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).regiontype = r(3:end);
   
   %read in Classification
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).classification = r(3:end);
   
   %read in Author
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   if length(r) < 3
      results.region(i).author = '';
   else
      results.region(i).author = r(3:end);
   end
   
   %read in Slice Size
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).slicesize = str2num(r(3:end));
   
   %read in Slice Ref Type
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).slicereftype = r(3:end);
   
   %read in Vertical Slice Size
   line = fgetl(fid);
   [t, r] = strtok(line, ':');
   if strcmp(t,'VertSliceSize')
      results.region(i).vertslicesize = str2num(r(3:end));
   else
      fclose(fid);
      clear results
      results = regread_1_0(file);
      disp('For Phase 3 region files use regread_1_0');
      return
   end   
   %read in comments
   fgetl(fid);  %Skip CommentsBegin
   line = fgets(fid);
   commentsstr = [];
   while ~strncmp(line,'CommentsEnd',11)
      commentsstr = [commentsstr line];
      line = fgets(fid);
   end
   results.region(i).comments = commentsstr;
   
   %read in Date/Time
   line = fgetl(fid);
   [t, r] = strtok(line, ':'); 
   results.region(i).datetime = str2num(r(3:end));
   fgetl(fid);  %Skip RegionEnd   
   
end

fclose(fid);