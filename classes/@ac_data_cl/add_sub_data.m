function add_sub_data(data,subdata)
subdata_temp=data.SubData;

for i=1:length(subdata)
    fieldname=subdata(i).Fieldname;
    [idx,found]=find_field_idx(data,fieldname);
    if found==0
        if size(subdata_temp,1)==1
            subdata_temp=[subdata_temp subdata(i)];
        else
            subdata_temp=[subdata_temp; subdata(i)];
        end
        data.Fieldname=[data.Fieldname subdata(i).Fieldname];
        data.Type=[data.Type subdata(i).Type];
    else
        subdata_temp(idx).Memap.Writable=false;
        delete(subdata_temp(idx).Memap.Filename);
        subdata_temp(idx)=subdata(i);
    end
end

data.SubData=subdata_temp;

end