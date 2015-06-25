function BSD=BSD_selection()
[FileName,PathName] = uigetfile('*.txt','Select the BSD file');
if FileName == 0 
    BSD=-1;
    clc
    return 
else
filename_w_path = strcat(PathName,FileName);
BSD = load(filename_w_path);
clc
end