function [dr,dp]=display_layer(layer,freq,fieldname,ax,main_echo,x,y,new)

[idx_freq,found]=layer.find_freq_idx(freq);
if found==0
    return;
end

screensize = getpixelposition(ax);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).get_transceiver_range();

if new==0
    [~,idx_ping_min]=nanmin(abs(xdata-x(1)));
    [~,idx_r_min]=nanmin(abs(ydata-y(1)));
    [~,idx_ping_max]=nanmin(abs(xdata-x(2)));
    [~,idx_r_max]=nanmin(abs(ydata-y(2)));
    idx_ping=idx_ping_min:idx_ping_max;
    idx_r=idx_r_min:idx_r_max;
else
    idx_ping=1:length(xdata);
    idx_r=1:length(ydata);
    idx_ping=idx_ping(1:floor(nanmin(screensize(3),length(idx_ping))));
end


nb_samples=length(idx_r);
nb_pings=length(idx_ping);

%outputSize=nanmin(screensize(3:4),[nb_pings nb_samples]);


% dr=nanmax(floor(nb_samples/outputSize(2)),1);
% dp=nanmax(floor(nb_pings/outputSize(1)),1);
dp=1;
dr=1;
% profile on;
%data=layer.Transceivers(idx_freq).Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);
data=layer.Transceivers(idx_freq).Data.get_datamat(fieldname);
% profile off;
% profile viewer;
% % 


if isempty(data)
    fieldname= layer.Transceivers(idx_freq).Data.Fieldname{1};
    data=layer.Transceivers(idx_freq).Data.get_datamat(fieldname);
    %data=layer.Transceivers(idx_freq).Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);
end

if isempty(data)
    set(main_echo,'XData',1,'YData',1,'CData',1);
    return;
end


switch lower(deblank(fieldname))
    case {'y','y_imag','y_real'}
        data_mat=10*log10(abs(data));
    case {'power','powerdenoised','powerunmatched'}
        data_mat_lin=data;
        data_mat_lin(data_mat_lin<=0)=nan;
        data_mat=10*log10(data_mat_lin);
    otherwise
        data_mat=data;
end

data_mat=(real(data_mat));

% x_data_disp=xdata(idx_ping);
% y_data_disp=ydata(idx_r);


x_data_disp=xdata;
y_data_disp=ydata;

set(main_echo,'XData',x_data_disp,'YData',y_data_disp,'CData',data_mat);


if length(x_data_disp)>1
    set(ax,'xlim',[x_data_disp(1) x_data_disp(end)]);
end

if length(y_data_disp)>1
    set(ax,'ylim',[y_data_disp(1) y_data_disp(end)]);
end

end