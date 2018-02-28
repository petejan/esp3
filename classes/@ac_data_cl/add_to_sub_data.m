function add_to_sub_data(data_obj,field,val)

[idx,found]=find_field_idx(data_obj,field);

if found>0    
    for ii=1:length(data_obj.SubData(idx).Memap)
        if numel(val)==1||all(size(val)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))))
            data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))=data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))+val;
        elseif (size(val,1)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))),1)&&size(val,2)==1)||...
                (size(val,2)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))),2)&&size(val,1)==1)
            data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))=bsxfun(@plus,data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))),val);    
        end
    end
end

end
