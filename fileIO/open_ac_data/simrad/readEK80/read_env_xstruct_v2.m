function env=read_env_xstruct_v2(xstruct)%%%%%%TOFIX

env=xstruct.Environment.Attributes;

trans=xstruct.Environment.Transducer;

if length(trans)==1
    trans={trans};
end

att=fieldnames(trans{1}.Attributes);
for j=1:length(att)
    env.(att{j})=trans{1}.Attributes.(att{j});
end


att=fieldnames(env);

for j=1:length(att)
    val_temp=str2double(env.(att{j}));
    if ~isnan(val_temp)
        env.(att{j})=str2double(env.(att{j}));
    end
end

