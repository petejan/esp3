function add_to_sub_data(data_obj,field,val)

[idx,found]=find_field_idx(data_obj,field);

if found>0    
    for ii=1:length(data_obj.SubData(idx).Memap)
        if numel(val)==1||all(size(val)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))))
            data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))=...
                cast((double(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))))*data_obj.SubData(idx).ConvFactor+val)/data_obj.SubData(idx).ConvFactor,data_obj.SubData(idx).Fmt);
        elseif (size(val,1)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))),1)&&size(val,2)==1)||...
                (size(val,2)==size(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))),2)&&size(val,1)==1)
            data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))=...
                cast(bsxfun(@plus,double(data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field))))*data_obj.SubData(idx).ConvFactor,val)/data_obj.SubData(idx).ConvFactor,data_obj.SubData(idx).Fmt);    
        end
    end
end




end
