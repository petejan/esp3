%% set_region_colors.m
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
% * |curr_dispCmap|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |ac_data_col|: TODO: write description and info on variable
% * |ac_bad_data_col|: TODO: write description and info on variable
% * |in_data_col|: TODO: write description and info on variable
% * |in_bad_data_col|: TODO: write description and info on variable
% * |txt_col|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * 2017-03-29: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [ac_data_col,ac_bad_data_col,in_data_col,in_bad_data_col,txt_col]=set_region_colors(curr_dispCmap)

switch curr_dispCmap
    case 'esp2'
        
        txt_col='w';
    otherwise
        txt_col='k';
end

ac_data_col=[1 0 0];
in_bad_data_col=[240,200,140]/256;
in_data_col=[0 0.8 0];
ac_bad_data_col=[0.5 0.5 0];

end