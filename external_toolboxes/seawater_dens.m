% seawater_dens.m                                      by:  Edward T Peltzer, MBARI
%                                                  revised:  29 Jan 98.
%
% CALCULATE THE DENSITY OF SEAWATER AT A GIVEN S, T and P.
% Equation of State is from Millero & Poisson (1981) DSR V28: 625-629.
%
% INPUT:       	Salinity (S) in g/kg or psu.
%		Temperature (T) in degrees C.
%		Pressure (P) in decibar.
%
% OUTPUT:	Density [rhp] in KG/M3:
%
%			rhp = seawater_dens(S,T,P).

function [rhp]=seawater_dens(S,T,P)

% DEFINE CONSTANTS FOR EQUATION OF STATE

  R0=+9.99842594E2;
  R1=+6.793952E-2;
  R2=-9.095290E-3;
  R3=+1.001685E-4;
  R4=-1.120083E-6;
  R5=+6.536332E-9;

  A0=+8.24493E-1;
  A1=-4.0899E-3;
  A2=+7.6438E-5;
  A3=-8.2467E-7;
  A4=+5.3875E-9;

  B0=-5.72466E-3;
  B1=+1.0227E-4;
  B2=-1.6546E-6;

  C=+4.8314E-4;

% CALCULATE RHO

    SR=sqrt(S);

    RHO0=R0+T.*(R1+T.*(R2+T.*(R3+T.*(R4+T.*R5))));
    A=A0+T.*(A1+T.*(A2+T.*(A3+T.*A4)));
    B=B0+T.*(B1+T.*B2);

    RHO=RHO0+S.*(A+B.*SR+C.*S);

% DEFINE CONSTANTS FOR SECANT BULK MODULUS

  D0=+1.965221E+4;
  D1=+1.484206E+2;
  D2=-2.327105E+0;
  D3=+1.360477E-2;
  D4=-5.155288E-5;

  E0=+5.46746E+1;
  E1=-6.03459E-1;
  E2=+1.09987E-2;
  E3=-6.1670E-5;

  F0=+7.944E-2;
  F1=+1.6483E-2;
  F2=-5.3009E-4;

  G0=+3.239908E+0;
  G1=+1.43713E-3;
  G2=+1.16092E-4;
  G3=-5.77905E-7;

  H0=+2.2838E-3;
  H1=-1.0981E-5;
  H2=-1.6078E-6;
  H3=+1.91075E-4;

  I0=+8.50935E-5;
  I1=-6.12293E-6;
  I2=+5.2787E-8;

  J0=-9.9348E-7;
  J1=+2.0816E-8;
  J2=+9.1697E-10;

% CORRECT P IN DECI-BARS TO BARS

    Pc=P./10.;

% CALCULATE K

    H=H0+T.*(H1+T.*H2)+H3.*SR;
    J=J0+T.*(J1+T.*J2);

    K1=D0+T.*(D1+T.*(D2+T.*(D3+T.*D4)));
    K2=E0+T.*(E1+T.*(E2+T.*E3));
    K3=F0+T.*(F1+T.*F2);
    K4=G0+T.*(G1+T.*(G2+T.*G3))+S.*H;
    K5=I0+T.*(I1+T.*I2)+S.*J;

    K=K1+S.*(K2+SR.*K3)+Pc.*(K4+Pc.*K5);

% CORRECT FOR PRESSURE

    rhp=RHO.*(1./(1-Pc./K));


   
