function gpu_comp=get_gpu_comp_stat()

if  license('test','Distrib_Computing_Toolbox')
    gpu_comp=gpuDeviceCount>0;
else   
    gpu_comp=1==0;
end

end
