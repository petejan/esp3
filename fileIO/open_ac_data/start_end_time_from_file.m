function [start_time,end_time]=start_end_time_from_file(filename,varargin)

if nargin==1
    ftype=get_ftype(fullfile(filename));
else
    ftype=varargin{1};
end

switch ftype
    case {'EK60','EK80'}
        [start_time,end_time]=start_end_time_from_raw_file(filename);
    case 'asl'
        [start_time,end_time]=start_end_time_from_asl_file(filename);
end
                        
end