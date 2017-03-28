function reg_table_data_new=update_reg_data_table(regions,reg_table_data)

nb_regions=length(regions);
reg_table_data_new=cell(nb_regions,10);

for i=1:length(regions)
    if~isempty(reg_table_data)
        idx_mod=find([reg_table_data{:,10}]==regions(i).Unique_ID);
    else
        idx_mod=[];
    end
    
    if ~isempty(idx_mod)
        reg_table_data(idx_mod,:)=[];
    end
    
    reg_table_data_new{i,1}=regions(i).Name;
    reg_table_data_new{i,2}=regions(i).ID;
    reg_table_data_new{i,3}=regions(i).Tag;
    reg_table_data_new{i,4}=regions(i).Type;
    reg_table_data_new{i,5}=regions(i).Reference;
    reg_table_data_new{i,6}=regions(i).Cell_w;
    reg_table_data_new{i,7}=regions(i).Cell_w_unit;
    reg_table_data_new{i,8}=regions(i).Cell_h;
    reg_table_data_new{i,9}=regions(i).Cell_h_unit;
    reg_table_data_new{i,10}=regions(i).Unique_ID;
end

reg_table_data_new=[reg_table_data;reg_table_data_new];

[~,idx_sort]=sort([reg_table_data_new{:,10}]);
reg_table_data_new=reg_table_data_new(idx_sort,:);
end