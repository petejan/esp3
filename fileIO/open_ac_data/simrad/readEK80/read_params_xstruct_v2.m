function params=read_params_xstruct_v2(xstruct)


Channels=xstruct.Parameter.Channel;
for i=1:length(Channels)
    if length(Channels)>1
        Chanel=Channels{i};
    else
        Chanel=Channels;
    end
    params_temp=Chanel.Attributes;
    att=fieldnames(params_temp);
    
    for j=1:length(att)
        
        val_temp=str2double(params_temp.(att{j}));
        if ~isnan(val_temp)
            params(i).(att{j})=val_temp;
        else
            params(i).(att{j})=params_temp.(att{j});
        end
    end
    
end
