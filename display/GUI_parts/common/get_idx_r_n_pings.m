function [idx_samples,idx_pings]=get_idx_r_n_pings(layer,curr_disp,main_echo)

xdata=double(get(main_echo,'XData'));
ydata=double(get(main_echo,'YData'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

Number=trans.get_transceiver_pings();
Range=trans.get_transceiver_range();


[~,idx_ping_start]=nanmin(abs(xdata(1)-Number));
[~,idx_ping_end]=nanmin(abs(xdata(end)-Number));

[~,idx_r_start]=nanmin(abs(ydata(1)-Range));
[~,idx_r_end]=nanmin(abs(ydata(end)-Range));

idx_pings=idx_ping_start:idx_ping_end;
idx_samples=idx_r_start:idx_r_end;
end