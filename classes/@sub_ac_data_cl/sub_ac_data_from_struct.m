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

% 
% format_test={};
% 
% fileID_test = fopen(curr_name,'w+');
% for uuu=1:length(ff)
%     if ~isempty(data_struct.(ff{uuu}))
%         format_test=[format_test;{'single',size(data_struct.(ff{uuu})),ff{uuu}}];
%         fwrite(fileID_test,single(data_struct.(ff{uuu})),'single');
%     end
% end
% fclose(fileID_test);
% memmap_test= memmapfile(curr_name,...
%     'Format',format_test,'repeat',1,'writable',true);
% 
% disp('test');
end