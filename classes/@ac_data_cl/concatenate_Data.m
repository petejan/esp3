function data_out=concatenate_Data(data_1,data_2)

if data_1.Time(1)>=data_2.Time(end)
    data_temp=data_1;
    data_1=data_2;
    data_2=data_temp;
end

ff_1=data_1.Fieldname;


new_sub_data=[];

for uuu=1:length(ff_1)
    [idx,found]=find_field_idx(data_2,ff_1{uuu});
    if found
        new_sub_data=[new_sub_data concatenate_SubData(data_1.SubData(uuu),data_2.SubData(idx))];
    else
        data_1.remove_sub_data(ff_1{uuu});
        warning('Cannot find field. This field will not be added.');
    end
end
time=[data_1.Time data_2.Time];
data_out=ac_data_cl('SubData',new_sub_data,...
    'Range',data_1.Range,...
    'Samples',data_1.Samples,...
    'FileId',[data_1.FileId data_2.FileId+nanmax(data_1.FileId)],...
    'Time',time,...
    'Number',[data_1.get_numbers(1) data_1.get_numbers(1)+length(time)-1],...
    'MemapName',[data_1.MemapName data_2.MemapName]);


end