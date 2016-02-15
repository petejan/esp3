function remove_sub_data(data,fieldname)
subdata_temp=data.SubData;
[idx,found]=find_field_idx(data,fieldname);

if found==0
    return;
else
    subdata_temp(idx).Memap.Writable=false;
    delete(subdata_temp(idx).Memap.Filename);
    subdata_temp(idx)=[];
    data.Type(idx)=[];
    data.Fieldname(idx)=[];
end

data.SubData=subdata_temp;

end
