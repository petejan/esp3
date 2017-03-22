%% splitbeam_angle_to_spherical.m
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
% * |fa|: TODO: write description and info on variable
% * |ps|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |phi|: TODO: write description and info on variable
% * |theta|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-23: header and comments updated (Alex Schimel)
% * 2017-03-22: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [phi, theta] = splitbeam_angle_to_spherical(fa, ps)

%%% Convert angles from cartesian to conical
t1 = tan(ps);
t2 = tan(fa);
phi = atan(sqrt(t1.*t1 + t2.*t2)); % angle off transducer axis
theta = atan2(t1, t2); % rotation about transducer axis

%%% Convert the angles so that we get negative phis to allow for plotting of complete beam pattern slice arcs
i = find(theta < 0);
phi(i) = -phi(i);
theta(i) = pi/2+theta(i);



end