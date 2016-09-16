function noise_analysis_callback(~,~,reg_curr,main_figure)
extfig=getappdata(main_figure,'ExternalFigures');
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

trans_obj=layer.Transceivers(idx_freq);
data=trans_obj.Data.get_subdatamat(reg_curr.Idx_r,reg_curr.Idx_pings,'field','power');
fs=1./trans_obj.Params.SampleInterval(reg_curr.Idx_pings);


[nb_samples,nb_pings]=size(data);

nfft=2^(nextpow2(nb_samples)+1);
ffts=nan(nfft,nb_pings);

f_vec=nan(nfft,nb_pings);

for i=1:nb_pings
    ffts(:,i)=fftshift(fft(data(:,i),nfft)/sqrt(nfft*fs(i)));
    f_vec(:,i)=fs(i)*((1:nfft)/nfft-1/2);
end

[fs_unique,idx_unique]=unique(fs);

nb_fig=length(fs_unique);

hfig(nb_fig)=figure;

for i=1:nb_fig
    idx_fs=idx_unique==i;
    P_f=10*log10(2*(nanmean(ffts(:,idx_fs).*conj(ffts(:,idx_fs)),2)));

    figure(hfig(i));
    plot(nanmean(f_vec(:,idx_fs),2),P_f);
    grid on;
    xlabel('F(Hz)')
    ylabel('|P(f)| (dB/Hz)')
    title([sprintf('%s\n',trans_obj.Config.ChannelID) sprintf('Regions %.0f Bandwidth %.0f Hz, Frequency resolution %.2fHz',reg_curr.ID,fs_unique(i),fs_unique(i)/nfft)]);
    
end


extfig=[extfig hfig];
setappdata(main_figure,'ExternalFigures',extfig);

end