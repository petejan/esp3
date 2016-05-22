function ydata_new=resample_data_v2(ydata,xdata,xdata_n,varargin)
p = inputParser;

addRequired(p,'ydata',@isnumeric);
addRequired(p,'xdata',@isnumeric);
addRequired(p,'xdata_n',@isnumeric);
addParameter(p,'Opt','Linear',@ischar);
addParameter(p,'Type','Real',@ischar);

parse(p,ydata,xdata,xdata_n,varargin{:});
idx_nan=isnan(xdata);

xdata(idx_nan)=[];
ydata(idx_nan)=[];
[xdata,IA,~] = unique(xdata);
ydata=ydata(IA);

if length(ydata)==1
    ydata_new=repmat(ydata,size(xdata_n,1),size(xdata_n,2));
     return;
end


switch p.Results.Type
    case 'Real'
        ydata_use=ydata;
    case 'Angle'
        ydata_use=exp(1i*ydata/180*pi);
end

switch p.Results.Opt
    case 'Nearest'
        ydata_new_temp = interp1(xdata,ydata_use,xdata_n,'nearest');
    case 'Linear'
        ydata_new_temp = interp1(xdata,ydata_use,xdata_n);
end

switch p.Results.Type
    case 'Real'
        ydata_new=ydata_new_temp;
    case 'Angle'
        ydata_new=sign(asin(imag(ydata_new_temp))).*acos(real(ydata_new_temp))/pi*180;
end


idx_nan=find(isnan(ydata_new));
idx_nonan_ori=find(~isnan(ydata));
if ~isempty(idx_nan)&&strcmp(p.Results.Opt,'Linear')&&~isempty(idx_nonan_ori)
    idx_nearest=nan(1,length(idx_nan));
    dx=nanmean(diff(xdata_n));
    dx_old=nanmean(diff(xdata));
    idx_far=[];
    for ij=1:length(idx_nan)
        [val,idx_nearest(ij)]=min(abs(xdata(idx_nonan_ori)-xdata_n(idx_nan(ij))));
        if val>nanmax(10*dx_old,10*dx)
            idx_far=[idx_far ij];
        end
    end
    ydata_temp=ydata(idx_nonan_ori);
    idx_nan(idx_far)=[];
    idx_nearest(idx_far)=[];
    ydata_new(idx_nan)=ydata_temp(idx_nearest);
end
end



