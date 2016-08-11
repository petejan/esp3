function linked_candidates=link_candidates_v3(candidates,dist_pings,range,horz_link_max,vert_link_max,l_min_tot,h_min_tot)


nb_pings=length(dist_pings);
nb_samples=length(range);

candidates_ori=candidates;
vec_candidates=unique(candidates(:));
vec_candidates(vec_candidates==0)=[];
nb_candidates=length(vec_candidates);
if nb_candidates==0
    linked_candidates=candidates;
    return;
end
linking_mat=nan(nb_candidates,nb_candidates);
fprintf(1,'Processing Linking %i/%i\n',1,nb_candidates);

mask=candidates>0;

mask=(filter2(ones(3,3),mask,'same'))==9;

candidates(mask)=0;

u=0;
while u<length(vec_candidates(1:end-1))
     u=u+1;
    i=vec_candidates(u);
    k_done=[];
    curr_candidates=find(candidates==vec_candidates(u));
    other_candidates=find(candidates~=vec_candidates(u)&candidates>0);
    
    if isempty(curr_candidates)||isempty(other_candidates)
        continue;
    end
    
    idx_can_other=candidates(other_candidates);
    
    idx_already_unlinked=find(linking_mat(i,:)==0);
    
    for ial=1:length(idx_already_unlinked)
        other_candidates(idx_can_other==idx_already_unlinked(ial))=0;
    end
    
    other_candidates(other_candidates==0)=[];
    
    if isempty(other_candidates)
        linking_mat(isnan(linking_mat(:,i)),i)=0;
        linking_mat(i,isnan(linking_mat(i,:)))=0;
        continue;
    end
    
    K_red=reduce_matrice_v2(dist_pings,range,curr_candidates,other_candidates,horz_link_max,vert_link_max);
    
    if isempty(K_red)
        linking_mat(isnan(linking_mat(:,i)),i)=0;
        linking_mat(i,isnan(linking_mat(i,:)))=0;
        continue;
    end
    
    [k_other,id_inter]=intersect(other_candidates,K_red);
    
    idx_can_other=idx_can_other(id_inter);
    k_curr=intersect(curr_candidates,K_red);
    k_curr=setdiff(k_curr,k_done);
    
    
    if isempty(k_other)||isempty(k_curr)
        linking_mat(isnan(linking_mat(:,i)),i)=0;
        linking_mat(i,isnan(linking_mat(i,:)))=0;
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
                vec_candidates(vec_candidates==iii)=[];
                nb_candidates=length(vec_candidates(1:end));
                candidates(candidates==iii)=i;
                candidates_ori(candidates_ori==iii)=i;
            end
            
            curr_candidates=find(candidates==vec_candidates(u));
             other_candidates=find(candidates~=vec_candidates(u)&candidates>0);
            
            if isempty(curr_candidates)||isempty(other_candidates)
                linking_mat(isnan(linking_mat(:,i)),i)=0;
                linking_mat(i,isnan(linking_mat(i,:)))=0;
                break;
            end
            
            idx_can_other=candidates(other_candidates);
            idx_already_unlinked=find(linking_mat(i,:)==0);
            
            for ial=1:length(idx_already_unlinked)
                other_candidates(idx_can_other==idx_already_unlinked(ial))=0;
            end
             other_candidates(other_candidates==0)=[];
            if isempty(other_candidates)

                linking_mat(isnan(linking_mat(:,i)),i)=0;
                linking_mat(i,isnan(linking_mat(i,:)))=0;
                break;
            end
            
            K_red=reduce_matrice_v2(dist_pings,range,curr_candidates,other_candidates,horz_link_max,vert_link_max);
            
            if isempty(K_red)
                linking_mat(isnan(linking_mat(:,i)),i)=0;
                linking_mat(i,isnan(linking_mat(i,:)))=0;
                break;
            end
            
            [k_other,id_inter]=intersect(other_candidates,K_red);
            
            idx_can_other=idx_can_other(id_inter);
            k_curr=intersect(curr_candidates,K_red);
            k_curr=setdiff(k_curr,k_done);
            
            
            if isempty(k_other)||isempty(k_curr)
                linking_mat(isnan(linking_mat(:,i)),i)=0;
                linking_mat(i,isnan(linking_mat(i,:)))=0;
                fprintf(1,'Processing Linking %i/%i\n',u,nb_candidates);
                continue;
            end
            j=0;
            
        end
        
    end
    linking_mat(isnan(linking_mat(:,i)),i)=0;
    linking_mat(isnan(linking_mat(i,:)),i)=0;
end
fprintf(1,'Processing Linking %i/%i\n',u,nb_candidates);

linked_candidates=zeros(size(candidates));
id=0;
u=unique(candidates_ori(:));

for ii=1:length(u)
    idx_curr=find(candidates_ori==u(ii));
    I_curr_can=rem(idx_curr,nb_samples);
    I_curr_can(I_curr_can==0)=nb_samples;
    J_curr_can=ceil(idx_curr/nb_samples);
    
    if ((nanmax(dist_pings(J_curr_can))-nanmin(dist_pings(J_curr_can)))>=l_min_tot )&&((nanmax(range(I_curr_can))-nanmin(range(I_curr_can)))>=h_min_tot)   
        linked_candidates(candidates_ori==u(ii))=id;
        id=id+1;
    else
        linked_candidates(candidates_ori==u(ii))=0;
    end
end

linked_candidates(candidates_ori==0)=0;


end




