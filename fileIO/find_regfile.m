function reg_filename=find_regfile(path,file)

reg_filename=fullfile(path,'echoanalysisfiles',[file '.mat']);
if ~(exist(reg_filename,'file')==2)
    reg_filename=[];
    return;
end
