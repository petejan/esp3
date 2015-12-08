function env=read_env_xstruct(xstruct)

Env=xstruct;

for j=1:length(Env.Attributes)
    env_temp.(Env.Attributes(j).Name)=Env.Attributes(j).Value;
end

Transducer=Env.Children(1);

for j=1:length(Transducer.Attributes)
    env_temp.(Transducer.Attributes(j).Name)=Transducer.Attributes(j).Value;
end

    fields=fieldnames(env_temp);
    
    for jj=1:length(fields)
        switch fields{jj}
            case 'TransducerName' 
                env.(fields{jj})=(env_temp.(fields{jj}));
            otherwise
                env.(fields{jj})=str2double(env_temp.(fields{jj}));
        end
    end
end
