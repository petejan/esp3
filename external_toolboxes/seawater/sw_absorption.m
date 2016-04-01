function alpha = sw_absorption(f, S, T, D, method)

% function alpha = sw_absorption(f, S, T, D, method)
%
% Returns the Absorption coefficient [dB/km] for
% the given acoustic frequency (f [kHz]), salinity
% (S, [ppt]), temperature (T, [degC]), and depth
% (D, [m]).
%
% Note that the salinity units are ppt, not the more
% modern psu. See the comment on page 2 of Doonan et al.
% for a discussion of this. For most purposes, using psu
% values in place of ppt will make no difference to the
% resulting alpha value.
%
% Will work correctly with vector inputs for S, T,
% and D.
%
% By default function implements the formula given in
% Doonan, I.J.; Coombs, R.F.; McClatchie, S. (2003).
% The Absorption of sound in seawater in relation to
% estimation of deep-water fish biomass. ICES
% Journal of Marine Science 60: 1-9.
%
% Note that the paper has two errors in the formulae given
% in the conclusions.
%
% Optional argument 'method', allows the user to specify the
% Absorption formula to use. Default is Doonan etal (2003)
% other possibilities are:
% 'doonan'  - Doonan et al (2003)
% 'fandg'   - Francois & Garrison (1982)
% 'fands'   - Fisher & Simmonds(1977) - not yet implemented

% Written by Gavin Macaulay, August 2003
% $Id: sw_absorption.m 7191 2015-04-01 18:59:49Z ladroity $

% checks on valid inputs

if nargin < 5
    method = 'doonan';
end

if isempty(T) || isempty(D) || isempty(S)
    disp('The length of the T, D, and S parameters must be greater than 0')
    alpha = [];
    return
end

error = 0;
if (f < 10 || f > 120) && (nargin < 5 || strcmp(method,'doonan'))
    disp('The formula is only valid for frequencies between 10 and 120 kHz.')
    disp('Try the Francois & Garrison formula')
    error = 1;
end

if (max(T) > 20) && (nargin < 5 || strcmp(method,'doonan'))
    disp('The formula is only valid for temperatures less than 20 deg C')
    disp('Try the Francois & Garrison formula')
    error = 1;
end

if error == 1
    return
end

% Turn S, T, and D into column vectors, and check that they
% are vectors.
if size(S,1) == 1
    S = S';
end
if size(T,1) == 1
    T = T';
end
if size(D,1) == 1
    D = D';
end

if strcmpi(method,'doonan')
    c = 1412 + 3.21*T + 1.19*S + 0.0167*D;
    A2 = 22.19 * S .* (1.0 + 0.017 * T);
    f2 = 1.8 * 10.^(7.0 - 1518./(T+273));
    P2 = exp(-1.76e-4*D);
    A3 = 4.937e-4 - 2.59e-5*T + 9.11e-7*T.*T - 1.5e-8*T.*T.*T;
    P3 = 1.0 - 3.83e-5*D + 4.9e-10*D.*D;
    
    alpha = A2.*P2.*f2*f*f./(f2.*f2 + f*f) ./ c + A3.*P3.*f*f;
elseif strcmpi(method,'fandg')
    %Francois & Garrison need pH
    %Assume 8 for seawater and 7 for freshwater
    pH = 8;
    if mean(S) < 10
        warning('Assuming pH of 7 for freshwater');
        pH = 7;
    end
    c = 1412 + 3.21*T + 1.19*S + 0.0167*D;
    A1 = 8.86 * (10.^(0.78*pH - 5)) ./ c;
    A2 = 21.44 * S .* (1 + 0.025 * T) ./ c;
    A3 = 4.937e-4 - 2.59e-5*T + 9.11e-7*T.*T - 1.5e-8*T.*T.*T;
    Tidx = find(T > 20);
    A3(Tidx) = 3.964e-4 - 1.146e-5*T(Tidx) + 1.45e-7*T(Tidx).*T(Tidx) - 6.5e-10*T(Tidx).*T(Tidx).*T(Tidx);
    f1 = 2.8 * sqrt(S/35) .* (10.^(4 - 1245./(T+273)));
    f2 = (8.17 * 10 .^(8 - 1990./(T+273))) ./ (1+0.0018*(S-35));
    P2 = 1.0 - 1.37e-4*D + 6.2e-9*D.*D;
    P3 = 1.0 - 3.83e-5*D + 4.9e-10*D.*D;
    alpha = f^2* (A1.*f1./(f1.^2+f^2) + A2.*P2.*f2./(f2.^2+f^2) + A3.*P3);
end