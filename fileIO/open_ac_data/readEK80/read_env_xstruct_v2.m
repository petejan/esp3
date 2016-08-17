function env=read_env_xstruct_v2(xstruct)

env=xstruct.Environment.Attributes;

att=fieldnames(xstruct.Environment.Transducer.Attributes);
for j=1:length(att)
    env.(att{j})=xstruct.Environment.Transducer.Attributes.(att{j});
end


att=fieldnames(env);

for j=1:length(att)
    val_temp=str2double(env.(att{j}));
    if ~isnan(val_temp)
        env.(att{j})=str2double(env.(att{j}));
    end
end

