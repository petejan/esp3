

function candidates=find_candidates_v3(Mask,range,dist_pings,l_min_can,h_min_can,min_nb_sples,output,load_bar_comp)


[nb_row,~]=size(Mask);

CC = bwconncomp(Mask==1);
num_can=CC.NumObjects;
candidates_idx=CC.PixelIdxList;
switch output
    case 'mat'
        candidates=zeros(size(Mask));
    case 'cell'
        candidates=cell(1,num_can);
end

if ~isempty(load_bar_comp)
    load_bar_comp.status_bar.setText('Finding Candidates');
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_can, 'Value',0);
end
region_number=1;

for i=1:num_can
    if mod(i,floor(num_can/100))==1
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_can, 'Value',i);
        end
    end
    curr_candidate=candidates_idx{i};
    if length(curr_candidate)>min_nb_sples
        row_idx=rem(curr_candidate,nb_row);
        row_idx(row_idx==0)=nb_row;
        col_idx=ceil(curr_candidate/nb_row);
        
        if abs(nanmax(dist_pings(col_idx))-nanmin(dist_pings(col_idx)))>=l_min_can...
                &&abs(nanmax(range(row_idx))-nanmin(range(row_idx)))>=h_min_can
            
            switch output
                case 'mat'
                    candidates(curr_candidate)=region_number;
                    region_number=region_number+1;
                case 'cell'
                    candidates{i}=curr_candidate;
            end
            if mod(num_can,i)==10
                
            end
        end
    end
    
end

switch output
    case 'cell'
        candidates(cellfun(@isempty,candidates))=[];
end

end