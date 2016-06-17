function [phi, theta] = simradAnglesToSpherical(fa, ps)
% Convert the cartesian angles to conical angle.
t1 = tan(ps * pi/180);
t2 = tan(fa * pi/180);
phi = atan(sqrt(t1.*t1 + t2.*t2)) * 180/pi; % angle off transducer axis
theta = atan2(t1, t2) * 180/pi; % rotation about transducer axis

% Convert the angles so that we get negative phi's to allow for plotting of
% complete beam pattern slice arcs
i = find(theta < 0);
phi(i) = -phi(i);
theta(i) = 180+theta(i);
end