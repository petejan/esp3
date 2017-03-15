function shadow_zone_height_est = get_shadow_zone_height_est( trans_obj ,varargin)
% shadow_zone_height_est = get_shadow_zone_height_est( trans_obj)
%
% DESCRIPTION
%
% Gives a shadow zone height estimation
%
% USE
%
% PROCESSING SUMMARY
%
% INPUT VARIABLES
%
% - trans_obj: transceiver_cl
%       
% OUTPUT VARIABLES
%
% shadow_zone_height_est : shadow zone height estimation
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% 2017-03-15: first version.
% EXAMPLE
%
%
%%%
% Yoann Ladroit& NIWA
%%%


p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));

parse(p,trans_obj,varargin{:});
faBW=trans_obj.Config.BeamWidthAlongship;
psBW=trans_obj.Config.BeamWidthAthwartship;
beam_angle=nanmean(faBW+psBW)/2;

bot_range=trans_obj.get_bottom_range();

slope_est=trans_obj.get_slope_est();

shadow_zone_height_est=2*abs(tand(slope_est)).*(bot_range*sind(beam_angle/2));