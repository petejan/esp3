
function Rp = sw_salrp(R,T,P)

% SW_SALRP   Conductivity ratio   Rp(S,T,P) = C(S,T,P)/C(S,T,0)
%=========================================================================
% SW_SALRP   $Revision: 4775 $  $Date: 2000-03-08 12:07:34 +1300 (Wed, 08 Mar 2000) $
%            Copyright (C) CSIRO, Phil Morgan 1993.
%
% USAGE:  Rp = sw_salrp(R,T,P)
%
% DESCRIPTION:
%    Equation Rp(S,T,P) = C(S,T,P)/C(S,T,0) used in calculating salinity.
%    UNESCO 1983 polynomial.
%
% INPUT: (All must have same shape)
%   R = Conductivity ratio  R =  C(S,T,P)/C(35,15,0) [no units]
%   T = temperature [degree C (IPTS-68)]
%   P = pressure    [db]
%
% OUTPUT:
%   Rp = conductivity ratio  Rp(S,T,P) = C(S,T,P)/C(S,T,0)  [no units] 
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

%-------------------
% CHECK INPUTS
%-------------------
if nargin~=3
  error('sw_salrp.m: requires 3 input arguments')
end %if

[mr,nr] = size(R);
[mp,np] = size(P);
[mt,nt] = size(T);
if ~(mr==mp | mr==mt | nr==np | nr==nt)
   error('sw_salrp.m: R,T,P must all have the same shape')
end %if   

%-------------------
% eqn (4) p.8 unesco.
%-------------------
d1 =  3.426e-2;
d2 =  4.464e-4;
d3 =  4.215e-1;
d4 = -3.107e-3;

e1 =  2.070e-5;
e2 = -6.370e-10;
e3 =  3.989e-15;

Rp = 1 + ( P.*(e1 + e2.*P + e3.*P.^2) ) ...
     ./ (1 + d1.*T + d2.*T.^2 +(d3 + d4.*T).*R);
 
return
%-----------------------------------------------------------------------

