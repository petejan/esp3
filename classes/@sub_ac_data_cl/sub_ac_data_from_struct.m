function [subacdata_vec,curr_name]=sub_ac_data_from_struct(data_struct,dir_data,fieldnames)

[~,curr_filename,~]=fileparts(tempname);
curr_name=fullfile(dir_data,curr_filename);

if isempty(fieldnames)
    ff=fields(data_struct);
else
    ff=fieldnames;
end

subacdata_vec(length(ff))=sub_ac_data_cl();

for uuu=1:length(ff)
    if isfield(data_struct,ff{uuu})
        subacdata_vec(uuu)=sub_ac_data_cl('field',ff{uuu},'memapname',curr_name,'data',data_struct.(ff{uuu}));
    end
end

end