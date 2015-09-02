function [caxis,idx]=get_caxis(data,field)


[idx,found]=find_field_idx(data,(deblank(field)));

if found
    caxis=data.SubData(idx).CaxisDisplay;
else
    caxis=[];
end

end