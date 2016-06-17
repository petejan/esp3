function [data_new,t_new,idx_choice]=find_nearest(data,t_old,t)
idx_choice=nan(length(t),1);
for jj=1:length(t)
    [~,idx_choice(jj)]=nanmin(abs(t_old-t(jj)));
end

t_new=t_old(idx_choice);
data_new=data(idx_choice);


end

