

function candidates=find_candidates_v2(Mask,range_mat,dist_pings_mat,l_min_can,h_min_can,min_nb_sples)

candidates=zeros(size(Mask));
[full_candidates, num_can] = bwlabeln(Mask==1);


k=1;
h=waitbar(k/num_can,sprintf('Processing Segmentation %.0f/%i',k/num_can*100,100),'Name','Processing Segmentation');
region_number=1;


for i=1:num_can
    curr_candidate=find(full_candidates==i);
    dist=dist_pings_mat(curr_candidate);
    range=range_mat(curr_candidate);
    if ((nanmax(dist)-nanmin(dist)>=l_min_can )...
&&(nanmax(range)-nanmin(range)>=h_min_can) ...
&& (length(curr_candidate)>min_nb_sples))

        candidates(curr_candidate)=region_number;       
        region_number=region_number+1;
        
        try
            waitbar(i/num_can,h,sprintf('Processing Segmentation %.0f/%i',i/num_can*100,100));
        catch
            h=waitbar(i/num_can,sprintf('Processing Segmentation %.0f/%i',i/num_can*100,100),'Name','Processing Segmentation');
        end
    end
    
end

close(h)
end