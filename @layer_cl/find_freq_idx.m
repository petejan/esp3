function [idx,found]=find_freq_idx(layer,freq)

idx=find(layer.Frequencies==freq);
found=1;
if isempty(idx)
    idx=1;
    found=0;
end

end