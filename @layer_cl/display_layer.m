function main_echo=display_layer(layer,freq,fieldname,ax,axes_type,x,y,dx,dy,new)

[idx_freq,found]=layer.find_freq_idx(freq);

if found==0
    return;
end

if isempty(axes_type)
    axes_type='Number';
    x=layer.Transceivers(idx_freq).Data.Time;
    y=layer.Transceivers(idx_freq).Data.Range;
    dx=(x(2)-x(1))/10;
    dy=(y(2)-y(1))/10;
    new=1;
end



switch axes_type
    case 'Time'
        xdata=layer.Transceivers(idx_freq).Data.Time;
    case 'Number'
        xdata=layer.Transceivers(idx_freq).Data.Number;
    case 'Distance'
        xdata=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        if isempty(xdata)
            disp('NO GPS Data');
            axes_type='Number';
            xdata=layer.Transceivers(idx_freq).Data.Number;
        end
    otherwise
        xdata=layer.Transceivers(idx_freq).Data.Number;
end

ydata=layer.Transceivers(idx_freq).Data.Range;
data=layer.Transceivers(idx_freq).Data.get_datamat(fieldname);


if new==0
    [~,idx_xlim_min]= nanmin(abs(xdata-x(1)));
    [~,idx_xlim_max]= nanmin(abs(xdata-x(2)));
    
    [~,idx_ylim_min]= nanmin(abs(ydata-y(1)));
    [~,idx_ylim_max]= nanmin(abs(ydata-y(2)));
else
    idx_xlim_min=1;
    idx_xlim_max=1;
    idx_ylim_min=1;
    idx_ylim_max=1;
end


idx_xlim=[idx_xlim_min idx_xlim_max];
idx_ylim=[idx_ylim_min idx_ylim_max];



if isempty(data)
   return; 
end

switch lower(deblank(fieldname))
    case 'y'
        data_mat=10*log10(abs(data));
    case {'power','powerdenoised'}
        data_mat_lin=data;
        data_mat_lin(data_mat_lin<=0)=nan;
        data_mat=10*log10(data_mat_lin);
    otherwise
        data_mat=data;
end

axes(ax);
switch axes_type
    case {'Time','Distance'}       
        main_echo=surface(xdata,ydata,real(data_mat));
        view(2)
        shading(ax,'flat');
            case 'Number'
        main_echo=imagesc(xdata,ydata,real(data_mat));
    otherwise
        main_echo=imagesc(xdata,ydata,real(data_mat));
end
if strcmp(axes_type,'Time')
   dx=dx/(24*60*60); 
end
cax=layer.Transceivers(idx_freq).Data.get_caxis(fieldname);

format_main_axes(ax,cax,xdata,ydata,idx_xlim,idx_ylim,dx,dy,new);

end