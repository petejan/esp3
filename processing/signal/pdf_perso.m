%[pdf,x]=pdf_perso(X,varargin)
% Input:
% X: vector containing samples
% bin: either number of bins or vector containing the center of each bin
% for pdf processing
% weight_idx: weight applied to each sampled durring pdf processing
% win_type: 'box' or 'gaussian'

function [pdf,x]=pdf_perso(X,varargin)


p = inputParser;

addRequired(p,'X',@isnumeric);
addParameter(p,'bin',ceil(length(X(~isnan(X)))/100),@isnumeric);
addParameter(p,'weight',ones(size(X)),@isnumeric);
addParameter(p,'win_type','box',@(str) ischar(str));


parse(p,X,varargin{:});

bin=p.Results.bin;
weight_idx=p.Results.weight;
win_type=p.Results.win_type;


X(X==Inf|X==-Inf)=nan;
idx_non_nan=~isnan(X);
X=X(idx_non_nan);
weight_idx=weight_idx(idx_non_nan);
w_tot=sum(weight_idx);

if length(bin)==1
    N=max(bin,2);
   
    maxi=max(X(:));
    mini=min(X(:));
    x=linspace(mini,maxi,N);
    dx=(maxi-mini)/(N-1);
    
%     switch win_type
%         case 'box'
%             bin_mat=bsxfun(@(u,v) (u-v)/dx<=1/2&(u-v)/dx>-1/2,X(:),x(:)');
%         case 'gauss'
%             bin_mat=(1/(sqrt(2*pi))*exp(-(bsxfun(@minus,X(:),x(:)')).^2/(2*dx^2)));
%             %bin_mat=bsxfun(@(u,v) (1/(sqrt(2*pi))*exp(-(u-v).^2/(2*dx^2))),X(:),x(:)');
%     end
%     pdf=sum(bsxfun(@times,weight_idx(:),bin_mat/(dx*w_tot)));
 
    pdf=zeros(1,N);
    for i=1:N
        if strcmp(win_type,'box')
            idx_bin=((X-x(i))/dx<=1/2&(X-x(i))/dx>-1/2);
            pdf(i)=sum(weight_idx(idx_bin))/(dx*w_tot);
        elseif strcmp(win_type,'gauss')
            pdf(i)=sum(weight_idx.*(1/(dx*sqrt(2*pi))*exp(-(X-x(i)).^2/(2*dx^2))))/(w_tot);
        end
        
    end

else
    N=nanmax(length(bin),2);
    pdf=zeros(1,N);
    grad_bin=gradient(bin);
    x=bin;
    

    for i=1:N
        if strcmp(win_type,'box')
            idx_bin=(X>=bin(i)-grad_bin(i)/2&X<bin(i)+grad_bin(i)/2);
            pdf(i)=sum(weight_idx(idx_bin)./grad_bin(i))/w_tot;
        elseif strcmp(win_type,'gauss')
            parz_win=1/(grad_bin(i)*sqrt(2*pi))*exp(-(X-bin(i)).^2/(2*grad_bin(i)^2));
            pdf(i)=sum(weight_idx.*parz_win)/(w_tot);
        end
    end
end

end