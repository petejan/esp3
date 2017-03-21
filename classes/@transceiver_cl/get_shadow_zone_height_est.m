%% get_shadow_zone_height_est.m
%
% Gives a shadow zone height estimation
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
%
% *OUTPUT VARIABLES*
%
% * |shadow_zone_height_est|: Shadow zone height estimation
% * |slope_est|: TODO
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-15: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [shadow_zone_height_est,slope_est] = get_shadow_zone_height_est( trans_obj ,varargin)

% Checking and parsin input variables
p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
parse(p,trans_obj,varargin{:});


faBW=trans_obj.Config.BeamWidthAlongship;
psBW=trans_obj.Config.BeamWidthAthwartship;
beam_angle=nanmean(faBW+psBW)/2;
[slope_est,~]=trans_obj.get_slope_est();
bot_range=trans_obj.get_bottom_range();

%shadow_zone_height_est=2*abs(tand(slope_est)).*(bot_range*sind(beam_angle/2));

shadow_zone_height_est=zeros(size(slope_est));

beta=abs(slope_est(abs(slope_est)>beam_angle));
shadow_zone_height_est(abs(slope_est)>beam_angle)=(1.264 - 0.216*beta +...
    0.262*beta.^2 - 0.01382*beta.^3 + 0.0002686*beta.^4);

beta=abs(slope_est(abs(slope_est)<=beam_angle));
shadow_zone_height_est(abs(slope_est)<=beam_angle)=(1.2 + 0.16*beta.^2);
shadow_zone_height_est=shadow_zone_height_est.*bot_range*1e-3;



