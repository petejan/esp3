function Mask_out=grid_mask_from_cont(x_grid,y_grid,x,y)

contour_type=ones(1,length(x));
[contour_type,idx_order]=order_contours(x,y,contour_type,0);
Mask_out=zeros(size(x_grid));

for i=idx_order
   in=inpolygon(x_grid,y_grid,x{i},y{i});
   Mask_out(in)=contour_type(i);
end

