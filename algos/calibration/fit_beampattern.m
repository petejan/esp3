function [offset_fa, bw_fa, offset_ps, bw_ps, pts_used, peak, exitflag] ...
    = fit_beampattern(ts, echoangle_ps, echoangle_fa, limit, bw)
% A function to estimate the beamwidth from the given data. TS and echoangle
% should be the same size and contain the target strength and respective
% angles. TS points more than limit dB away from the fit are
% discarded and a new fit calculated.

% Use the Simrad beam compensation equation and fit it to the data.

% Define a function that can be minimised to find the beamwidth and angle
% offset (also finds the best max amplitude).
% x(1) is the fa beamwidth, x(2) the ps beamwidth, x(3) the fa offset,
% x(4) the ps offset and x(5) the ts on beam-axis
shape = @(x) sum((ts - x(5) + simradBeamCompensation(x(1), x(2), echoangle_fa-x(3), echoangle_ps-x(4))) .^2);
[result , ~, exitflag, ~] = fminsearch(shape, double([bw, bw, 0.0, 0.0, max(ts)]));

bw_fa = result(1);
bw_ps = result(2);
offset_fa = result(3);
offset_ps = result(4);
peak = result(5);

% Idenitfy and ignore points that are too far from the fit and recalculate
% (removes some sensitivity to outliers)
% Find all points within limit dB of the theoretical beam patter
ii = find(abs(ts - peak + simradBeamCompensation(bw_fa, bw_ps, echoangle_fa-offset_fa, echoangle_ps-offset_ps)) < limit);

% A new function to minimise that only uses the points from ii
shape = @(x) sum((ts(ii) - x(5) + simradBeamCompensation(x(1), x(2), echoangle_fa(ii)-x(3), echoangle_ps(ii)-x(4))) .^2);
result = fminsearch(shape, [bw_fa, bw_ps, offset_fa, offset_ps, peak]);
bw_fa = result(1);
bw_ps = result(2);
offset_fa = result(3);
offset_ps = result(4);
peak = result(5);
pts_used = ii;
end