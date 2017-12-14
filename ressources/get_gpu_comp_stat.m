function gpu_comp=get_gpu_comp_stat()

[gpu_comp,~]=license('checkout','Distrib_Computing_Toolbox');

try
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
       disp('Your graphic card might support CUDA, but it looks like your graphic driver needs to be updated to the latest version from the NVidia Website. If you do not have a VUDA enabled NVidia graphic card, please ignore this long message and let us know about it...') 
    end
end

end
