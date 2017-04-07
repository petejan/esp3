function files=LSSSreader_pairfiles(files)
%
% this function pair snap, work and raw files from the files in the file
% list directories. 
%
% Input:
% files      : Input files
% files.snap : snapfile list (output from "rdir")
% files.work : workfiles list (output from "rdir")
% files.raw  : rawfiles list (output from "rdir")
%
% Output:
% files.F       : List of unique file combinations.
% files.F{i,1}  : Full path to snap file
% files.F{i,2}  : Full path to work file
% files.F{i,3}  : Full path to raw file
%
% The function returns empty if the snap, work or raw file is missing
%
% The function does not handle multiple files with same name in different
% folders.
%


% Combine the files
k = 1;
F={};
F=combinefiles(F,files.snap,1);
F=combinefiles(F,files.work,2);
F=combinefiles(F,files.raw,3);
files.F=F;

function files0 = combinefiles(files0,files,fp)
% List
s=size(files0);
for i=1:length(files)
    file = fullfile(files(i).name);
    [~,filemain,~] = fileparts(file);
    % does the file already exist?
    ex = false;
    for j=1:s(1)
        for l=1:s(2)
            if ~isempty(files0{j,l})
            [~,filemain0,~] = fileparts(files0{j,l});
            if strcmp(filemain,filemain0)
                ex=true;
                files0{j,fp} =file;
            end
            end
        end
    end
    if ~ex
        % Append the file
        files0{s(1)+1,fp} = file;
        s(1)=s(1)+1;
    end
end


