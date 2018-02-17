function reg_output_table_table=reg_output_to_table(str_obj)

data_size=size(str_obj.nb_samples);
str_field=fieldnames(str_obj);


for i=1:numel(str_field)
    tmp=str_obj.(str_field{i});
    
    str_obj_size=size(tmp);
    if contains(lower(str_field{i}),'time')
        tmp=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS.FFF'),num2cell(tmp),'UniformOutput',0);
    end
    
    if ~(str_obj_size(1)==data_size(1))
        tmp=repmat(tmp,data_size(1),1);
    end
    
    if ~(str_obj_size(2)==data_size(2))
        tmp=repmat(tmp,1,data_size(2));
    end
    
    str_obj.(str_field{i})=tmp(:);
end

if all(data_size==1)
    reg_output_table_table=struct2table(str_obj,'asarray',1);
else
    reg_output_table_table=struct2table(str_obj);
end
end