% Vsnd_un95.m                                      by:  Edward T Peltzer, MBARI
%                                                  revised:  2015 Apr 10.
%
% CALCULATE SPEED OF SOUND IN SEAWATER AS A FUNCTION OF S, T & P USING THE
%   UNESCO 1995 EQUATION
%
% Source: Wong and Zhu (1995) "Speed of sound in seawater as a function of salinity,
%         temperature and pressure." J. Acoust. Soc. Am. 97: 1732-1736.
%
% Input:    S = Salinity (pss-78).
%           T = Temperature (deg C).
%           P = Pressure in decibars.
%
% Output:   Speed of sound in seawater (m/sec).
%
%             Vsnd = Vsnd_un95(S,T,P).
%
% CHECKVALUES
%
%    for Vsnd UNESCO 1995: Vsnd=1732.0175 M/S  @  S=40, T=40 DEG C, P=10000 DBAR.

function Vsnd = seawater_svel_un95(S,T,P)
     
% This is copied directly from the UNESCO algorithmms, with some minor changes
% (like adding ";" and changing "*" to ".*") for Matlab.

% SCALE PRESSURE TO BARS

    P_bar=P/10.;
      
% CALCULATE SQUARE-ROOT OF SALINITY

    SR = sqrt(abs(S));
      
% DEFINE COEFFICIENTS from Wong & Zhu (1995)

    A00 = 1.389;
    A01 = -1.262E-2;
    A02 = 7.166E-5;
    A03 = 2.008E-6;
    A04 = -3.21E-8;
    A10 = 9.4742E-5;
    A11 = -1.2583E-5;
    A12 = -6.4928E-8;
    A13 = 1.0515E-8;
    A14 = -2.0142E-10;
    A20 = -3.9064E-7;
    A21 = 9.1061E-9;
    A22 = -1.6009E-10;
    A23 = 7.994E-12;
    A30 = 1.100E-10;
    A31 = 6.651E-12;
    A32 = -3.391E-13;
    B00 = -1.922E-2;
    B01 = -4.42E-5;
    B10 = 7.3637E-5;
    B11 = 1.7950E-7;
    C00 = 1402.388;
    C01 = 5.03830;
    C02 = -5.81090E-2;
    C03 = 3.3432E-4;
    C04 = -1.47797E-6;
    C05 = 3.1419E-9;
    C10 = 0.153563;
    C11 = 6.8999E-4;
    C12 = -8.1829E-6;
    C13 = 1.3632E-7;
    C14 = -6.1260E-10;
    C20 = 3.1260E-5;
    C21 = -1.7111E-6;
    C22 = 2.5986E-8;
    C23 = -2.5353E-10;
    C24 = 1.0415E-12;
    C30 = -9.7729E-9;
    C31 = 3.8513E-10;
    C32 = -2.3654E-12;
    D00 = 1.727E-3;
    D10 = -7.9836E-6;

% CALCULATE TERMS

    A0 = (((A04.*T + A03).*T + A02).*T + A01).*T + A00;
    A1 = (((A14.*T + A13).*T + A12).*T + A11).*T + A10;
    A2 = ((A23.*T + A22).*T + A21).*T + A20;
    A3 = (A32.*T + A31).*T + A30;
    A_TP = ((A3.*P_bar + A2).*P_bar + A1).*P_bar + A0;

    B_TP = B00 + B01.*T + (B10 + B11.*T).*P_bar;

    C0 = ((((C05.*T + C04).*T + C03).*T + C02).*T + C01).*T + C00;
    C1 = (((C14.*T + C13).*T + C12).*T + C11).*T + C10;
    C2 = (((C24.*T + C23).*T + C22).*T + C21).*T + C20;
    C3 = (C32.*T + C31).*T + C30;
    C_TP = ((C3.*P_bar + C2).*P_bar + C1).*P_bar + C0;
    
    D_TP = D10.*P_bar + D00;

% CALCULATE SOUND SPEED

      Vsnd = C_TP + (A_TP + B_TP .* SR + D_TP.*S).*S;
      
end
