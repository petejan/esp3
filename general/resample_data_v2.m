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
             idx_nearest=nan(1,length(idx_nan));
            for ij=1:length(idx_nan)
                [~,idx_nearest(ij)]=min(abs(xdata-xdata_n(idx_nan(ij))));
            end
            ydata_new(idx_nan)=ydata(idx_nearest);
            ydata_new(idx_nan)=ydata(idx_nearest);
        end
end

end

