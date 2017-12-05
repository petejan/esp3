function [idx_samples,idx_pings]=get_idx_r_n_pings(layer,curr_disp,main_echo)

xdata=double(get(main_echo,'XData'));
ydata=double(get(main_echo,'YData'));

[trans_obj,~]=layer.get_trans(curr_disp);
trans=trans_obj;

Number=trans.get_transceiver_pings();

[~,idx_ping_start]=nanmin(abs(xdata(1)-Number));
[~,idx_ping_end]=nanmin(abs(xdata(end)-Number));

Samples=trans.get_transceiver_samples();
[~,idx_r_start]=nanmin(abs(ydata(1)-Samples));
[~,idx_r_end]=nanmin(abs(ydata(end)-Samples));

idx_pings=idx_ping_start:idx_ping_end;
idx_samples=idx_r_start:idx_r_end;
end