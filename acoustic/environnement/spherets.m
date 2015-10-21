function [ts, form] = spherets(k, a, c, c1, c2, rho, rho1)
% [ts, form] = spherets(k, a, c, c1, c2, rho, rho1)
%
% Calculates the form function as defined be equations
% 6 to 9 in: 
% MacLennan, D.N., 1981. The Theory of Solid Spheres 
% as Sonar Calibration Targets. 22, Department of 
% Agriculture and Fisheries for Scotland. 
%
% Input variables are:
% k - wavenumber, [1/m]
% a - sphere radius [m]
% c - sound velocity in water [m/s]
% c1 - longitudinal sound velocity in sphere [m/s]
% c2 - transverse sound velocity in sphere [m/s]
% rho - density of water [kg/m^3]
% rho1 - density of sphere [kg/m^3]
% 
% The input variables can be all scalars or all vectors
% (of the same size).
% The relationship for the derivatives of the bessel
% functions are from Rudgers, A.J., 1967. Techniques 
% for Numerically Evaluating the Formulas Describing 
% Monostatic Reflection of Acoustic Waves by Elastic 
% Spheres. NRL Report 6551, Acoustic Research Branch, 
% Sound Division, Naval Research Laboratory.
%
% Gavin Macaulay, November 1998
% $Id: spherets.m 5301 2003-08-20 21:14:43Z gjm $
q = k.*a;
q1 = q .* c ./ c1;
q2 = q .* c ./ c2;
alpha = 2.0 * (rho1 ./ rho) .* ((c2 ./ c) .^ 2.0);
beta = (rho1 ./ rho) .* ((c1 ./ c) .^ 2.0) - alpha;
form = 0;
tol = 0.0000000001;
pi2 = pi / 2;

for l = 0:50
   j_q =   besselj(l+0.5, q) .* sqrt(pi2 ./ q);
   jm1_q = besselj(l-.5, q) .* sqrt(pi2 ./ q);
   j_qd = jm1_q - (l+1) ./ q .* j_q;
   j_q1 =   besselj(l+0.5, q1) .* sqrt(pi2 ./ q1);
   jm1_q1 = besselj(l-0.5, q1) .* sqrt(pi2 ./ q1);
   j_q1d = jm1_q1 - (l+1) ./ q1 .* j_q1;
   j_q1dd = 1 ./ (q1.*q1) .* ((l+1)*(l+2) - q1.*q1) .* j_q1 - 2 ./ q1 .* jm1_q1;
   j_q2 =   besselj(l+0.5, q2) .* sqrt(pi2 ./ q2);
   jm1_q2 = besselj(l-0.5, q2) .* sqrt(pi2 ./ q2);
   j_q2d = jm1_q2 - (l+1) ./ q2 .* j_q2;
   j_q2dd = 1 ./ (q2.*q2) .* ((l+1)*(l+2) - q2.*q2) .* j_q2 - 2 ./ q2 .* jm1_q2;
   
   y_q =   bessely(l+0.5, q) .* sqrt(pi2 ./ q);
   yp1_q = bessely(l+1.5, q) .* sqrt(pi2 ./ q);
   y_qd = l ./ q .* y_q - yp1_q;
   A2 = (l*l + l - 2) .* j_q2 + q2 .* q2 .* j_q2dd;
   A1 = 2*l*(l+1) * (q1 .* j_q1d - j_q1);
   B2 = A2 .* q1.*q1 .* (beta .* j_q1 - alpha .* j_q1dd) - A1 .* alpha .* (j_q2 - q2 .* j_q2d);
   B1 = q .* (A2 .* q1 .* j_q1d - A1 .* j_q2);
   neta = atan(-(B2 .* j_qd - B1 .* j_q)./(B2 .* y_qd - B1 .* y_q));
   newterm = (-1)^l * (2*l+1) * sin(neta) .* exp((0+i) * neta);
   form = form + newterm;
   if (abs(newterm)./abs(form) < tol) 
      break;
  end
end
form = -(2.0 ./ q) .* form;
sigma = pi * a.*a .* abs(form) .* abs(form);
ts = 10 * log10(sigma / (4*pi));
