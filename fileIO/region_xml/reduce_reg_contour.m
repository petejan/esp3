function [x,y]=reduce_reg_contour(x,y,thr)

nb_elt_x=cellfun(@numel,x);
if any(nb_elt_x>=thr)
    x(nb_elt_x<thr)=[];
    y(nb_elt_x<thr)=[];
end