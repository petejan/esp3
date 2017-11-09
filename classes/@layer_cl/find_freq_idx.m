function [idx,found]=find_freq_idx(layer,freq)
found=ones(1,numel(freq));
idx=ones(1,numel(freq));

for ifr=1:numel(freq)
    idx_tmp=find(layer.Frequencies==freq(ifr));
    
    if isempty(idx_tmp)
        found(ifr)=0;
        idx(ifr)=1;
    else
        found(ifr)=1;
        idx(ifr)=idx_tmp(1);
    end
end

end