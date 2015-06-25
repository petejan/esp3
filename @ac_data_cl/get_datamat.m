function datamat=get_datamat(data,type)
[idx,found]=find_type_idx(data,type);
if found
    datamat=data.SubData(idx).DataMat;
else
    datamat=[];
end
end