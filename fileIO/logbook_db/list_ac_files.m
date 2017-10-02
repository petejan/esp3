%% list_ac_file_db.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-05-17: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function

function [files,ftype]=list_ac_files(datapath,listonly)

dir_raw=dir(fullfile(datapath,'*.raw'));
dir_asl=dir(fullfile(datapath,'*.*A'));

files=union({dir_raw([dir_raw(:).isdir]==0).name},...
    {dir_asl([dir_asl(:).isdir]==0).name});
ftype=cell(1,numel(files));

if listonly==0
    for ifi=1:numel(files)
        ftype{ifi}=get_ftype(fullfile(datapath,files{ifi}));
    end
    
    idx_rem=strcmpi('unknown',ftype);
    files(idx_rem)=[];
    ftype(idx_rem)=[];
end

end



