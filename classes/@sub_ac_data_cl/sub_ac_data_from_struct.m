function [subacdata_vec,curr_name]=sub_ac_data_from_struct(data_struct,dir_data,fieldnames)

[~,curr_filename,~]=fileparts(tempname);
curr_name=fullfile(dir_data,curr_filename);

if isempty(fieldnames)
    ff=fields(data_struct);
else
    ff=fieldnames;
end
subacdata_vec=[];

for uuu=1:length(ff)
    if isfield(data_struct,ff{uuu})
        subacdata_vec=[subacdata_vec sub_ac_data_cl(ff{uuu},curr_name,data_struct.(ff{uuu}))];
    end
end

end