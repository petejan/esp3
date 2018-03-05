function [datamat,idx]=get_datamat(data,field)

[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=nan(length(data.get_samples()),length(data.get_numbers()));
    
    for icell=1:length(data.SubData(idx).Memap)
        idx_ping=(data.FileId==icell);
        datamat(:,idx_ping)=data.SubData(idx).ConvFactor*double(data.SubData(idx).Memap{icell}.Data.(lower(deblank(field))));
    end
else
    datamat=[];
end

end