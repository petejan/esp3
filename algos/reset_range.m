%% reset_range.m
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
% * |algo_vec|: TODO: write description and info on variable
% * |range|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |algo_vec|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function algo_vec=reset_range(algo_vec,range)

for i=1:length(algo_vec)
    switch algo_vec(i).Name
        case {'BottomDetectionV2'}
            algo_vec(i).Varargin.r_min=range(2);
            algo_vec(i).Varargin.r_max=range(end-1);
        case {'BottomDetection', 'BadPings'}
            algo_vec(i).Varargin.r_min=range(2);
            algo_vec(i).Varargin.r_max=range(end-1);
            algo_vec(i).Varargin.vert_filt=range(end)/50;
    end
end

end