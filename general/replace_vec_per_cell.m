function cell_vals=replace_vec_per_cell(vec_vals)
temp=cell(size(vec_vals));
for i=1:length(vec_vals)
    if isnumeric(vec_vals(i))
        temp{i}=num2str(vec_vals(i),'%.0f');
    else
        temp{i}='';
    end
end
cell_vals=temp;
end
