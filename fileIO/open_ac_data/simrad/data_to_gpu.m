function data=data_to_gpu(data)

for idx_freq=1:length(data.pings)
    fi=fieldnames(data.pings(idx_freq));
    
    for ifi=1:length(fi)
        if isnumeric(data.pings(idx_freq).(fi{ifi}))    
            data.pings(idx_freq).(fi{ifi})=gpuArray(data.pings(idx_freq).(fi{ifi}));
        end
    end
    
end