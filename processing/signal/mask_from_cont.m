function Mask_out=mask_from_cont(x,y,nb_x,nb_y)

contour_type=ones(1,length(x));
[contour_type,idx_order]=order_contours(x,y,contour_type,0);
Mask_out=false(nb_x,nb_y);

% [nb_samples,nb_pings]=size(Mask_out);
% [P,S]=meshgrid(1:nb_pings,1:nb_samples);

for i=idx_order
   %in=inpolygon(S,P,y{i},x{i});
   in=poly2mask(x{i},y{i},nb_x,nb_y);
   Mask_out(in)=contour_type(i);
   Mask_out(y{i}+(x{i}-1)*nb_x)=contour_type(i);
end

Mask_out=Mask_out>=1;