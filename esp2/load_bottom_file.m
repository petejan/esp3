% load_bottom_file
% Loads in a previously exported bottom file produced by ESP2
% Outputs this as a vector of numbers, where
% each number represents the depth of the bottom
% below the transducer, in ADC samples.
%
% Usage: bottom = load_bottom_file(file)
%
% file can either be a file name, including path, or a number
% in which case a file b0000xxx in the current directory is
% assumed.
%
% See also get_bottom

% Created by Adam Dunford August 2000
% $Id: load_bottom_file.m 6539 2009-02-26 01:02:07Z dunford $

function bottom = load_bottom_file(file)

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
   bottom = [];
   return;
end

%Read in file, skipping lines until 'EndAlgorithm' is found
%and ignoring columns 1 (the old bottom) and 3 (bottom type)
line = fgetl(fid);
while ~strncmp(line,'EndAlgorithms',13)
   line = fgetl(fid);
end

bottom = fscanf(fid, '%*d %d %*s');

%Decide how to handle undefined bottoms, indicated by -1 in file
%-1 indicates that ESP2 could not find a bottom for that transmit
%Options are 'NaN' and 'From_Left'
fill_bottom_method = 'From_Left';
%fill_bottom_method = 'NaN';

switch fill_bottom_method
case 'NaN'
   %Replace any -1s by NaN
   f = find(bottom == -1);
   if length(f) == length(bottom)
      disp('Error: the file has no bottom fitted');
   else
      bottom(f) = NaN;
   end
case 'From_Left'
   %Replace any -1s by the previous value, interatively.
   %This will draw a flat (constant) line from the previous 
   %non-'-1' (i.e. defined) value to the next defined value.
   %If the first element is -1 then the first defined element is
   %used for the bottom line value from the first element to that value
   f = find(bottom == -1);
   if ~isempty(f)
      if length(f) == length(bottom)
         disp('Error: the file has no bottom fitted');
      else
         if (f(1)) == 1 %the first non-zero element is the first element
            bottom(1) = bottom((find(bottom ~= -1,1,'first')));  %use the first non-'-1' element
            for i = 2:length(f)
               bottom(f(i)) = bottom(f(i)-1);
            end
         else
            for i = 1:length(f)
               bottom(f(i)) = bottom(f(i)-1);
            end
         end
      end
   end
end
fclose(fid);