function [data_cell,idx_pings_cell]=divide_mat_v2(data,nb_samples,nb_pings,idx_pings)

data_cell=cell(1,length(nb_samples));
idx_pings_cell=cell(1,length(nb_samples));

if isempty(idx_pings)
    idx_pings=1:nansum(nb_pings);
end

for i=1:length(nb_pings)
    if i==1
        ipings=1:nb_pings(1);
    else
        ping_start=nansum(nb_pings(1:i-1))+1;
        ping_end=nansum(nb_pings(1:i));
        ipings=ping_start:ping_end;
    end
    [~,idx_pings_cell{i},idx_ping_tmp]=intersect(ipings,idx_pings);
    
    data_cell{i}=data(1:nb_samples(i),idx_ping_tmp);

end
    

end