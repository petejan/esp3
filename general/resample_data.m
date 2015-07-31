function [data_new,t_new]=resample_data(data,t_old,t)
idx_choice=nan(length(t),1);
for jj=1:length(t)
    [~,idx_choice(jj)]=nanmin(abs(t_old-t(jj)));
end

idx_choice_plus=nanmin(idx_choice+1,length(t_old));
idx_choice_minus=nanmax(idx_choice-1,1);

t_new=1/3*(t_old(idx_choice)+t_old(idx_choice_plus)+t_old(idx_choice_minus));
if nansum((size(t_new)==size(t)))<2
    t=t';
end
if nanmean(abs(t_new-t))<=10*nanmean(abs(diff(t)))
    data_new=1/3*(data(idx_choice)+data(idx_choice_plus)+data(idx_choice_minus));
else
    data_new=[];
    t_new=[];
end

end

