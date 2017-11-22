function [idx,found]=find_cid_idx(layer,cid)
if ~iscell(cid)
    cid={cid};
end
found=ones(1,numel(cid));
idx=ones(1,numel(cid));

for ifr=1:numel(cid)
    if isnumeric(cid{ifr})
        cid{ifr}=num2str(cid{ifr});
    end
        idx_tmp=find(strcmpi(deblank(layer.ChannelID),deblank(cid{ifr})));
    
    if isempty(idx_tmp)
        found(ifr)=0;
        idx(ifr)=1;
    else
        found(ifr)=1;
        idx(ifr)=idx_tmp;
    end
end

end