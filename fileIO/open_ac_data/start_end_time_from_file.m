function [start_time,end_time]=start_end_time_from_file(filename)

ftype=get_ftype(fullfile(filename));

switch ftype
    case {'EK60','EK80'}
        [start_time,end_time]=start_end_time_from_raw_file(filename);
    case 'asl'
        [start_time,end_time]=start_end_time_from_asl_file(filename);
end
                        
end