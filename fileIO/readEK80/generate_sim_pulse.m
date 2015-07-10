function [sim_pulse_2,y_tx_matched]=generate_sim_pulse (params,F1,F2)

f_s_ori=1.5*1e6;
Ztrd=75;%ohms

D_1=F1.DecimationFactor;
D_2=F2.DecimationFactor;
filt_1=(F1.Coefficients(1:2:end)+1i*F1.Coefficients(2:2:end));
filt_2=(F2.Coefficients(1:2:end)+1i*F2.Coefficients(2:2:end));

f_s_sig=round(1/(Params.SampleInterval(1)));
FreqStart=(params.FrequencyStart(1));
FreqEnd=(params.FrequencyEnd(1));
ptx=(params.TransmitPower(1));
pulse_length=(params.PulseLength(1));
pulse_slope=(params.Slope(1));

t_sim_pulse=linspace(0,pulse_length,(pulse_length*f_s_ori))';
amp= sqrt((ptx/4)*(2*Ztrd));
np=length(t_sim_pulse);


nwtx=2*floor(pulse_slope*np);
wtxtmp  = hann(nwtx);
nwtxh   = round(nwtx/2);
env_pulse = amp*[wtxtmp(1:nwtxh); ones(np-nwtx,1); wtxtmp(nwtxh+1:end)];


k_sweep=(FreqEnd-FreqStart)/t_sim_pulse(end);
phi_sweep=2*pi*(FreqStart*t_sim_pulse+k_sweep/2*t_sim_pulse.^2);
sim_pulse=env_pulse.*((exp(1i*phi_sweep)));
%sim_pulse=env_pulse.*chirp(t_sim_pulse,FreqStart,t_sim_pulse(end),FreqEnd);

%Filter simulated pulse to create match filter%


f_s_dec(1)=f_s_ori/D_1;
f_s_dec(2)=f_s_dec(1)/D_2;

if f_s_dec(2)~=f_s_sig
    disp('Decimated pulse sample rate not macthing signal sampling rate')
end

%     t_filt_1=1/f_s_ori*(0:(length(filt_1)-1))';
%     t_filt_2=1/f_s_dec(1)*(0:(length(filt_2)-1))';

sim_pulse_1=conv(sim_pulse/nanmax(abs(sim_pulse)),filt_1,'same');
sim_pulse_1=downsample(sim_pulse_1,D_1);

%     t_sim_pulse_1=downsample(t_sim_pulse,D_1);

sim_pulse_2=conv(sim_pulse_1/nanmax(abs(sim_pulse_1)),filt_2,'same');
sim_pulse_2=downsample(sim_pulse_2,D_2);

%     t_sim_pulse_2=downsample(t_sim_pulse_1,D_2);

y_tx_matched=flipud(conj(sim_pulse_2))/nanmax(abs(sim_pulse_2));