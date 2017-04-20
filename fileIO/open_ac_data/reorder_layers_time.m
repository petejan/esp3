function layers_out=reorder_layers_time(layers_in)

time_in=nan(1,length(layers_in));
for ui=1:length(layers_in)
   time_in(ui)=layers_in(ui).Transceivers(1).Time(1); 
end

[~,idx_sort]=sort(time_in);
layers_out=layers_in(idx_sort);

end