function sheet=reg_output_to_sheet(str_obj)

data_size=size(str_obj.nb_samples);
trans_fields=fieldnames(str_obj);
str_obj_cell=struct2cell(str_obj);
idx_keep=true(size(str_obj.Nb_good_pings));

str_obj_cell_rfmt=cell(nansum(idx_keep(:)),length(trans_fields));

idx_rem=[];
for i=1:size(str_obj_cell,1)
    if contains(lower(trans_fields{i}),'time')
        str_obj_cell{i}=cellfun(@(x) datestr(x,'dd/mm/yyyy HH:MM:SS.FFF'),num2cell(str_obj_cell{i}),'UniformOutput',0);
    end
       
    str_obj_size=size(str_obj_cell{i});
    if ~(str_obj_size(1)==data_size(1))
        str_obj_cell{i}=repmat(str_obj_cell{i},data_size(1),1);
    end
    
    if ~(str_obj_size(2)==data_size(2))
        str_obj_cell{i}=repmat(str_obj_cell{i},1,data_size(2));
    end
    

    if isnumeric(str_obj_cell{i})
        str_obj_cell_rfmt(:,i)=num2cell(str_obj_cell{i}(idx_keep));
    else
        str_obj_cell_rfmt(:,i)=str_obj_cell{i}(idx_keep);
    end
    
end
trans_fields(idx_rem)=[];
sheet=[trans_fields'; str_obj_cell_rfmt];

end