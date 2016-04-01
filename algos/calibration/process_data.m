%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2: Processing of sphere echoes to yield calibration parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function transceiver=process_data(transceiver,envData,idx_peak,idx_pings,sphere_ts)

% Optional single target and sphere processing parameters:
%
% The std of the arrival angle of each sample in each echo has to be
% less than or equal to this value for an echo to be kept.
p.max_std_phase = 1; %[degrees]

% Only consider echoes that have an angular position that is within
% trimToFactor times the beam angle
p.trimToFactor = 1.7;

% Any sphere echo more than maxDbDiff1 from the theoretical will be
% discarded as an outlier. Used in a coarse filter prior to actually
% working out the beam width.
p.maxdBDiff1 = 12;

% Beam compensated TS values more than maxdBDiff2 dB above or below the
% sphere TS are discarded. Done after working out the beam width.
% Note that this forces an upper limit on the RMS of the final fit to the
% beam pattern.
p.maxdBDiff2 = .75;

% All echoes within onAxisTol degrees of an axis (or 45 deg to the axis)
% will be used when doing the 4-panel plot of sphere echoes
p.onAxisTol = 0.3; % [degrees]

% All echoes within p.onAxisFactor times the beam width will be considered to
% be on-axis for the purposes of working out the on-axis gain.
p.onAxisFactor = 0.015; % [factor]

% If there are less than p.minOnAxisEchos sphere echoes close to the
% beam centre (as calculated using p.onAxisFactor), use
% p.onAxisFactorExpanded instead.
p.minOnAxisEchoes = 6;

% If insufficient echoes are found with p.onAxisFactor multiplied by
% the average of the fore/aft and port/stbd beamwidths,
% p.onAxisFactorExpanded will be used instead.
p.onAxisFactorExpanded = 5 * p.onAxisFactor; % [factor]

% When calculating the RMS fit of the data to the Simrad beam pattern, only
% consider echoes out to (rmsOutTo * beamwidth) degrees.
p.rmsOutTo = 0.5;

% What colour map to use for the echogram
p.colourmap = ''; % '' or 'EK500'
p.SpRange = [-72 -36];

% What method to use when calculating the 'best' estimate of the on-axis
% sphere TS. Max of on-axis echoes, mean of on-axis echoes, or the peak of
% the fitted beam pattern.
p.onAxisMethod = {'mean','max','beam fitting'}; % choices of 'max', 'mean', or 'beam fitting'


% Extract and derive some data from the .raw files

% Pick out the peak amplitudes for use later on, and discard the
% rest. For power keep the 9 samples that surround the peak too.


Sp=transceiver.Data.get_datamat('sp');
AlongAngle=transceiver.Data.get_datamat('alongangle');
AcrossAngle=transceiver.Data.get_datamat('acrossangle');

Power=transceiver.Data.get_datamat('power');

[AcrossPhi,AlongPhi]=transceiver.get_phase();


Freq=double(transceiver.Config.Frequency);
pulselength=double(transceiver.Params.PulseLength(1));
gains=transceiver.Config.Gain;
pulselengths=transceiver.Config.PulseLength;
[~,idx_pulse]=nanmin(abs(pulselengths-pulselength));
gain=gains(idx_pulse);
Np=double(round(pulselength/transceiver.Params.SampleInterval(1)));


pp = idx_peak;
tts = zeros(size(pp));
range = zeros(length(pp),1);
along = zeros(size(pp))';
athwart = zeros(size(pp))';
power = zeros(length(pp),2*Np+1);
phase_along = zeros(length(pp),2*Np+1);
phase_athwart = zeros(length(pp),2*Np+1);

for j = 1:length(pp)
    if (Np < pp(j) && (pp(j) + Np) < size(Sp,1))
        tts(j) = Sp(pp(j), idx_pings(j));
        along(j) = AlongAngle(pp(j), idx_pings(j));
        athwart(j) = AcrossAngle(pp(j), idx_pings(j));
        power(j,:) = Power(pp(j)-Np:pp(j)+Np, idx_pings(j));
        phase_along(j,:) = AlongPhi(pp(j)-Np:pp(j)+Np, idx_pings(j));
        phase_athwart(j,:) = AcrossPhi(pp(j)-Np:pp(j)+Np, idx_pings(j));
        range(j) = pp(j);
    end
end

