function [idx,found]=find_algo_idx(trans,name)

idx=[];
for ii=1:length(trans.Algo)
    if strcmp(name,trans.Algo(ii).Name)
        idx=ii;
        found=1;
    end
end

if isempty(idx)
    idx=1;
    found=0;
end

end