
function [idx_process,idx_algo,found]=find_process_algo(process_list,freq,name)

found=0;
if isempty(process_list)
    idx_process=[];
    idx_algo=[];
else
    idx_process=[];
    for ii=1:length(process_list)
        if freq==process_list(ii).Freq
            idx_process=ii;
        end
    end
    if ~isempty(idx_process)
        idx_algo=[];
        curr_process=process_list(idx_process);
        for kk=1:length(curr_process.Algo)
            switch curr_process.Algo(kk).Name
                case name
                    idx_algo=kk;
                    found=1;
            end
            
        end
    else
        idx_algo=[];
    end
end