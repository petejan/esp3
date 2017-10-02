function gpu_comp=get_gpu_comp_stat()

gpu_comp=gpuDeviceCount>0&& license('test','Distrib_Computing_Toolbox');

end
