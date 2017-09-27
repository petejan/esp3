function data=data_from_gpu(data)


for idx_freq=1:length(data.pings)
    fi=fieldnames(data.pings(idx_freq));
    
    for ifi=1:length(fi)
        if isa(data.pings(idx_freq).(fi{ifi}),'gpuArray')    
            data.pings(idx_freq).(fi{ifi})=gather(data.pings(idx_freq).(fi{ifi}));
        end
    end
    
end