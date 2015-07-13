function datamat=get_datamat(data,field)

% [idx,found]=find_field_idx(data,field);
% if found
%     datamat=data.SubData(idx).DataMat;
% else
%     datamat=[];
% end

if nansum(strcmpi(fields(data.MatfileData),(deblank(field))))==1
    datamat=data.MatfileData.(lower(deblank(field)));
else
    datamat=[];
end

end