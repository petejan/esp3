function main_echo=display_layer(layer,freq,fieldname,outputSize,ax,axes_type,x,y,dx,dy,new)

[idx_freq,found]=layer.find_freq_idx(freq);

if found==0
    return;
end

if isempty(axes_type)
    axes_type='Number';
    x=layer.Transceivers(idx_freq).Data.Number;
    y=layer.Transceivers(idx_freq).Data.Range;
    dx=(x(end)-x(1))/10;
    dy=(y(end)-y(1))/10;
    new=1;
end

switch axes_type
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time;
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).Data.Number;
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        if isempty(xdata_grid)
            disp('NO GPS Data');
            axes_type='Number';
            xdata_grid=layer.Transceivers(idx_freq).Data.Number;
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).Data.Number;      
end

xdata=layer.Transceivers(idx_freq).Data.Number;
ydata=layer.Transceivers(idx_freq).Data.Range;

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
end
nb_samples=length(idx_r);
nb_pings=length(idx_ping);

outputSize=nanmin(outputSize,[nb_samples nb_pings]);

dr=round(nb_samples/outputSize(1))+1;
dp=round(nb_pings/outputSize(2))+1;

data=layer.Transceivers(idx_freq).Data.get_subdatamat(fieldname,idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end));


if isempty(data)
   fieldname= layer.Transceivers(idx_freq).Data.Fieldname{1};
  data=layer.Transceivers(idx_freq).Data.get_subdatamat(fieldname,idx_r(1):dr:idx_r(end),idx_ping(1):dp:idx_ping(end));
end

if isempty(data)
    axes(ax);
    main_echo=imagesc(ones(1,1));
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

% if nansum(outputSize==size(data))<2
%     data_mat = imresize(data_mat,outputSize,'nearest');
% end

axes(ax);
switch axes_type
    case {'Time','Distance'}       
        main_echo=imagesc(xdata(idx_ping),ydata(idx_r),real(data_mat));
        view(2)
        shading(ax,'flat');
            case 'Number'
        main_echo=imagesc(xdata(idx_ping),ydata(idx_r),real(data_mat));
    otherwise
        main_echo=imagesc(xdata(idx_ping),ydata(idx_r),real(data_mat));
end
if strcmp(axes_type,'Time')
   dx=dx/(24*60*60); 
end
cax=layer.Transceivers(idx_freq).Data.get_caxis(fieldname);

format_main_axes(ax,cax,axes_type,xdata_grid(idx_ping),ydata(idx_r),xdata(idx_ping),ydata(idx_r),dx,dy);

end