function [dr,dp]=display_layer(layer,freq,fieldname,ax,main_echo,x,y,new)

[idx_freq,found]=layer.find_freq_idx(freq);
if found==0
    return;
end
set(ax,'units','pixels');
screensize=get(ax,'position');
set(ax,'units','normalized');

xdata=layer.Transceivers(idx_freq).Data.get_numbers();
ydata=layer.Transceivers(idx_freq).Data.get_range();

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

outputSize=nanmin(screensize(3:4),[nb_pings nb_samples]);


dr=nanmax(ceil(nb_samples/outputSize(2)),1);
dp=nanmax(ceil(nb_pings/outputSize(1)),1);
% dp=1;
% dr=1;

data=layer.Transceivers(idx_freq).Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);

switch lower(fieldname)
    case {'sv','sp','power'}
        
end

if isempty(data)
    fieldname= layer.Transceivers(idx_freq).Data.Fieldname{1};
    data=layer.Transceivers(idx_freq).Data.get_subdatamat(idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end),'field',fieldname);
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
data_mat=single(data_mat);

set(main_echo,'XData',xdata(idx_ping),'YData',ydata(idx_r),'CData',real(data_mat));


if length(xdata(idx_ping))>1
    set(ax,'xlim',[xdata(idx_ping(1)) xdata(idx_ping(end))]);
end

if length(ydata(idx_r))>1
    set(ax,'ylim',[ydata(idx_r(1)) ydata(idx_r(end))]);
end

end