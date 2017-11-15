function [contour_type,idx_order]=order_contours(x,y,contour_type,prev_type)


if length(x)==1
    contour_type=(prev_type==0);
    idx_order=1;
    return;
end

bbox=[cellfun(@min,y);cellfun(@min,x);cellfun(@max,y);cellfun(@max,x)]';

% bbox=nan(length(x),4);

% for u=1:length(x)
%     bbox(u,:)=[min(y{u}) min(x{u}) max(y{u}) max(x{u})];
% end

area=(bbox(:,3)-bbox(:,1)).*(bbox(:,4)-bbox(:,2));

[~,idx_max]=nanmax(area);
idx=1:length(x);

contour_type(idx_max)=(prev_type==0);

idx_in=idx(sum((bsxfun(@minus,bbox(idx_max,1:2),bbox(:,1:2)))<0,2)==2&sum((bsxfun(@minus,bbox(idx_max,3:4),bbox(:,3:4)))>0,2)==2);

idx(idx_max)=[];
idx_out=setdiff(idx,idx_in);

idx_order=idx_max;

if ~isempty(idx_in)
    [contour_type(idx_in),idx_order_in]=order_contours(x(idx_in),y(idx_in),contour_type(idx_in),prev_type==0);
     idx_order=[idx_order idx_in(idx_order_in)];
end

if ~isempty(idx_out)
    [contour_type(idx_out),idx_order_out]=order_contours(x(idx_out),y(idx_out),contour_type(idx_out),prev_type==1);
    idx_order=[idx_order idx_out(idx_order_out)];
end

end