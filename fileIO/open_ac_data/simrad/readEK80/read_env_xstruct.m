function env=read_env_xstruct(xstruct)

Env=xstruct;

for j=1:length(Env.Attributes)
    env_temp.(Env.Attributes(j).Name)=Env.Attributes(j).Value;
end

if ~isempty(Env.Children)
    Transducer=Env.Children(1);
    for j=1:length(Transducer.Attributes)
        env_temp.(Transducer.Attributes(j).Name)=Transducer.Attributes(j).Value;
    end
end

fields=fieldnames(env_temp);

for jj=1:length(fields)
    env.(fields{jj})=(env_temp.(fields{jj}));
end

