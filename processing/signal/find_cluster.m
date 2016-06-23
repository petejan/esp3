function main_idx_thr_db=find_cluster(idx_thr_db,lar_lim)
[nb_samples,nb_beams]=size(idx_thr_db);
main_idx_thr_db=zeros(nb_samples,nb_beams);

for i=1:nb_beams
    cluster_length=0;
    idx_cluster=1;
    best_cluster_length=0;
    idx_best_cluster=1;
    idx=idx_thr_db(:,i);
    idx_non_nul=find(idx);
    j=1;
    
    if ~isempty(idx_non_nul)
        idx_cluster=idx_non_nul(1);
        cluster_length=1;
    while j<length(idx_non_nul)
        if idx_non_nul(j+1)==idx_non_nul(j)+1
            idx_cluster=idx_non_nul(j)-cluster_length+1;
            cluster_length=cluster_length+1;
        else
            if cluster_length>=best_cluster_length
                best_cluster_length=cluster_length;
                idx_best_cluster=idx_cluster;
            end
            cluster_length=1;
        end
        j=j+1;
    end
        
    end
    
    if cluster_length>=best_cluster_length
        best_cluster_length=cluster_length;
        idx_best_cluster=idx_cluster;
    end
    
    if best_cluster_length==0
        if i==nb_beams||i==1
            main_idx_thr_db(:,i)=zeros(size(main_idx_thr_db(:,i)));
        else
            main_idx_thr_db(:,i)= main_idx_thr_db(:,i)|main_idx_thr_db(:,i+1);
        end
            
    else
        if best_cluster_length<lar_lim
            idx_best_cluster=max(1,idx_best_cluster-round((lar_lim-best_cluster_length)/2));
            best_cluster_length=lar_lim;
        end
        if idx_best_cluster+best_cluster_length-1<=nb_samples
            main_idx_thr_db(idx_best_cluster:idx_best_cluster+best_cluster_length-1,i)=1;
        else
            main_idx_thr_db(idx_best_cluster:end,i)=1;
        end
    end
end