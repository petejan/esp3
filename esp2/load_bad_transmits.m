% load_bad_transmits
% Loads in a previously exported bottom file produced by ESP2
% Outputs this as a boolean vector, where
% 1 signifies a bad transmit (indicated by B in the bottom file) and
% 0 signifies not bad (i.e. the abscence of a B)
%
% Usage: bad = load_bad_transmits(file)
%
% file can either be a file name, including path, or a number
% in which case a file b0000xxx in the current directory is
% assumed.
% 
% See also get_bad_transmits

% Created by Adam Dunford October 2001
% Added the Version number as output.

function [bad,ver] = load_bad_transmits(file)

if isnumeric(file)  %Create file name, e.g. b00000023
   filename = ['b', sprintf('%07d',file)];
elseif ischar(file) %Use the name given
   filename = file;
else
   error('Unknown format for file name')
end

%open file
fid = fopen(filename);
if fid == -1
   disp(['Error: File not found or permission denied for ' filename]);
   bad = [];
   return
end

%Read in file, skipping lines until 'EndAlgorithm' is found
%and ignoring columns 1 (the old bottom) and 2 (current bottom)
line = fgetl(fid);
if ~isempty(strfind(line,'head'));
    ver=line(end-3:end-1);
else
    ver=[];
end
while ~strncmp(line,'EndAlgorithms',13)
   line = fgetl(fid);
end

b = fscanf(fid, '%*d %*d %c%c',[2,inf]);
bad = zeros(1,size(b,2));                                 %set all transmits to not-bad
badpings1 = strfind(lower(char(b(1,:))),'b');             %and those with B to bad
badpings2 = strfind(lower(char(b(2,:))),'b');            
badpings = unique(union(badpings1,badpings2));            %to cope with B or UB
bad(badpings) = 1;
fclose(fid);