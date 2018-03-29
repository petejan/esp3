function data_out=concatenate_Data(data_1,data_2)

if isempty(data_1)&&isempty(data_2)
    data_out=ac_data_cl.empty();
    return;
end

if isempty(data_2)
    data_out=data_1;
    return;
end

if isempty(data_1)
    data_out=data_2;
    return;
end

new_sub_data=[];
ff_1=data_1.Fieldname;
for uuu=1:length(ff_1)
    [idx,found]=find_field_idx(data_2,ff_1{uuu});
    if found
        new_sub_data=[new_sub_data concatenate_SubData(data_1.SubData(uuu),data_2.SubData(idx))];
    else
        data_1.remove_sub_data(ff_1{uuu});
        warning('Cannot find field. This field will not be added.');
    end
end

data_out=ac_data_cl('SubData',new_sub_data,...
    'Nb_samples',data_1.Nb_samples,...
    'FileId',[data_1.FileId data_2.FileId+nanmax(data_1.FileId)],...
    'Nb_pings',data_1.Nb_pings+data_2.Nb_pings,...
    'MemapName',[data_1.MemapName data_2.MemapName]);


end