idx_keep=(range>0);
tts= tts(idx_keep);
along= along(idx_keep);
athwart= athwart(idx_keep);
power= power(idx_keep,:);
phase_along= phase_along(idx_keep,:);
phase_athwart = phase_athwart(idx_keep,:);
range = range(idx_keep);


data.cal.ts = tts;
data.cal.power = power;

% Convert the range from samples to metres. Range to the peak target
% amplitude is counted from the peak of the transmit pulse, which is
% taken to occur at the range corresponding to half the transmit pulse
% length.
data.cal.range = transceiver.Data.get_range(range) - ...
    pulselength * envData.SoundSpeed/4;

data.cal.sphere_ts = sphere_ts;


%
% along = along;
% athwart = athwart;
phase_along = phase_along';
phase_athwart = phase_athwart';

clear tts range pp power

% Extract some useful data from the data structure for convenience
amp_ts = data.cal.ts';
power = data.cal.power';
faBW = transceiver.Config.BeamWidthAlongship; % [degrees]
psBW = transceiver.Config.BeamWidthAthwartship; % [degrees]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Apply an ES60 triangle wave correction to the data
% amp_ts = amp_ts - data.pings.es60_error(idx_keep)';
% power = power - repmat(data.pings.es60_error(idx_keep), 9, 1);
%

% And merge some info into one matrix for convenience
sphere = [amp_ts athwart along data.cal.range];

% Keep a copy of the original set of data
original.sphere = sphere;
original.power = power;

% The amp_ts and range data are now in sphere
clear amp_ts range error

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove any echoes that are likely to be noisy or wrong

% Filter out echoes with too much variation in their position through the echo.
i = find(std(phase_along(Np-round(Np/4):Np+round(Np/4),:)) <= p.max_std_phase & ...
    std(phase_athwart(Np-round(Np/4):Np+round(Np/4),:)) <= p.max_std_phase);

[sphere,power,phase_along,phase_athwart] = trim_data(i, sphere, power, phase_along, phase_athwart);

% Trim echoes to those within a bit more than the 3 dB beamwidth
% This is not exact because we haven't yet calculated the
% beam centre offsets, but it will do for the moment
trimTo = p.trimToFactor * mean([faBW psBW]) * 0.5;
i = find(abs(sphere(:,2)) < trimTo & abs(sphere(:,3)) < trimTo);
[sphere,power,phase_along,phase_athwart] = trim_data(i, sphere, power, phase_along, phase_athwart);

% Use the Simrad theoretical beampattern formula to trim echoes that are
% grossly wrong
theoreticalTS = data.cal.sphere_ts - simradBeamCompensation(faBW, psBW, sphere(:,3), sphere(:,2));
diffTS = theoreticalTS - sphere(:,1);
i = find(abs(diffTS) <= p.maxdBDiff1);
[sphere,power,phase_along,phase_athwart] = trim_data(i, sphere, power, phase_along, phase_athwart);

if isempty(i)
    disp('Failed to find sphere echoes. ')
    return
end

% Fit the simrad beam pattern to the data. We get estimated beamwidth,
% offsets, and peak value from this.
[offset_fa,faBW,offset_ps,psBW,~,peak_ts,exitflag] = ...
    fit_beampattern(sphere(:,1), sphere(:,2), sphere(:,3), 1.0, mean([faBW psBW]));

% If a beam pattern couldn't be fitted, give up with some diagonistics.
if exitflag ~= 1
    disp('Failed to fit the simrad beam pattern to the data. ')
    disp('This probably means that the beampattern is so far from circular ')
    disp('that there is something wrong with the echosounder.')
    
    % Plot the probably wrong data, using the un-filtered dataset
    figure('name', 'Beam pattern contour plot')
    clf
    [XI,YI]=meshgrid(-trimTo:.1:trimTo,-trimTo:.1:trimTo);
    warning('off','MATLAB:griddata:DuplicateDataPoints');
    ZI = griddata(original.sphere(:,2), original.sphere(:,3), original.sphere(:,1), XI, YI);
    warning('on','MATLAB:griddata:DuplicateDataPoints');
    contourf(XI,YI,ZI)
    axis square
    grid
    xlabel('Port/starboard angle (\circ)')
    ylabel('Fore/aft angle (\circ)')
    colorbar

    hold on
    plot(sphere(:,2), sphere(:,3),'+','MarkerSize',2,'MarkerEdgeColor',[.5 .5 .5])
    
    % Add some circles to indicate what a circular beam looks like...
    for r = 1:4
        x = r * cos(0:.01:2*pi);
        y = r * sin(0:.01:2*pi);
        plot(x, y, 'k')
    end
    hold off
    disp(' ')
    disp('Contour plot is of all data points (no filtering, beyond what you did manually).')
    disp(' ')
    disp('No further analysis will be done. The beam is odd.')
    return
