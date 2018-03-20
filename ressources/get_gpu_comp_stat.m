function gpu_comp=get_gpu_comp_stat()

try
    gpu_comp=license('test','Distrib_Computing_Toolbox');
    if gpu_comp
        g = gpuDevice;
        if str2double(g.ComputeCapability)>=3&&g.SupportsDouble&&g.DriverVersion>7
            gpu_comp=g.DeviceSupported;
        else
            gpu_comp=0;
        end
    end
    
catch err
    gpu_comp=0;
    if contains((err.message),'CUDA')
        fprintf('Your graphic card might support CUDA, but it looks like your graphic driver needs to be updated to the latest version from the NVidia Website.\nIf you do not have a CUDA enabled NVidia graphic card, please ignore this long message and let us know about it...\n')
    end
end

end
