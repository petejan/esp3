function bs_analysis_EK60_standalone(Filename,varargin)

p = inputParser;

[def_path_to_mem,~,~]=fileparts(Filename{1});

addRequired( p, 'Filename',     @(x) ischar(x)||iscell(x));
addParameter(p, 'PathToSVP',    '', @(x) ischar(x));
addParameter(p, 'Filename_SVP', '', @(x) ischar(x));
addParameter(p, 'PathToAtt',    '', @(x) ischar(x));
addParameter(p, 'Filename_Att', '', @(x) ischar(x));
addParameter(p, 'PathToMemmap', def_path_to_mem,@ischar);
addParameter(p, 'Frequencies',  []);
addParameter(p, 'PingRange',    [1 inf]);
addParameter(p, 'SampleRange',  [1 inf]);
addParameter(p, 'Calibration',  []); %Calibration is a struct containing 3 fields:F,G0,SACORRECT.

parse(p, Filename, varargin{:});



layer = open_EK60_file_stdalone(Filename, ...
    'PathToMemmap', p.Results.PathToMemmap,Path, 'Frequencies', p.Results.Frequencies,...
    'PingRange', p.Results.PingRange, 'SampleRange', p.Results.SampleRange, ...
    'Calibration', p.Results.Calibration);

if ~strcmp(p.Results.Filename_SVP, '')
    u = importdata(fullfile(p.Results.PathToSVP, p.Results.Filename_SVP));
    z_c = u.data(:,1);
    c   = u.data(:,2);
else
    z_c = 1:2*1e4;
    c   = layer.Env.SoundSpeed*ones(size(z_c));
end

z_interp = z_c(1):1:z_c(end);
c_interp = interpn(z_c,c,z_interp,'linear');

figure();
plot(c_interp, z_interp, '-o');
hold on;
plot(c, z_c, '-+');
axis ij;
ylim([z_c(1) z_c(end)]);
xlabel('SoundSpeed(m/s)');
ylabel('Depth (m)');
grid on;
legend('Interpolated', 'Measured');

layer.EnvData = layer.EnvData.set_svp(z_c, c);

if ~strcmp(p.Results.Filename_Att, '')
    attitude_full = csv_to_attitude(p.Results.PathToAtt, p.Results.Filename_Att);
    layer.add_attitude(attitude_full);
end

idx_freq = find_freq_idx(layer,p.Results.Frequencies);

choice = questdlg('Do you want Use Ray tracing?', ...
    'Ray tracing',...
    'Yes', 'No', ...
    'No');
% Handle response
switch choice
    case 'Yes'
        ray_tray=1;
        
    case 'No'
        ray_tray=0;
    otherwise
        ray_tray=0;
end



phi_std_thr = 20/180*pi;
trans_angle = [0 -45];%pitch roll
pos_trans   = [-2.5;-2.5;-2.5];%dalong dacross dz
att_cal     = [0 0];

bs_analysis(layer, 'IdxFreq', idx_freq, 'PhiStdThr', phi_std_thr, 'TransAngle', trans_angle, 'PosTrans', pos_trans, 'AttCal', att_cal, 'RayTrayBool', ray_tray)
%

layer.delete();

end