function depthfactor = getdf(file)

% function depthfactor = getdf(file)
%
% Reads in data from an i-file and calculates the depthfactor
% which is the number of samples per metre.
%
% Type: help esp2 for other functions

% check number and type of arguments
if nargin < 1
  error('Function requires one input argument');
elseif ~isstr(file)
  error('Input must be a string representing a filename');
end
%If OS is windows, assume /data/ac1 is a mapped drive
if ~isempty(strfind(computer, 'WIN'))              %so find
    [status, result]=system(['cygpath -w ' file]); %windows
    file = strtrim(result);                        %equivalent
end

%if a d-,n- or t- file was specified instead of an i-file
%use the corresponding i-file
tok = file(end-7);
num = file((end-6):end);
if (tok == 'd' | tok == 'n' | tok == 't') & ~isempty(str2num(num))
   file(end-7) = 'i';
end

fid = fopen(file);
if fid == -1
   error(['File not found or permission denied for ' file]);
end

line = fgetl(fid);
while isempty(strfind(line,'depth_factor')) 
  line = fgetl(fid);
  if line == -1
    break;
  end
end

if line == -1
  depthfactor = 0; % will cause a divide by zero later on
else
  [t, r] = strtok(line, '='); 
  depthfactor = str2num(r(3:end));
end

fclose(fid);
