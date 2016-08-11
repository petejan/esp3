function varin=init_varargin(name)

switch name
    case 'BottomDetectionOld'
       varin=struct(...
        'denoised',0,...
        'thr_bottom',-35,...
        'thr_echo',-12,...
        'shift_bot',0,...
        'r_min',0,...
        'r_max',Inf);
    case 'BottomDetection'
       varin=struct(...
        'denoised',0,...
        'thr_bottom',-35,...
        'thr_backstep',-1,...
        'horz_filt',50,...
        'vert_filt',10,...
        'shift_bot',0,...
        'r_min',0,...
        'r_max',Inf);
    case 'BadPings'
        varin=struct(...
        'denoised',0,...
        'thr_bottom',-35,...
        'thr_backstep',-1,...
        'r_min',0,...
        'r_max',Inf,...
        'shift_bot',0,...
        'horz_filt',50,...
        'vert_filt',10,...
        'BS_std',6,...
        'BS_std_bool',true,...
        'thr_spikes_Above',3,...
        'thr_spikes_Below',3,...
        'Above',true,...
        'Below',false);
    case 'Denoise'
        varin=struct(...
        'HorzFilt',50,...
        'VertFilt',10,...
        'NoiseThr',-125,...
        'SNRThr',10);
    case 'SchoolDetection'
        varin=struct(...
        'Type','sv',...
        'Sv_thr',-65,...
        'l_min_can',10,...
        'h_min_tot',20,...
        'h_min_can',10,...
        'l_min_tot',50,...
        'nb_min_sples',100,...
        'horz_link_max',5,...
        'vert_link_max',5,...
        'depth_max',Inf);
    case 'SingleTarget'
        varin=struct(...
        'Type','sp',...
        'TS_threshold',-65,...
        'PLDL',6,...
        'MinNormPL',0.6,...
        'MaxNormPL',1.5,...
        'MaxBeamComp',12,...
        'MaxStdMinAxisAngle',1,...
        'MaxStdMajAxisAngle',1);
    case 'TrackTarget'
        varin=struct(...
        'AlphaMajAxis',0.7,...
        'AlphaMinAxis',0.7,...
        'AlphaRange',0.7,...
        'BetaMajAxis',0.5,...
        'BetaMinAxis',0.5,...
        'BetaRange',0.5,...
        'ExcluDistMajAxis',1,...
        'ExcluDistMinAxis',1,...
        'ExcluDistRange',1,...
        'MaxStdMajorAxisAngle',1,...
        'MaxStdMinorAxisAngle',1,...
        'MissedPingExpMajAxis',5,...
        'MissedPingExpMinAxis',5,...
        'MissedPingExpRange',5,...
        'WeightMajAxis',20,...
        'WeightMinAxis',20,...
        'WeightRange',40,...
        'WeightTS',10,...
        'WeightPingGap',10,...
        'Min_ST_Track',8,...
        'Min_Pings_Track',10,...
        'Max_Gap_Track',5);
    otherwise
        varin=[];
        
end

end