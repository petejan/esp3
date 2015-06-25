
function region_id=region_seg_v2(Mask,min_nb_sples)
region_number=0;
region_id=zeros(size(Mask));
[I,J]=find(Mask);
[nb_row,nb_col]=size(Mask);
K=find(Mask);
k=1;
h=waitbar(k/length(I),sprintf('Processing Segmentation %i/%i',k,length(I)),'Name','Processing Segmentation');

if ~isempty(K)
    while k<length(I)
        
        region_number=region_number+1;
        I_new=I(k);
        J_new=J(k);
        K_new=K(k);
        K_tot=K_new;
        Len_idx=length(K_new);
        
        while Len_idx>0
            %[~,~,K_init]=find_neighbours(I,J,K,I_new,J_new);
            %K_init=find_neighbours_v2(I,J,K,I_new,J_new);
            %K_init=find_neighbours_v3(I,J,K,I_new,J_new,nb_row,nb_col);
            K_init=find_neighbours_v4(I,J,K,I_new,J_new);%fastest version....
            K_new=setdiff(K_init,K_tot);
               
            K_tot=[K_tot ;K_new];
            Len_idx=length(K_new);
            
            if Len_idx>0
            J_new=floor(K_new/nb_row)+1;
            I_new=K_new-nb_row*(J_new-1);
            end
        end
        
        if length(K_tot)>min_nb_sples
            region_id(K_tot)=region_number;  
        else
            region_number=region_number-1;
        end
        k=k+length(K_tot);
        try
            waitbar(k/length(I),h,sprintf('Processing Segmentation %i/%i',k,length(I)));
        catch
            h=waitbar(k/length(I),h,sprintf('Processing Segmentation %i/%i',k,length(I)),'Name','Processing Segmentation');
        end
    end
    
end
close(h)
end