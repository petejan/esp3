function sheet=struct_to_sheet(str_obj)

str_obj_cell=struct2cell(str_obj);
str_obj_cell_rfmt=cell(length(str_obj_cell),length(str_obj_cell{1}));

trans_fields=fieldnames(str_obj);
for i=1:size(str_obj_cell,1)
    
    if ~isempty(strfind(trans_fields{i},'time'))
        str_obj_cell{i}=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS'),num2cell(str_obj_cell{i}),'UniformOutput',0);
    end
    
    if isnumeric(str_obj_cell{i})
        str_obj_cell_rfmt(i,:)=num2cell(str_obj_cell{i});
    else
        str_obj_cell_rfmt(i,:)=str_obj_cell{i};
    end
    
end
sheet=[fieldnames(str_obj) str_obj_cell_rfmt];

end