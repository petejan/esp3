function datamat=get_subdatamat(data,field,idx_r,idx_ping)

[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=nan(length(idx_r),length(idx_ping));
    
    for icell=1:length(data.SubData(idx).Memap)
        idx_ping_cell=find(data.FileId==icell);
        [idx_ping_cell_red,idx_ping_temp,~]=intersect(idx_ping,idx_ping_cell);
        %idx_ping_temp
        if ~isempty(idx_ping_temp)
            datamat(:,idx_ping_temp)=double(data.SubData(idx).Memap{icell}.Data.(lower(deblank(field)))(idx_r,idx_ping_cell_red-idx_ping_cell(1)+1));
        end
    end
else
    datamat=[];
end


end