function struct_out=csv2struct_bis(file)
data_struct=importdata(file);

for i=1:length(data_struct.colheaders)
    struct_out.(strtrim(data_struct.colheaders{i}))=data_struct.data(:,i);
end

end