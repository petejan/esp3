function [ydata_new,xdata_diff,idx_choice]=resample_data(ydata,xdata,xdata_n,varargin)
p = inputParser;

addRequired(p,'ydata',@isnumeric);
addRequired(p,'xdata',@isnumeric);
addRequired(p,'xdata_n',@isnumeric);
addParameter(p,'Opt','Neighbours',@ischar);
addParameter(p,'Type','Real',@ischar);

parse(p,ydata,xdata,xdata_n,varargin{:});

[xdata,I]=sort(xdata);
ydata=ydata(I);

idx_choice=nan(1,length(xdata_n));
xdata_diff=nan(1,length(xdata_n));
for jj=1:length(xdata_n)
    [xdata_diff(jj),idx_choice(jj)]=nanmin(abs(xdata-xdata_n(jj)));
end


idx_choice_plus=nanmin(idx_choice+1,length(xdata));
idx_choice_minus=nanmax(idx_choice-1,1);


switch p.Results.Opt
    case {'Neighbours','Linear'}
        nb_stable=length(xdata);
        while nansum(xdata(idx_choice_plus)==xdata(idx_choice))<nb_stable
            idx_choice_plus(xdata(idx_choice_plus)==xdata(idx_choice))=nanmin(idx_choice_plus(xdata(idx_choice_plus)==xdata(idx_choice))+1,length(xdata));
            nb_stable=nansum(xdata(idx_choice_plus)==xdata(idx_choice));
        end
        
        nb_stable=length(xdata);
        while nansum(xdata(idx_choice_minus)==xdata(idx_choice_minus))<nb_stable
            idx_choice_plus(xdata(idx_choice_minus)==xdata(idx_choice))=nanmax(idx_choice_minus(xdata(idx_choice_minus)==xdata(idx_choice))-1,1);
            nb_stable=nansum(xdata(idx_choice_minus)==xdata(idx_choice));
        end
end

switch p.Results.Type
    case 'Real'
        ydata_use=ydata;
    case 'Angle'
        ydata_use=exp(1i*ydata/180*pi);
end

switch p.Results.Opt
    case 'Nearest'
        ydata_new_temp=ydata_use(idx_choice);
    case 'Linear'
        slope=(ydata_use(idx_choice_plus)-ydata_use(idx_choice))./(xdata(idx_choice_plus)-xdata(idx_choice));
        intercept=1/2*((ydata_use(idx_choice_plus)+ydata_use(idx_choice))-slope.*(xdata(idx_choice_plus)+xdata(idx_choice)));       
        ydata_new_temp=slope.*xdata_n+intercept;        
        ydata_new_temp(xdata(idx_choice_plus)==xdata(idx_choice))=ydata(idx_choice(xdata(idx_choice_plus)==xdata(idx_choice)));
        ydata_new_temp(xdata_diff<1e-9)=ydata(idx_choice(xdata_diff<1e-9));
    case 'Neighbours'
        ydata_new_temp=1/3*(ydata_use(idx_choice)+ydata_use(idx_choice_plus)+ydata_use(idx_choice_minus));
end

switch p.Results.Type
    case 'Real'
        ydata_new=ydata_new_temp;
    case 'Angle'
        ydata_new=sign(asin(imag(ydata_new_temp))).*acos(real(ydata_new_temp))/pi*180;
end

if nansum((size(xdata_diff)==size(xdata_n)))<2
    xdata_diff=xdata_diff';
end


end

