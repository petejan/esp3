function gpu_comp=get_gpu_comp_stat()

[gpu_comp,~]=license('checkout','Distrib_Computing_Toolbox');

if gpu_comp
    g = gpuDevice;
    gpu_comp=g.DeviceSupported;
end

end
