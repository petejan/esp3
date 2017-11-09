function [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,main_echo)

xdata=double(get(main_echo,'XData'));
ydata=double(get(main_echo,'YData'));

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans=trans_obj;
Number=trans.get_transceiver_pings();
Samples=trans.get_transceiver_samples();
[~,idx_ping_ori]=nanmin(abs(xdata(1)-Number));

[~,idx_r_ori]=nanmin(abs(ydata(1)-Samples));
end