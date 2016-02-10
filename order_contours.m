function [contour_type,idx_order]=order_contours(x,y,contour_type,prev_type)

bbox=nan(length(x),4);

if length(x)==1
    contour_type=(prev_type==0);
    idx_order=1;
    return;
end
for u=1:length(x)
    bbox(u,:)=[nanmin(y{u}) nanmin(x{u}) nanmax(y{u}) nanmax(x{u})];
end

area=(bbox(:,3)-bbox(:,1)).*(bbox(:,4)-bbox(:,2));
[~,idx_max]=nanmax(area);
idx=1:length(x);
idx(idx_max)=[];
contour_type(idx_max)=(prev_type==0);

idx_in=[];

for u=idx
    if nansum((bbox(idx_max,1:2)-bbox(u,1:2))<0)==2&nansum((bbox(idx_max,3:4)-bbox(u,3:4))>0)==2
        idx_in=[idx_in u];
    end
end

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