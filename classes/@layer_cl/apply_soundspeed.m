function  apply_soundspeed(layer,c)

    fprintf('   New Soundspeed value: %.0f m/s\n',c);
    for it=1:length(layer.Transceivers)
        layer.Transceivers(it).apply_soundspeed(c);  
    end
    
    layer.EnvData.SoundSpeed=c;
end