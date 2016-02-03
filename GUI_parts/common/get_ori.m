function [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,main_echo)

xdata=double(get(main_echo,'XData'));
ydata=double(get(main_echo,'YData'));

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);
Number=trans.Data.Number;
Range=trans.Data.Range;

[~,idx_ping_ori]=nanmin(abs(xdata(1)-Number));

[~,idx_r_ori]=nanmin(abs(ydata(1)-Range));
end