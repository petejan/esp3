function datamat=get_datamat(data,field)


[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=data.SubData(idx).Memap.Data.(lower(deblank(field)));
else
    datamat=[];
end

end