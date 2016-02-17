function sub_out=concatenate_SubData(sub_1,sub_2)

if ~strcmp(sub_1.Fieldname,sub_2.Fieldname)
    warning('Concatenating two different subdataset');
end

sub_out=sub_ac_data_cl(sub_1.Fieldname,'',[]);
sub_out.CaxisDisplay=sub_1.CaxisDisplay;

sub_out.Memap=[sub_1.Memap sub_2.Memap];

end