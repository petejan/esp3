function linked_candidates=link_candidates_v2(candidates,dist_pings,range,horz_link_max,vert_link_max,l_min_tot,h_min_tot,load_bar_comp)

if nansum(candidates(:))==0
    linked_candidates=candidates;
    return;
end
candidates_ori=candidates;

[nb_samples,nb_pings]=size(candidates);

range_mat=bsxfun(@times,range,ones(1,nb_pings));
dist_pings_mat=bsxfun(@times,dist_pings(:)',ones(nb_samples,1));


vec_candidates=double(unique(candidates(candidates>0)))';
vec_candidates(vec_candidates==0)=[];
nb_candidates=length(vec_candidates);

mask=candidates>0;

mask=(filter2(ones(3,3),mask,'same'))==9;


candidates(mask)=0;


linking_mat=nan(nb_candidates,nb_candidates);

u=0;
if ~isempty(load_bar_comp)
    load_bar_comp.status_bar.setText('Linking Candidates');
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(vec_candidates(1:end)), 'Value',0);
end

while u<length(vec_candidates(1:end-1))
    u=u+1;
    nb_candidates=length(vec_candidates(1:end));
    i=vec_candidates(u);
    
    if ~isempty(load_bar_comp)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(vec_candidates(1:end)), 'Value',u);
    end
    
    curr_candidates=(candidates==i);
    
    if sum(curr_candidates(:))==0
        continue;
    end
    
    other_candidates=(candidates~=i)&(candidates>0);
    idx_already_unlinked=find(linking_mat(i,:)==0);
    
    other_candidates(ismember(candidates,idx_already_unlinked))=0;
    
    k_other=find(other_candidates);
    k_curr=find(curr_candidates);
    
    if isempty(k_other)|| isempty(k_curr)
        linking_mat(:,i)=0;
        linking_mat(i,:)=0;
        continue;
    end
   
    K_red=reduce_matrice_v2(dist_pings,range,k_curr,k_other,horz_link_max,vert_link_max);
    if isempty(K_red)
        linking_mat(:,i)=0;
        linking_mat(i,:)=0;
        continue;
    end
    
    k_other=K_red(other_candidates(K_red));
    k_curr=K_red(curr_candidates(K_red));
    
    if isempty(k_other)|| isempty(k_curr)
        linking_mat(:,i)=0;
        linking_mat(i,:)=0;
        continue;
    end
    
    j=0;
    while j<length(k_curr) && ~isempty(k_other)
        j=j+1;
        
        dist_curr=dist_pings_mat(k_curr(j));
        range_curr=range_mat(k_curr(j));
        
        linkable_candidates_k=((((dist_pings_mat(k_other)-dist_curr).^2/horz_link_max^2+(range_mat(k_other)-range_curr).^2/vert_link_max^2)<=1));
        linkable_candidates_idx=unique(candidates(k_other(linkable_candidates_k)));
        
        if ~isempty(linkable_candidates_idx)
            
            
            
            for iii=linkable_candidates_idx'
                
                linking_mat(iii,i)=1;
                linking_mat(i,iii)=1;
                vec_candidates(vec_candidates==iii)=[];
                nb_candidates=length(vec_candidates(1:end));
                candidates(candidates==iii)=i;
                candidates_ori(candidates_ori==iii)=i;
                 
            end
            
            
            other_candidates=(candidates~=i)&(candidates>0);
            idx_already_unlinked=find(linking_mat(i,:)==0);
            
            other_candidates(ismember(candidates,idx_already_unlinked))=0;
            
            curr_candidates=(candidates==i);
            
            k_other=find(other_candidates);
            k_curr=find(curr_candidates);
            
            if isempty(k_other)|| isempty(k_curr)
                linking_mat(:,i)=0;
                linking_mat(i,:)=0;
                break;
            end

            K_red=reduce_matrice_v2(dist_pings,range,k_curr,k_other,horz_link_max,vert_link_max);
            k_other=K_red(other_candidates(K_red));
            k_curr=K_red(curr_candidates(K_red));
            
            if isempty(k_other)|| isempty(k_curr)
                linking_mat(isnan(linking_mat(:,i)),i)=0;
                linking_mat(i,isnan(linking_mat(i,:)))=0;
                break;
            end
                 
            j=0;  
        else
            candidates(k_curr(j))=0;   
        end
    end
    linking_mat(isnan(linking_mat(:,i)),i)=0;
    linking_mat(isnan(linking_mat(i,:)),i)=0;
    fprintf(1,'Processing Linking %i/%i\n',u,nb_candidates);

end


linked_candidates=zeros(size(candidates));
id=0;
u=unique(candidates_ori(:));

for ii=1:length(u)
    idx_curr=(candidates_ori==u(ii));
    if ((max(dist_pings_mat(idx_curr))-min(dist_pings_mat(idx_curr)))>=l_min_tot )&&((max(range_mat(idx_curr))-min(range_mat(idx_curr)))>=h_min_tot)   
        linked_candidates(candidates_ori==u(ii))=id;
        id=id+1;
    else
        linked_candidates(candidates_ori==u(ii))=0;
    end
end

linked_candidates(candidates_ori==0)=0;
end