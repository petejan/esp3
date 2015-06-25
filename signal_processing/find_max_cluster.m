function main_idx_thr_db=find_max_cluster(idx_thr_db,amp,lar)


if length(lar)>=2
    lar_min=lar(1);
    lar_max=nanmax([4*lar_min lar(2)]);
else
    lar_min=lar;
end

[nb_samples,nb_beams]=size(idx_thr_db);
main_idx_thr_db=zeros(nb_samples,nb_beams);
idx_thr_db=floor(filter2(ones(lar_min,1),idx_thr_db,'same')./filter2(ones(lar_min,1),ones(size(idx_thr_db)),'same'));
idx_thr_db=ceil(filter2(ones(lar_min,1),idx_thr_db,'same')./filter2(ones(lar_min,1),ones(size(idx_thr_db)),'same'));

idx_thr_db_2=floor(filter2(ones(lar_max,1),idx_thr_db,'same')./filter2(ones(lar_max,1),ones(size(idx_thr_db)),'same'));
idx_thr_db_2=ceil(filter2(ones(lar_max,1),idx_thr_db_2,'same')./filter2(ones(lar_max,1),ones(size(idx_thr_db)),'same'));

idx_thr_db=idx_thr_db&(~idx_thr_db_2);

amp(idx_thr_db==0)=nan;
[~,idx_max]=nanmax(amp);

for i=1:nb_beams
    i_min=idx_max(i);
    i_max=idx_max(i);
    
    while i_min>0&&idx_thr_db(i_min,i)==1
        main_idx_thr_db(i_min,i)=1;
        i_min=i_min-1;
    end
   
    while i_max<=nb_samples&&idx_thr_db(i_max,i)==1
        main_idx_thr_db(i_max,i)=1;
        i_max=i_max+1;
    end  
  
end

