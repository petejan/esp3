%[pdf,x]=pdf_perso(X,varargin)
% Input:
% X: vector containing samples
% bin: either number of bins or vector containing the center of each bin
% for pdf processing
% weight_idx: weight applied to each sampled durring pdf processing
% win_type: 'box' or 'gaussian'

function [pdf,x]=pdf_perso(X,varargin)

bin=10;
weight_idx=ones(size(X));
win_type='box';

for n = 1:2:length(varargin)
    switch lower(varargin{n})
        case 'bin'
            bin = varargin{n + 1};
        case 'weight'
            weight_idx=varargin{n + 1};
        case 'win_type'
            win_type=varargin{n + 1};
        otherwise
            warning('pdf_perso:ParameterError', ['Unknown property name: ' varargin{n}]);
    end
end

X(X==Inf|X==-Inf)=nan;
w_tot=nansum(weight_idx(~isnan(X)));

if length(bin)==1
    N=nanmax(bin,2);
    pdf=zeros(1,N);
    maxi=nanmax(X(:));
    mini=nanmin(X(:));
    x=linspace(mini,maxi,N);
    dx=gradient(x);
    vec_X=X(~isnan(X));
    for i=1:N
        if strcmp(win_type,'box')
            idx_bin=((vec_X-x(i))/dx(i)<=1/2&(vec_X-x(i))/dx(i)>-1/2);
            pdf(i)=sum(weight_idx(idx_bin))/(dx(i)*w_tot);
        elseif strcmp(win_type,'gauss')
            parz_win=1/(dx(i)*sqrt(2*pi))*exp(-(vec_X-x(i)).^2/(2*dx(i)^2));
            pdf(i)=nansum(weight_idx(~isnan(X)).*parz_win)/(w_tot);
        end
        
    end
else
    N=nanmax(length(bin),2);
    pdf=zeros(1,N);
    grad_bin=gradient(bin);
    vec_X=X(~isnan(X));
    x=bin;
    for i=1:N
        if strcmp(win_type,'box')
            idx_bin=(vec_X>=bin(i)-grad_bin(i)/2&vec_X<bin(i)+grad_bin(i)/2);
            pdf(i)=sum(weight_idx(idx_bin))/(nanmean(grad_bin)*w_tot);
        elseif strcmp(win_type,'gauss')
            parz_win=1/(grad_bin(i)*sqrt(2*pi))*exp(-(vec_X-bin(i)).^2/(2*grad_bin(i)^2));
            pdf(i)=nansum(weight_idx(~isnan(X)).*parz_win)/(w_tot);
        end
    end
end

end