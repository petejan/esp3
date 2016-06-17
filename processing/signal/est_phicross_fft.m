function [n_fft_eval,delta,estim_ph,phi_est]=est_phicross_fft(n,amp,phase,phi_fix)

nfft=nanmax(2^(nextpow2(length(amp))+1),2^14);

S=abs(fft(amp.*exp(1i*phase),nfft)).^2;

[~,idx_freq]=max(fftshift(S));
estim_ph=2*pi*(idx_freq-((nfft)/2+1))/(nfft);

sig_comp=amp.*exp(1i*phase).*exp(-1i*estim_ph*n);
phi_const = angle(nanmean(sig_comp));
phi_est=estim_ph*(n)+phi_const;

[~,idx_amp]=max(amp);
k=round((phase(idx_amp)-phi_est(idx_amp))/(2*pi));

phi_est=phi_est+2*k*pi;
delta=sqrt(nanmean(angle((exp(1i*phi_est).*exp(-1i*phase))).^2));

% figure(1);clf;plot(fftshift(S))
% figure(2);clf;plot(phi_est);hold on;plot(phase);

n_fft_eval=nan(1,length(phi_fix));
for i=1:length(phi_fix)
    n_fft_eval(i)=(phi_fix(i)-(phi_const+2*k*pi))/estim_ph;
end

end