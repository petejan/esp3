function sheet=struct_to_sheet(str_obj)

str_obj_cell=struct2cell(str_obj);
str_obj_cell_rfmt=cell(length(str_obj_cell),length(str_obj_cell{1}));

trans_fields=fieldnames(str_obj);
idx_rem=[];
for i=1:size(str_obj_cell,1)
    
    
%     if numel(str_obj_cell{i})>1
%         idx_rem=union(idx_rem,i);
%         continue;
%     end
    
    if contains(lower(trans_fields{i}),'time')
        str_obj_cell{i}=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS.FFF'),num2cell(str_obj_cell{i}),'UniformOutput',0);
    end
    
    if isnumeric(str_obj_cell{i})
        str_obj_cell_rfmt(i,:)=num2cell(str_obj_cell{i});
    else
        str_obj_cell_rfmt(i,:)=str_obj_cell{i};
    end
    
end
trans_fields(idx_rem)=[];
sheet=[trans_fields str_obj_cell_rfmt];

end