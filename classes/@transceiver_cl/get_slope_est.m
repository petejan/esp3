%% get_slope_est.m
%
% Gives a slope estimation of the bottom measured on the associated
% transducer using the depth line as reference
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |trans_obj|: Object of class |transceiver_cl| (Required)
% * |FilterWidth|: Filter width (in meters) for smoothing bottom and vessel
% distance (Optional. Num. Default: |100|). 
%
% *OUTPUT VARIABLES*
%
% * |shadow_zone_height_est|: Shadow zone height estimation
% * |slope_est|: TODO

% * |slope_est|: estimated slope
% * |bot_depth|: bottom range corrected from transducer depth
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (alex)
% % 2017-03-15: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [slope_est,bot_depth] = get_slope_est( trans_obj,varargin )

%% Checking and parsing inputs
p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addParameter(p,'FiltWidth',100,@isnumeric);
parse(p,trans_obj,varargin{:});

results=p.Results;
bot_depth=trans_obj.get_bottom_depth();


dist_vessel=trans_obj.get_dist();

[counts,hist_diff]=hist(diff(dist_vessel));
[~,idx]=nanmax(counts);
s_width=results.FiltWidth/(hist_diff(idx));

bot_data_filt=smooth(bot_depth(:),s_width);
dist_vessel_filt=smooth(dist_vessel(:),s_width);
%dist_vessel_filt(diff(dist_vessel_filt)<hist_diff(idx)/4)=nan;
slope_est=nan(size(bot_depth));
slope_est(1:end-1)=atand(diff(bot_data_filt(:)')./diff(dist_vessel_filt(:)'));
