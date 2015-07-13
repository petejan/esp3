function datamat=get_subdatamat(data,field,idx_r,idx_ping)

% [idx,found]=find_field_idx(data,field);
% if found
%     datamat=data.SubData(idx).DataMat;
% else
%     datamat=[];
% end

if nansum(strcmpi(fields(data.MatfileData),(deblank(field))))==1
    datamat=data.MatfileData.(lower(deblank(field)))(idx_r,idx_ping);
else
    datamat=[];
end

end