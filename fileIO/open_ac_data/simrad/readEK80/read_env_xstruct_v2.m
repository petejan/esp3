function env=read_env_xstruct_v2(xstruct)

if isfield(xstruct.Environment,'Attributes')
    env=xstruct.Environment.Attributes;
    
    if isfield(xstruct.Environment,'Transducer')
        trans=xstruct.Environment.Transducer;
        
        if length(trans)==1
            trans={trans};
        end
        if isfield(trans{1},'Transducer')
            att=fieldnames(trans{1}.Attributes);
            for j=1:length(att)
                env.(att{j})=trans{1}.Attributes.(att{j});
            end
        end
    end
    
    att=fieldnames(env);
    
    for j=1:length(att)
        val_temp=str2double(env.(att{j}));
        if ~isnan(val_temp)
            env.(att{j})=str2double(env.(att{j}));
        end
    end
else
    env=[];
end
