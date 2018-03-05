function subacdata_vec=sub_ac_data_from_files(dfiles,dsize,fields)
ff=fields;
%subacdata_vec(length(ff))=sub_ac_data_cl();

for uuu=1:length(ff)
    subacdata_vec(uuu)=sub_ac_data_cl('field',ff{uuu},'datasize',dsize,'data',dfiles(uuu));
end

end