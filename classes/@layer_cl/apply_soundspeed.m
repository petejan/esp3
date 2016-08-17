function  apply_soundspeed(layer,c)


    for it=1:length(layer.Transceivers)
        layer.Transceivers(it).apply_soundspeed(layer.EnvData.SoundSpeed,c);  
    end
    
    layer.EnvData.SoundSpeed=c;
end