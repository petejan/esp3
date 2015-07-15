function datamat=get_datamat(data,field)

% [idx,found]=find_field_idx(data,field);
% if found
%     datamat=data.SubData(idx).DataMat;
% else
%     datamat=[];
% end
varlist=who(data.MatfileData);
if nansum(strcmpi(varlist,(deblank(field))))==1
    datamat=double(data.MatfileData.(lower(deblank(field))));
else
    datamat=[];
end

end