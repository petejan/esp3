%%[phi, theta] = splitbeam_angle_to_spherical(fa, ps)
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
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
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
% Convert the cartesian angles to conical angle.
t1 = tan(ps);
t2 = tan(fa);
phi = atan(sqrt(t1.*t1 + t2.*t2)) ; % angle off transducer axis
theta = atan2(t1, t2); % rotation about transducer axis

% Convert the angles so that we get negative phi's to allow for plotting of
% complete beam pattern slice arcs
i = find(theta < 0);
phi(i) = -phi(i);
theta(i) = pi/2+theta(i);
end