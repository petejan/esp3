
function dens = sw_dens0(S,T)

% SW_DENS0   Denisty of sea water at atmospheric pressure
%=========================================================================
% SW_DENS0  $Revision: 4775 $  $Date: 2000-03-08 12:07:34 +1300 (Wed, 08 Mar 2000) $
%           Copyright (C) CSIRO, Phil Morgan 1992
%
% USAGE:  dens0 = sw_dens0(S,T)
%
% DESCRIPTION:
%    Density of Sea Water at atmospheric pressure using
%    UNESCO 1983 (EOS 1980) polynomial.
%
% INPUT:  (all must have same dimensions)
%   S = salinity    [psu      (PSS-78)]
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   dens0 = density  [kg/m^3] of salt water with properties S,T,
%           P=0 (0 db gauge pressure)
% 
% AUTHOR:  Phil Morgan 92-11-05  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%     Unesco 1983. Algorithms for computation of fundamental properties of 
%     seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%
%     Millero, F.J. and  Poisson, A.
%     International one-atmosphere equation of state of seawater.
%     Deep-Sea Res. 1981. Vol28A(6) pp625-629.
%=========================================================================

% CALLER: general purpose, sw_dens.m
% CALLEE: sw_smow.m

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
if nargin ~=2
   error('sw_dens0.m: Must pass 2 parameters')
end %if

[mS,nS] = size(S);
[mT,nT] = size(T);

if (mS~=mT) | (nS~=nT)
   error('sw_dens0.m: S,T inputs must have the same dimensions')
end %if

Transpose = 0;
if mS == 1  % a row vector
  S = S(:);
  T = T(:);
  Transpose = 1;
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------
%     UNESCO 1983 eqn(13) p17.

b0 =  8.24493e-1;
b1 = -4.0899e-3;
b2 =  7.6438e-5;
b3 = -8.2467e-7;
b4 =  5.3875e-9;

c0 = -5.72466e-3;
c1 = +1.0227e-4;
c2 = -1.6546e-6;

d0 = 4.8314e-4;

%$$$ dens = sw_smow(T) + (b0 + b1*T + b2*T.^2 + b3*T.^3 + b4*T.^4).*S  ...
%$$$                    + (c0 + c1*T + c2*T.^2).*S.*sqrt(S) + d0*S.^2;

dens = sw_smow(T) + (b0 + (b1 + (b2 + (b3 + b4*T).*T).*T).*T).*S  ...
                   + (c0 + (c1 + c2*T).*T).*S.*sqrt(S) + d0*S.^2;	       

if Transpose
  dens = dens';
end %if

return
%--------------------------------------------------------------------

