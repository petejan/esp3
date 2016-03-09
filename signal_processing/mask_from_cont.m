function Mask_out=mask_from_cont(x,y,nb_x,nb_y)

contour_type=ones(1,length(x));
[contour_type,idx_order]=order_contours(x,y,contour_type,0);
Mask_out=zeros(nb_x,nb_y);

for i=idx_order
   in=poly2mask(x{i},y{i},nb_x,nb_y);
   Mask_out(in)=contour_type(i);
end
