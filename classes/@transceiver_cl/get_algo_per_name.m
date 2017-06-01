function algo_obj=get_algo_per_name(trans_obj,algo_name)

[idx_alg,alg_found]=find_algo_idx(trans_obj,algo_name);

if alg_found==0
    algo_obj=init_algos(algo_name);
    trans_obj.add_algo(algo_obj);
else
    algo_obj=trans_obj.Algo(idx_alg);
end


end