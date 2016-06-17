function unused_files=find_unused()

path_echo=whereisEcho();

[files_tot,path_tot]=find_file_recursive(path_echo,'*.m');
echo_files_tot=cellfun(@(x,y) fullfile(x,y),path_tot,files_tot,'UniformOutput',0);

[echo_files,~]=matlab.codetools.requiredFilesAndProducts('EchoAnalysis');
idx_unused=cellfun(@(x) nansum(strcmpi(x,echo_files))==0,echo_files_tot);

unused_files=echo_files_tot(idx_unused);

end