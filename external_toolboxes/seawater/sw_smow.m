
function dens = sw_smow(T)

% SW_SMOW    Denisty of standard mean ocean water (pure water)
%=========================================================================
% SW_SMOW  $Revision: 4775 $  $Date: 2000-03-08 12:07:34 +1300 (Wed, 08 Mar 2000) $
%          Copyright (C) CSIRO, Phil Morgan 1992.
%
% USAGE:  dens = sw_smow(T)
%
% DESCRIPTION:
%    Denisty of Standard Mean Ocean Water (Pure Water) using EOS 1980. 
%
% INPUT: 
%   T = temperature [degree C (IPTS-68)]
%
% OUTPUT:
%   dens = density  [kg/m^3] 
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
%     UNESCO 1983 p17  Eqn(14)
%
%     Millero, F.J & Poisson, A.
%     INternational one-atmosphere equation of state for seawater.
%     Deep-Sea Research Vol28A No.6. 1981 625-629.    Eqn (6)
%=========================================================================

%----------------------
% CHECK INPUT ARGUMENTS
%----------------------
% TEST INPUTS
if nargin ~= 1
   error('sw_smow.m: Only one input argument allowed')
end %if

Transpose = 0;
[mT,nT] = size(T);
if mT == 1 % a row vector
   T = T(:);
   Tranpose = 1;
end %if

%----------------------
% DEFINE CONSTANTS
%----------------------
a0 = 999.842594;
a1 =   6.793952e-2;
a2 =  -9.095290e-3;
a3 =   1.001685e-4;
a4 =  -1.120083e-6;
a5 =   6.536332e-9;

dens = a0 + (a1 + (a2 + (a3 + (a4 + a5*T).*T).*T).*T).*T;

if Transpose
  dens = dens';
end %if

return
%--------------------------------------------------------------------

