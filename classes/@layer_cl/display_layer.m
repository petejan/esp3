function main_echo=display_layer(layer,freq,fieldname,ax,axes_type,x,y,dx,dy,new)

[idx_freq,found]=layer.find_freq_idx(freq);
if found==0
    return;
end
set(ax,'units','pixels');
screensize=get(ax,'position');
set(ax,'units','normalized');

xdata=layer.Transceivers(idx_freq).Data.get_numbers();
ydata=layer.Transceivers(idx_freq).Data.get_range();

if isempty(axes_type)
    axes_type='Number';
end


switch axes_type
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time;
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers();
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist;
        if isempty(xdata_grid)
            disp('NO GPS Data');
            axes_type='Number';
            xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers();
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers();
end



Time=layer.Transceivers(idx_freq).Data.Time;
idx_start_time=[];
idx_end_time=[];
if length(layer.SurveyData)>=1
    idx_start_time=nan(1,length(layer.SurveyData));
    idx_end_time=nan(1,length(layer.SurveyData));
    for is=1:length(layer.SurveyData)
        surv_temp=layer.get_survey_data('Idx',is);
        if ~isempty(surv_temp)
            [~,idx_start_time(is)]=nanmin(abs(surv_temp.StartTime-Time));
            [~,idx_end_time(is)]=nanmin(abs(surv_temp.EndTime-Time));
        end
    end
end


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

idx_ping=idx_ping(1:floor(nanmin(screensize(3),length(idx_ping))));
nb_samples=length(idx_r);
nb_pings=length(idx_ping);

outputSize=nanmin(screensize(3:4),[nb_pings nb_samples]);


dr=nanmax(ceil(nb_samples/outputSize(2)),1);
dp=nanmax(ceil(nb_pings/outputSize(1)),1);
% dp=1;
% dr=1;

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
dt=nanmean(diff(xdata));

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

idx_change_file=find(diff(layer.Transceivers(idx_freq).Data.FileId)>0);

u=get(ax,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'file_id')||strcmp(get(u(ii),'tag'),'surv_id')
        delete(u(ii));
    end
end


for ifile=1:length(idx_change_file)
    plot(xdata(idx_change_file(ifile)).*ones(size(ydata(idx_r))),ydata(idx_r),'k','tag','file_id');
end

for ifile=1:length(idx_start_time)
    if ~isempty(idx_start_time(ifile))
        plot(xdata(idx_start_time(ifile)).*ones(size(ydata(idx_r)))+dt,ydata(idx_r),'g','tag','surv_id');
    end
end

for ifile=1:length(idx_end_time)
    if ~isempty(idx_end_time(ifile))
        plot(xdata(idx_end_time(ifile)).*ones(size(ydata(idx_r)))-dt,ydata(idx_r),'r','tag','surv_id');
    end
end

if strcmp(axes_type,'Time')
    dx=dx/(24*60*60);
end
cax=layer.Transceivers(idx_freq).Data.get_caxis(fieldname);

format_main_axes(ax,cax,axes_type,xdata_grid(idx_ping),ydata(idx_r),xdata(idx_ping),ydata(idx_r),dx,dy);

end