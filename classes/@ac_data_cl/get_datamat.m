function [datamat,idx]=get_datamat(data,field)

[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=nan(length(data.Range),length(data.Number));
    
    for icell=1:length(data.SubData(idx).Memap)
        idx_ping=(data.FileId==icell);
        datamat(:,idx_ping)=double(data.SubData(idx).Memap{icell}.Data.(lower(deblank(field))));
    end
else
    datamat=[];
end

end