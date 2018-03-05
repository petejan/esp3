function varout=init_varargout(name)

switch name
    case {'BottomDetectionV2','BottomDetection'}
        varout={'bottom','double_bottom_region','bs_bottom','idx_bottom','idx_ringdown','idx_pings'};
    case 'BadPings'
        varout={'bottom','double_bottom_region','idx_noise_sector'};
    case 'BadPingsV2'
        varout={'idx_noise_sector'};
    case 'Denoise'
        varout={};
        %varout={'power_unoised','Sv_unoised','Sp_unoised','SNR'};
    case 'SchoolDetection'
        varout={'linked_candidates'};
    case 'SingleTarget'
        varout={'single_targets'};
    case 'TrackTarget'
        varout={'tracks_out'};
    otherwise
        varout=[];
        
end

end