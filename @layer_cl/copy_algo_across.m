function copy_algo_across(layer_obj,algo_obj)

for ii=1:length(layer_obj.Frequencies)
    
    [idx_algo,found]=find_algo_idx(layer_obj.Transceivers(ii),algo_obj.Name);
    
    if found==1
        layer_obj.Transceivers(ii).Algo(idx_algo)=algo_obj;
    else
        layer_obj.Transceivers(ii).Algo=[layer_obj.Transceivers(ii).Algo algo_obj];
    end
end

end