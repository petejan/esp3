function params=read_params_xstruct(xstruct)

Channel=xstruct.Children;

for j=1:length(Channel.Attributes)
    params.(Channel.Attributes(j).Name)=Channel.Attributes(j).Value;
end

end
