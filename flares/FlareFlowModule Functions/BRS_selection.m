function BRS2=BRS_selection()
[FileName,PathName] = uigetfile('*.txt','Select the BRS file');
if FileName == 0 
    BRS2=-1;
    clc
    return 
else
filename_w_path = strcat(PathName,FileName);
BRS2 = load(filename_w_path);
clc
end