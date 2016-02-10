function load_bot_regs(layer)

for uui=1:length(layer.Frequencies)
    layer.Transceivers(uui).rm_all_region();
end

[path_xml,reg_file_str,bot_file_str,i_file_str]=layer.create_files_str();

if exist(fullfile(path_xml,reg_file_str),'file')>0
    layer.add_regions_from_reg_xml(fullfile(path_xml,reg_file_str));
else
    warning('No region files for this layer');
end


end