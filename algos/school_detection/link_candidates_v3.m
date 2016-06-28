function linked_candidates=link_candidates_v3(candidates,dist_pings,range,horz_link_max,vert_link_max,l_min_tot,h_min_tot)

if isempty(candidates)
    linked_candidates=candidates;
    return;
end
nb_candidates=length(candidates);
vec_candidates=1:nb_candidates;
nb_pings=length(dist_pings);
nb_samples=length(range);
linking_mat=nan(nb_candidates,nb_candidates);
fprintf(1,'Processing Linking %i/%i\n',1,nb_candidates);

candidates_ori=candidates;

%candidates=clean_candidates(candidates,nb_samples,nb_pings);

for i=1:length(candidates)
    k_done=[];
    curr_candidates=candidates{i};
    
    len_candidates=cellfun(@length,candidates);
    idx_can=zeros(nansum(len_candidates),1);
    idx_can(1:len_candidates(1))=1;
    for i_len=2:length(len_candidates)
        idx_can(sum(len_candidates(1:i_len-1))+1:sum(len_candidates(1:i_len)))=i_len;
    end
    
    if isempty(curr_candidates)
        fprintf(1,'Processing Linking %i/%i\n',i,nb_candidates);
        continue;
    end
    idx_can_other=idx_can(idx_can~=i);
    idx_already_unlinked=find(linking_mat(i,:)==0);
    tmp = cellfun(@(c)c(:), candidates, 'UniformOutput',false);
    if ~isempty(idx_already_unlinked)
        for ia=1:length(idx_already_unlinked)
            idx_can_other(idx_can_other==idx_already_unlinked(ia))=[];
            tmp{idx_already_unlinked(ia)}=[];
        end
    end
    other_candidates= (vertcat(tmp{vec_candidates~=i}) );
    
    K_red=reduce_matrice_v2(dist_pings,range,curr_candidates,other_candidates,horz_link_max,vert_link_max);
    
    [k_other,id_inter]=intersect(other_candidates,K_red);

    idx_can_other=idx_can_other(id_inter);
    k_curr=intersect(curr_candidates,K_red);
    k_curr=setdiff(k_curr,k_done);
    
    if isempty(k_other)
        fprintf(1,'Processing Linking %i/%i\n',i,nb_candidates);
        continue;
    end
    j=0;
    
    while j<length(k_curr) && ~isempty(k_other)
        j=j+1;
        

        k_done=[k_done k_curr(j)];
        
        sample_other=k_other-floor(k_other/nb_samples)*nb_samples;
        ping_other=ceil(k_other/nb_samples);
        
        sample_curr=k_curr(j)-floor(k_curr(j)/nb_samples)*nb_samples;
        ping_curr=ceil(k_curr(j)/nb_samples);
        
        dist_curr=dist_pings(ping_curr);
        range_curr=range(sample_curr);
        
        inside_idx=((dist_pings(ping_other)-dist_curr).^2/horz_link_max^2+(range(sample_other)-range_curr).^2/vert_link_max^2)<=1;

        if sum(inside_idx)>0
            linkable_candidates_idx=unique(idx_can_other(inside_idx));
            for iii=linkable_candidates_idx(:)'
                linking_mat(iii,i)=1;
                linking_mat(i,iii)=1;
                link_candidate=candidates{iii};
                candidates{i}=union(link_candidate,candidates{i});
                link_candidate_ori=candidates_ori{iii};
                candidates_ori{i}=union(link_candidate_ori,candidates_ori{i});
                vec_candidates(vec_candidates==iii)=i;
                idx_last=find(idx_can==i,1,'last');
                len_iii=length(link_candidate);
                idx_can(idx_can==iii)=[];
                if idx_last<length(idx_can)
                    idx_can=[idx_can(1:idx_last);i*ones(len_iii,1);idx_can(idx_last+1:end)];
                else
                    idx_can=[idx_can(1:idx_last);i*ones(len_iii,1)];
                end 
                candidates{iii}=[];  
                candidates_ori{iii}=[];  
            end
            
            curr_candidates=candidates{i};
            
            idx_can_other=idx_can(idx_can~=i);
            tmp = cellfun(@(c)c(:), candidates, 'UniformOutput',false);
            if ~isempty(idx_already_unlinked)
                for ia=1:length(idx_already_unlinked)
                    tmp{idx_already_unlinked(ia)}=[];
                    idx_can_other(idx_can_other==idx_already_unlinked(ia))=[];
                end
            end
            
            other_candidates= unique(vertcat(tmp{vec_candidates~=i}) );
            
            K_red=reduce_matrice_v2(dist_pings,range,curr_candidates,other_candidates,horz_link_max,vert_link_max);
            
            [k_other,id_inter]=intersect(other_candidates,K_red);
            idx_can_other=idx_can_other(id_inter);
            k_curr=intersect(curr_candidates,K_red);
            k_curr=setdiff(k_curr,k_done);
            
            if isempty(k_other)|| isempty(k_curr)
                fprintf(1,'Processing Linking %i/%i\n',i,nb_candidates);
                continue;
            end
            j=0;
            
        end
        
    end
    linking_mat(isnan(linking_mat(:,i)),i)=0;
    linking_mat(isnan(linking_mat(i,:)),i)=0;
    fprintf(1,'Processing Linking %i/%i\n',i,nb_candidates);
end

linked_candidates=zeros(nb_samples,nb_pings);

candidates_ori(cellfun(@isempty,candidates_ori))=[];
for ii=1:length(candidates_ori)
    k_curr=candidates_ori{ii};
    sample_curr=k_curr-floor(k_curr/nb_samples)*nb_samples;
    ping_curr=ceil(k_curr/nb_samples);
    
    if ((nanmax(dist_pings(ping_curr))-nanmin(dist_pings(ping_curr)))>=l_min_tot )&&((nanmax(range(sample_curr))-nanmin(range(sample_curr)))>=h_min_tot)
        linked_candidates(k_curr)=ii;
    end
end


end


function candidates_out=clean_candidates(candidates,nb_samples,nb_pings)

candidates_out=cell(1,length(candidates));
for ic=1:length(candidates)
    
    can_curr=candidates{ic};
    j_curr=ceil(can_curr/nb_samples);
    i_curr=can_curr-(j_curr-1)*nb_samples;
    
    i_curr_min=min(i_curr);
    j_curr_min=min(j_curr);
    i_curr_max=max(i_curr);
    j_curr_max=max(j_curr);

    
end

end


