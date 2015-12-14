function [ydata_new,idx_nearest]=resample_data_v2(ydata,xdata,xdata_n,varargin)
p = inputParser;

addRequired(p,'ydata',@isnumeric);
addRequired(p,'xdata',@isnumeric);
addRequired(p,'xdata_n',@isnumeric);
addParameter(p,'Opt','Linear',@ischar);
addParameter(p,'Type','Real',@ischar);

parse(p,ydata,xdata,xdata_n,varargin{:});

[xdata,IA,~] = unique(xdata);
ydata=ydata(IA);

idx_nearest=nan(1,length(xdata_n));

for jj=1:length(xdata_n)
    [~,idx_nearest(jj)]=nanmin(abs(xdata-xdata_n(jj)));
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

switch p.Results.Opt
    case 'Linear'
        idx_nan=find(isnan(ydata_new));
        if ~isempty(idx_nan)
            ydata_new(idx_nan(1))=ydata(idx_nearest(idx_nan(1)));
            ydata_new(idx_nan(end))=ydata(idx_nearest(idx_nan(end)));
        end
end

end

