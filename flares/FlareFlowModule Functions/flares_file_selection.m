function [filename,flare,flarenames,structSize,path]=flares_file_selection()
[FileName,PathName] = uigetfile('*.mat','Select the mat-file');
if FileName == 0 
    filename=-1;
    flare=-1;
    flarenames=-1;
    structSize=-1;
    return 
else
% Current_folder = pwd;
path = PathName;
filename_w_path = strcat(PathName,FileName);
filename = FileName;
flare = load(filename_w_path);
flarenames = fieldnames(flare);
structSize = length(flarenames);
end
