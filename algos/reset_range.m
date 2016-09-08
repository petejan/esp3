function algo_vec=reset_range(algo_vec,range)


for i=1:length(algo_vec)
    switch algo_vec(i).Name
        case {'BottomDetectionV2', 'BadPings'}
            algo_vec(i).Varargin.r_min=range(2);
            algo_vec(i).Varargin.r_max=range(end-1);
            algo_vec(i).Varargin.vert_filt=range(end)/50;
    end
end

end