function process_list=set_process_list(process_list,freq,algo,add)

[idx_process,idx_algo,~]=find_process_algo(process_list,freq,algo.Name);

if isempty(idx_process)
    if add==1
        process_list=[process_list process_cl('Freq', freq,'Algo', algo)];
    end
else
    if ~isempty(idx_algo)
        if add==1
            process_list(idx_process).Algo(idx_algo)=algo;
        else
            process_list(idx_process).Algo(idx_algo)=[];
        end
    else
         if add==1
            process_temp=process_list(idx_process);
            process_list(idx_process).Algo=[process_temp.Algo algo];
        end
    end
end

end