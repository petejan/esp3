
function candidates=find_candidates(Mask,range_mat,dist_pings_mat,l_min_can,h_min_can,min_nb_sples)

%remove bad candidates.
% h_filter=ceil(h_min_can/nanmean(diff(range_mat(:,1)))/2);
% l_filter=ceil(l_min_can/nanmean(diff(dist_pings_mat(1,:))));


candidates=zeros(size(Mask));
%candidates_filt=zeros(size(Mask));

[I,J]=find(Mask);
[nb_row,nb_col]=size(Mask);
K=find(Mask);
k=1;
h=waitbar(k/length(I),sprintf('Processing Segmentation %.0f/%i',k/length(I)*100,100),'Name','Processing Segmentation');
region_number=1;
K_rem=sort(K);
I_rem=I;
J_rem=J;
K_proc=[];
if ~isempty(K_rem)
    while k<length(I)
        reg_temp=zeros(size(Mask));
        %reg_disp=zeros(size(Mask));
        I_new=I_rem(1);
        J_new=J_rem(1);
        K_new=K_rem(1);
        K_tot=K_new;
        Len_idx=length(K_new);
        
        while Len_idx>0
            I_neighbours=[I_new-1 I_new-1 I_new-1 I_new I_new I_new I_new+1 I_new+1 I_new+1];
            J_neighbours=[J_new-1 J_new J_new+1 J_new-1 J_new J_new+1 J_new-1 J_new J_new+1];
            idx_rem=(I_neighbours<=0)|(I_neighbours>nb_row)|(J_neighbours<=0)|(J_neighbours>nb_col);
            
            K_neighbours=I_neighbours+nb_row*(J_neighbours-1);
            K_neighbours(idx_rem)=[];
            
            K_init=intersect(K_rem,K_neighbours);
            
            K_new=setdiff(K_init,K_tot);
            
            K_tot=[K_tot;K_new];
            
            Len_idx=length(K_new);
            
            J_new=floor(K_new/nb_row)+1;
            I_new=K_new-nb_row*(J_new-1);
            
        end
 
        dist=dist_pings_mat(K_tot);
        range=range_mat(K_tot);
        if ((nanmax(dist)-nanmin(dist)>=l_min_can )...
                &&(nanmax(range)-nanmin(range)>=h_min_can) ...
                && (length(K_tot)>min_nb_sples))
            
            reg_temp(K_tot)=1;
            
            %             reg_temp_filt=ceil(filter2(ones(h_filter,l_filter),double(reg_temp>0),'same')./filter2(ones(h_filter,l_filter),ones(size(reg_temp)),'same'));
            %             reg_temp_filt=floor(filter2(ones(h_filter,l_filter),reg_temp_filt,'same')./filter2(ones(h_filter,l_filter),ones(size(reg_temp)),'same'));
            %             candidates_filt(reg_temp_filt>0)=region_number;
            
            candidates(reg_temp>0)=region_number;
            
            region_number=region_number+1;
            
            try
                waitbar(k/length(I),h,sprintf('Processing Segmentation %.0f/%i',k/length(I)*100,100));
            catch
                h=waitbar(k/length(I),sprintf('Processing Segmentation %.0f/%i',k/length(I)*100,100),'Name','Processing Segmentation');
            end
        end
        
        K_proc=[K_proc;K_tot];
        [K_rem,idx_rem]=setdiff(K,K_proc);
        I_rem=I(idx_rem);
        J_rem=J(idx_rem);
        k=length(K_proc);
        
    end
    
end
close(h)
end