end

% Apply the offsets to the target angles
sphere(:,2) = sphere(:,2) - offset_ps;
sphere(:,3) = sphere(:,3) - offset_fa;

% Convert the angles to conical angle for use later on
t1 = tan(sphere(:,2) * pi/180);
t2 = tan(sphere(:,3) * pi/180);
phi = atan(sqrt(t1.*t1 + t2.*t2)) * 180/pi;

% Calculate beam compensation for each echo
compensation = simradBeamCompensation(faBW, psBW, sphere(:,3), sphere(:,2));

% Filter outliers based on the beam compensated corrected data
i = find(sphere(:,1)+compensation <= peak_ts+p.maxdBDiff2 & ...
    sphere(:,1)+compensation > peak_ts-p.maxdBDiff2);
[sphere, power , ~, ~] = trim_data(i, sphere, power, phase_along, phase_athwart);

% And some data that trim_data doesn't do
compensation = compensation(i);
phi = phi(i);

% Calculate the mean_ts from echoes that are on-axis
on_axis = p.onAxisFactor * mean(faBW + psBW);

% If there are no echoes found within onAxisFactor, make a note to use
% a larger factor.
use_corrected = 0;

if numel(find(phi < on_axis)) <  p.minOnAxisEchoes
    use_corrected = 1;
end

if use_corrected == 0
    i = find(phi < on_axis);
    ts_values = sphere(i,1);
    mean_ts_on_axis = 10*log10(mean(10.^(ts_values/10)));
    std_ts_on_axis = std(ts_values);
    max_ts_on_axis = max(ts_values);
else
    on_axis = p.onAxisFactorExpanded * mean(faBW + psBW);
    % Since we're using data from a much larger angle range, apply the beam
    % pattern compensation to avoid gross errors.
    i = find(phi < on_axis);
    if isempty(i)
        return;
    end
    ts_values = sphere(i,1) + compensation(i);
    mean_ts_on_axis = 10*log10(mean(10.^(ts_values/10)));
    std_ts_on_axis = std(ts_values);
    max_ts_on_axis = max(ts_values);
end



% plot up the on-axis TS values
figure('name', 'On-axis sphere TS')
if exist('boxplot', 'file') % this lives in the Statistics toolbox, which not everyone will have
    boxplot(ts_values)
else
    hist(ts_values)
