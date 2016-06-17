function [filtered_vec] = filter_nan( win,vec )

lar_filt=length(win);
lar_vec=length(vec);
filtered_vec=nan(1,lar_vec);
if lar_vec>=lar_filt
    vec_temp=[fliplr(vec(1:floor((lar_filt+1)/2)-1)) vec fliplr(vec(end-floor((lar_filt+1)/2)+1:end))];   
    for i=1:lar_vec
        filtered_vec(i)=nanmean(vec_temp(i:i+lar_filt-1).*win);
    end
else 
    filtered_vec=nan(1,lar_vec);
end
end

