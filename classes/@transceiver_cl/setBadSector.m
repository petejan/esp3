function setBadSector(obj,tag)

if isempty(tag)
    return;
end

bottom_obj=obj.Bottom;
tag=ones(size(bottom_obj.Range));
tag(IdxBad)=0;
obj.Bottom=bottom_cl('Origin',bottom_obj.Origin,'Range',bottom_obj.Range,'Sample_idx',bottom_obj.Sample_idx,'Tag',tag);

end