function function_out=init_func(name)

switch name
    case 'BottomDetection'
        function_out=@detec_bottom_algo_v2;
    case 'BadPings'
        function_out=@bad_pings_removal_2;
    case 'Denoise'
        function_out=@bg_noise_removal_v2;
    case 'SchoolDetection'
        function_out=@school_detect;
    case 'SingleTarget'
        function_out=@single_targets_detection;
    case 'TrackTarget'
        function_out=@track_targets_angular;
        
end

end