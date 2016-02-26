function [idx,found]=find_layer_idx(layers,ID)

layer_id=nan(1,length(layers));
for i=1:length(layers)
    if isvalid(layers(i))
        layer_id(i)=layers(i).ID_num;
    end
end
idx=find(layer_id==ID,1);
if isempty(idx)
    idx=1;
    found=0;
else
    found=1;
end

end
