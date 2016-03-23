
function S = sw_sals(Rt,T)

% SW_SALS    Salinity of sea water
%=========================================================================
% SW_SALS  $Revision: 4775 $  $Date: 2000-03-08 12:07:34 +1300 (Wed, 08 Mar 2000) $
%          Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  S = sw_sals(Rt,T)
%
% DESCRIPTION:
%    Salinity of sea water as a function of Rt and T.  
%    UNESCO 1983 polynomial.
%
% INPUT:
%   Rt = Rt(S,T) = C(S,T,0)/C(35,T,0)
%   T  = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   S  = salinity    [psu      (PSS-78)]
% 
% AUTHOR:  Phil Morgan 93-04-17  (morgan@ml.csiro.au)
%
% DISCLAIMER:
%   This software is provided "as is" without warranty of any kind.  
%   See the file sw_copy.m for conditions of use and licence.
%
% REFERENCES:
%    Fofonoff, P. and Millard, R.C. Jr
%    Unesco 1983. Algorithms for computation of fundamental properties of 
%    seawater, 1983. _Unesco Tech. Pap. in Mar. Sci._, No. 44, 53 pp.
%=========================================================================

% CALLER: sw_salt
% CALLEE: none

%--------------------------
% CHECK INPUTS
%--------------------------
if nargin~=2
  error('sw_sals.m: requires 2 input arguments')
end %if

[mrt,nrt] = size(Rt);
[mT,nT]   = size(T);
if ~(mrt==mT | nrt==nT)
   error('sw_sals.m: Rt and T must have the same shape')
end %if

%--------------------------
% eqn (1) & (2) p6,7 unesco
%--------------------------
a0 =  0.0080;
a1 = -0.1692;
a2 = 25.3851;
a3 = 14.0941;
a4 = -7.0261;
a5 =  2.7081;

b0 =  0.0005;
b1 = -0.0056;
b2 = -0.0066;
b3 = -0.0375;
b4 =  0.0636;
b5 = -0.0144;

k  =  0.0162;

Rtx   = sqrt(Rt);
del_T = T - 15;
del_S = (del_T ./ (1+k*del_T) ) .* ...
        ( b0 + (b1 + (b2+ (b3 + (b4 + b5.*Rtx).*Rtx).*Rtx).*Rtx).*Rtx);
	
S = a0 + (a1 + (a2 + (a3 + (a4 + a5.*Rtx).*Rtx).*Rtx).*Rtx).*Rtx;

S = S + del_S;

return
%----------------------------------------------------------------------
