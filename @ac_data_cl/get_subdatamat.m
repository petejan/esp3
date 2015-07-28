function datamat=get_subdatamat(data,field,idx_r,idx_ping)

% [idx,found]=find_field_idx(data,field);
% if found
%     datamat=data.SubData(idx).DataMat;
% else
%     datamat=[];
% end


[idx,found]=find_field_idx(data,(deblank(field)));

if found
    datamat=data.SubData(idx).Memap.Data.(lower(deblank(field)))(idx_r,idx_ping);
else
    datamat=[];
end



end