end
ylabel('TS (dB re 1 m^2)')
title(['On axis TS values for ' num2str(length(sphere(i,1))) ' targets'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Produce plots and output text

% The calibration results
disp(' ')
oa = num2str(on_axis);
disp(['Mean ts within ' oa ' deg of centre = ' num2str(mean_ts_on_axis) ' dB'])
disp(['Std of ts within ' oa ' deg of centre = ' num2str(std_ts_on_axis) ' dB'])
disp(['Maximum TS within ' oa ' deg of centre = ' num2str(max_ts_on_axis) ' dB.'])
disp(['Number of echoes within ' oa ' deg of centre = ' num2str(length(sphere(i,1)))])
disp(['On axis TS from beam fitting = ' num2str(peak_ts) ' dB.'])
disp(['The sphere ts is ' num2str(data.cal.sphere_ts) ' dB'])

outby=nan(1,length(p.onAxisMethod));
for k=1:length(p.onAxisMethod)
    if strcmp(p.onAxisMethod{k}, 'max')
        outby(k) = data.cal.sphere_ts - max_ts_on_axis;
    elseif strcmp(p.onAxisMethod{k}, 'mean')
        outby(k) = data.cal.sphere_ts - mean_ts_on_axis;
        old_cal=transceiver.get_cal();
        new_cal.G0=old_cal.G0-outby(k)/2;
    elseif strcmp(p.onAxisMethod{k}, 'beam fitting')
        outby(k) = data.cal.sphere_ts - peak_ts;
    end
    
    if outby(k) > 0
        disp(['Hence Ex60 is reading ' num2str(outby(k)) ' dB too low (' p.onAxisMethod{k} ' method).'])
    else
        disp(['Hence Ex60 is reading ' num2str(abs(outby(k))) ' dB too high (' p.onAxisMethod{k} ' method).'])
    end
    
    disp(['So add ' num2str(-outby(k)/2) ' dB to G_o (' p.onAxisMethod{k} ' method)'])
    
    disp(['G_o from .raw file is ' num2str(gain) ' dB'])
    disp(' ')
    disp(['So the calibrated G_o = ' num2str(old_cal.G0-outby(k)/2) ' dB (' p.onAxisMethod{k} ' method)'])
    disp(' ')
end

% Do a contour plot to show the beam pattern

[XI,YI]=meshgrid(-trimTo:.1:trimTo,-trimTo:.1:trimTo);

warning('off','MATLAB:griddata:DuplicateDataPoints');
ZI=griddata(double(sphere(:,2)), double(sphere(:,3)), double(sphere(:,1)+outby(1)),XI,YI);

if ~isempty(ZI)
    figure('name', 'Beam pattern contour plot')
    clf
    warning('on','MATLAB:griddata:DuplicateDataPoints');
    contourf(XI,YI,ZI)
    axis equal
    grid
    xlabel('Port/starboard angle (\circ)')
    ylabel('Fore/aft angle (\circ)')
    colorbar
    
    
    % And plot the positions of the sphere. Note that there is a bug in matlab
    % where the point (.) marker doesn't have a continuous size range, so we
    % used a marker that does (the available . sizes are not right).
    hold on
    plot(sphere(:,2), sphere(:,3),'+','MarkerSize',2,'MarkerEdgeColor',[.5 .5 .5])
    axis equal
    
    % Do a 3d plot of the uncorrected and corrected beampattern
    figure('name', '3D beam pattern (corrected and uncorrected)')
    clf
    surf(XI, YI, ZI)
    warning('off','MATLAB:griddata:DuplicateDataPoints');
    ZI=griddata(double(sphere(:,2)), double(sphere(:,3)), double(sphere(:,1)+compensation+outby(1)),XI,YI);
    warning('on','MATLAB:griddata:DuplicateDataPoints');
    hold on
    surf(XI, YI, ZI)
    zlabel('TS (dB re 1m^2)')
    xlabel('Port/stbd angle (\circ)')
    ylabel('Fore/aft angle (\circ)')
end

% Do a plot of the sphere range during the calibration
figure('name', 'Sphere range')
clf
plot(sphere(:,4))
disp(['Mean sphere range = ' num2str(mean(sphere(:,4))) ...
    ' m, std = ' num2str(std(sphere(:,4))) ' m.'])
title('Sphere range during the calibration.')
xlabel('Ping number')
ylabel('Sphere range (m)')

% Do a plot of the compensated and uncompensated echoes at a selection of
% angles, similar to what one can get from the Simrad calibration program
figure('name', 'Beam slice plot')
clf
plotBeamSlices(sphere, outby(1), trimTo, faBW, psBW, peak_ts, p.onAxisTol)

% Calculate the sa correction value informed by draft formulae
% in Tody Jarvis's WGFAST calibration report.
%
% This is a litte hard to represent in text, so refer to Echoview help for
% more details than are presented here.
%
% The Sa correction is a value that corrects for the received pulse having
% less energy in it than that nominal, transmitted pulse. The formula for
% Sv (see Echoview) includes a term -10log10(Teff) (where Teff is the
% effective pulse length). We don't have Teff, so need to calculate it. We
% do have Tnom (the nominal pulse length) and just need to scale Tnom so
% that it gives the same result as the integral of Teff:
%
% Teff = Tnom * alpha
% alpha = Teff / Tnom
% alpha = Int(P.dt) / (Pmax * Tnom)
%  where P is the power measurements throughout the echo,
%  Pmax is the max power in the echo, and dt the time
%  between P measurements. This is simply the ratio of the area under the
%  nominal pulse and the area under the actual pulse.
%
% For the EK60, dt = Tnom/4 (it samples 4 times every pulse length)
% So, alpha = Sum(P * Tnom) / (4 * Pmax * Tnom)
%     alpha = Sum(P) / (4 * Pmax)
%
% However, Echoview, etc, expect the correction factor to be in dB, and
% furthermore is used as (10log10(Tnom) + 2 * Sa). Hence
% Sa = 0.5 * 10log10(alpha)

% Work in the linear domain to calculate the scale factor to convert the
% nominal pulse length into the effective pulse length
alpha = mean( (sum(power(:,i)) ) ./ (Np * max(power(:,i))));

% And convert that to dB, taking account of how this ratio is used as 2Sa
% everywhere (i.e., it needs to be halved after converting to dB).
sa_correction = 5 * log10(alpha);
disp(' ')
disp(['So sa correction = ' num2str(sa_correction) ' dB.'])
disp(' ')
disp(['(the effective pulse length = ' num2str(alpha) ' * nominal pulse length).'])
disp(' ')

% Print out some more cal results
disp(['Fore/aft beamwidth = ' num2str(faBW) ' degrees.'])
disp(['Fore/aft offset = ' num2str(offset_fa) ' degrees (to be subtracted from EK60 angles).'])
disp(['Port/stbd beamwidth = ' num2str(psBW) ' degrees.'])
disp(['Port/stbd offset = ' num2str(offset_ps) ' degrees (to be subtracted from EK60 angles).'])

disp(['Results obtained from ' num2str(length(sphere(:,1))) ' sphere echoes.'])
disp(['Using c = ' num2str(envData.SoundSpeed) ' m/s.'])
disp(['Using alpha = ' num2str(transceiver.Params.Absorption*1000) ' dB/km.'])

% Calculate the RMS fit to the beam model
fit_out_to = mean([psBW faBW]) * p.rmsOutTo; % fit out to half the beamangle
i = find(phi <= fit_out_to);
beam_model = peak_ts - compensation;

% Note that the halving of the difference is not what was done here
% previously. From a comparison of the rms value that the Simrad
% calibration program produces and what this formulae produced when using
% the same input data, it appears that the Simrad program is halving the
% difference, hence this formula now halves the difference and produces rms
% values that are directly comparable to the Simrad results.
rms_fit = sqrt( mean( ( (sphere(i,1) - beam_model(i))/2 ).^2 ) );
disp(['RMS of fit to beam model out to ' num2str(fit_out_to) ' degrees = ' num2str(rms_fit) ' dB.'])


new_cal.SACORRECT=sa_correction;

transceiver.apply_cw_cal(new_cal);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compensation = simradBeamCompensation(faBW, psBW, faAngle, psAngle)
% Calculates the simard beam compensation given the beam angles and
% positions in the beam

part1 = 2*faAngle/faBW;
part2 = 2*psAngle/psBW;

compensation = 6.0206 * (part1.^2 + part2.^2 - 0.18*part1.^2.*part2.^2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phi, theta] = simradAnglesToSpherical(fa, ps)
% Convert the cartesian angles to conical angle.
t1 = tan(ps * pi/180);
t2 = tan(fa * pi/180);
phi = atan(sqrt(t1.*t1 + t2.*t2)) * 180/pi; % angle off transducer axis
theta = atan2(t1, t2) * 180/pi; % rotation about transducer axis

% Convert the angles so that we get negative phi's to allow for plotting of
% complete beam pattern slice arcs
i = find(theta < 0);
phi(i) = -phi(i);
theta(i) = 180+theta(i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotBeamSlices(sphere, outby, trimTo, faBW, psBW, peak_ts, tol)
% Produce a plot of the sphere echoes and the fitted beam pattern at 4
% slices (0 45, 90, and 135 degrees) through the beam.
%
% trimTo is the angle (degrees) to plot out to
% tol is the angle (degrees) to take sphere echoes from for each slice

% suplot1 is a function that produces better looking subplots, available
% from the Mathworks File Exchange.
subplot1(2,2)

% 0 degrees
subplot1(1)
i = find(abs(sphere(:,2)) < tol);
plot(sphere(i,3), sphere(i,1)+outby(1),'k.')
hold on
x = -trimTo:.1:trimTo;
plot(x, peak_ts + outby(1) - simradBeamCompensation(faBW, psBW, x, 0), 'k');

% 45 degrees. Needs special treatment to get angle off axis from the fa and
% ps angles
subplot1(2)
i = find(abs(sphere(:,2) - sphere(:,3)) < tol);
[phi_x,~] = simradAnglesToSpherical(sphere(i,3), sphere(i,2));
s = sphere(i,1) + outby(1);
i = find(abs(phi_x) <= trimTo);
plot(phi_x(i), s(i), 'k.')
hold on
[phi_x,~] = simradAnglesToSpherical(x, x);
beam = peak_ts + outby(1) - simradBeamCompensation(faBW, psBW, x, x);
i = find(abs(phi_x) <= trimTo);
plot(phi_x(i), beam(i), 'k');

% 90 degrees
subplot1(3)
i = find(abs(sphere(:,3)) < tol);
plot(sphere(i,2), sphere(i,1)+outby(1),'k.')
hold on
x = -trimTo:.1:trimTo;
plot(x, peak_ts + outby(1) - simradBeamCompensation(faBW, psBW, 0, x), 'k');
xlabel('Angle (\circ) off normal')
ylabel('TS (dB re 1m^2)')

% 135 degrees. Needs special treatment to get angle off axis from the fa and
% ps angles
subplot1(4)
i = find(abs(-sphere(:,2) - sphere(:,3)) < tol);
[phi_x,~] = simradAnglesToSpherical(sphere(i,3), sphere(i,2));
s = sphere(i,1) + outby(1);
i = find(abs(phi_x) <= trimTo);
plot(phi_x(i), s(i),'k.')
hold on
[phi_x,~] = simradAnglesToSpherical(-x, x);
beam = peak_ts + outby(1) - simradBeamCompensation(faBW, psBW, -x, x);
i = find(abs(phi_x) <= trimTo);
plot(phi_x(i), beam(i), 'k');

% Make the y-axis limits the same for all 4 subplots
limits = [1000 -1000 1000 -1000];
for i = 1:4
    subplot1(i)
    lim = axis;
    limits(1) = min(limits(1), lim(1));
    limits(2) = max(limits(2), lim(2));
    limits(3) = min(limits(3), lim(3));
    limits(4) = max(limits(4), lim(4));
end

% Expand the axis limits so that axis labels don't overlap
limits(1) = limits(1) - .2; % x-axis, units of degrees
limits(2) = limits(2) + .2; % x-axis, units of degrees
limits(3) = limits(3) - 1; % y-axis, units of dB
limits(4) = limits(4) + 1; % y-axis, units of dB
for i = 1:4
    subplot1(i)
    axis(limits)
end

% Add a line to each subplot to indicate which angle the slice is for.
% Work out the position for the ship schematic with angled line.
angles = [0 45 90 135]; % angles of the four plots
for i = 1:length(angles)
    subplot1(i)
    pos = get(gca, 'Position');
    axes('Position', [pos(1)+0.02*pos(3) pos(2)+0.7*pos(4) 0.2*pos(3) 0.2*pos(4)]);
    plot_angle_diagram(angles(i))
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_angle_diagram(angle)
% Plots a little figure of the ship and an angled line on the given axes

% The ship shape
x = [0 1 1 .5 0 0];
y = [0 0 2 2.5 2 0];
plot(x,y,'k')
hold on

% The circle to represent the transducer
theta = 0:.01:2.1*pi;
r = 0.3;
centre = [0.5 1.5];
length = 0.9;
plot(centre(1) + r*cos(theta), centre(2) + r*sin(theta), 'k')

% The angled line
switch angle
    case 0
        plot([centre(1) centre(1)], [centre(2)-length centre(2)+length], 'k', 'LineWidth', 2)
    case 45
        x = length*cos(angle*pi/180);
        y = length*sin(angle*pi/180);
        plot([centre(1)-x centre(1)+x] ,[centre(2)-y centre(2)+y], 'k', 'LineWidth', 2)
    case 90
        plot([centre(1)-length centre(1)+length], [centre(2) centre(2)], 'k', 'LineWidth', 2)
    case 135
        x = length*cos(angle*pi/180);
        y = length*sin(angle*pi/180);
        plot([centre(1)+x centre(1)-x] ,[centre(2)+y centre(2)-y], 'k', 'LineWidth', 2)
end

axis equal

% The bottom of some figures get chopped off when removing the axis, so
% extend the axis a little to prevent this
set(gca, 'YLim', [-0.1 2.6])
axis off
hold off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sphere,power,phase_along,phase_athwart] = trim_data(i, sphere, power, phase_along, phase_athwart)
% A function to eliminate specified entries in a set of vectors.

sphere = sphere(i,:);
power = power(:,i);
phase_along = phase_along(:,i);
phase_athwart = phase_athwart(:,i);
end