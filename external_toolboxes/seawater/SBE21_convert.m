function [Tcuve, C, S, Tsea] = SBE21_convert(tval, cval, cal_id, t38val);

% aug07 added sbe38 arg;  corrected ITS-68

P = 0;

% Calculate temperature
ft = (tval./19.0)+2100;		% Ref: SBE21 operating manual page 26


switch cal_id;
case 1;
	g = +4.24449510e-03;
	h = +6.49372032e-04;
	i = +2.94134218e-05;
	j = +2.43190871e-06;
	f0 = 1000.0;
case 2;
	g = +4.24536860e-03;
	h = +6.51452362e-04;
	i = +3.11110154e-05;
	j = +2.89502328e-06;
	f0 = 1000.0;
case 3;
   % 21-3145, 11-Jul-02
	g = +4.24523814e-03;
	h = +6.50999811e-04;
	i = +3.07372522e-05;
	j = +2.80453277e-06;
   f0 = 1000.0;
case 4;
   % 21-3145, 22-Jan-03
	g = 4.24578738e-003;
	h = 6.52306519e-004;
	i = 3.17585959e-005;
	j = 3.06597545e-006;
   f0 = 1000.0;
case 5;
   % 21-3145, 22-Dec-05   ITS-90
	g = 4.24580302e-3;
	h = 6.52278425e-004;
	i = 3.17196320e-005;
	j = 3.05226276e-006;
   f0 = 1000.0;
case 6;
   % 21-3145, 22-Dec-05   ITS-68
	g = 3.64763639e-3;
	h = 6.00072617e-004;
	i = 2.29808091e-005;
	j = 3.05444860e-006;
   f0 = 2605.211;
case 7;
    % 3145  16 Jan 08 ITS 68  before IPY
    g=3.64763722e-003;      % a,b,c,d,e in techsas
    h=6.00022330e-004;
    i=2.28839694e-005;
    j=2.94808360e-006;
    f0=2605.088;
end;


lnf = log(f0./ft);

% cuve Temp  ie SBE21 vessel
Tcuve = 1./(g + h.*lnf + i.*lnf.*lnf + j.*lnf.*lnf.*lnf) - 273.15;
% This equation OK for ITS-68 also


if nargin == 4
    % sbe38   sbe21 manual p.32
    % sea temp ie external temp
    disp('nargin==4')
    ft = (t38val./256);
    g = 4.0e-3;
    h = 2.0e-4;
    i = 0.0;
    j = 0.0;
    f0 = 1000.;

    lnf = log(f0./ft);

    Tsea = 1./(g + h.*lnf + i.*lnf.*lnf + j.*lnf.*lnf.*lnf) - 273.15;
% This equation OK for ITS-68 also
else
    Tsea = Tcuve;  
end    


% Calculate Conductivity

switch cal_id;
case 1;
	g = -4.25952854e+00;
	h = +5.03034536e-01;
	i = -3.96764172e-04;
	j = +4.58206388e-05;
	CPcor = -9.57e-08;
	CTcor = +3.25e-06;
case 2;
	g = -4.26629119e+00;
	h = +5.03709634e-01;
	i = -3.39062119e-04;
	j = +4.23616550e-05;
	CPcor = -9.57e-08;
	CTcor = +3.25e-06;
case 3;
   % 21-3145, 11-Jul-02
	g = -4.25992139e+00;
	h = +5.03008956e-01;
	i = -3.68428748e-04;
	j = +4.64515204e-05;
	CPcor = -9.57e-08;
	CTcor = +3.25e-06;
case 4;
   % 21-3145, 22-Jan-03
	g = -4.26092349e+000;
	h = 5.03298824e-001;
	i = -4.46539393e-004;
	j = 4.86696566e-005;
	CPcor = -9.57e-08;
	CTcor = +3.25e-06;
case 5;
   % 21-3145, 22-Dec-05   ITS-90
	g = -4.26601457e+000;
	h = 5.03769923e-001;
	i = -5.21030576e-004;
	j = 5.15456557e-005;
	CPcor = -9.57e-08;
	CTcor = +3.25e-06;
case 6;
   % 21-3145, 22-Dec-05  PSS 1978  a,b,c,s,m
	a = 1.71609855e-006;
	b = 5.01900991e-001;
	c = -4.25783094e000;
	d = -9.06085260e-005;
    m = 5.0;
	CPcor = -9.57e-08;
case 7;
    % 3145  16 Jan 08 ITS 68  before IPY
    a=6.31706123e-006;
    b=5.01103250e-001;
    c=-4.24879688e+000;
    d=-8.50630162e-005;
    m=4.5; 
   	CPcor = -9.57e-08;
end;
    
fc2 = (cval.*2100.0 + 6250000.0)./1e6; % div 1e6 to convert to khz
fc  = sqrt(fc2);

if (cal_id == 6) | 	(cal_id == 7)
  %   
  C = (a*fc.^m + b*fc2 + c + d*Tcuve)./(10.*(1. + CPcor.*P));
else    
  C = (g + h.*fc2 + i.*fc2.*fc + j.*fc2.*fc2)./(10.*(1. + CTcor.*Tcuve + CPcor.*P));
end

%  P in decibar    Old das used 10, not 0  ??????
% This should NOT be Tsea; should be Tcuve
S = sw_salt(C/4.2914, Tsea, P);   % Matlab SeaWater 3 Library
% conductivity ratio  C(S,T,P)/C(35,15(IPTS-68),0)
%"The intl oceanographic community will continue to use T68 for computation
%of salinity etc"
%print "T=", T, "C=", C
%T,C

%%fprintf('Temp= %7.4f  Cond= %7.4f  Salinity= %7.4f\n', T,C,S)


%S = Sal(C, T, P, 1);
%print "Salinity=", S

return;

