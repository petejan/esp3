function Mask_out=mask_from_poly(poly)

% contour_type=ones(1,length(x));
% [contour_type,idx_order]=order_contours(x,y,contour_type,0);

[xlim,ylim]=poly.boundingbox;
xlim=round(xlim);
ylim=round(ylim);
nb_x=(diff(xlim)+1);
nb_y=(diff(ylim)+1);
regs=poly.regions;
Mask_out=false(nb_y,nb_x);

for ireg=1:numel(regs)
    
    [xlim_sub,ylim_sub]=regs(ireg).boundingbox;
    xlim=round(xlim);
    ylim=round(ylim);
    nb_x_sub=diff(xlim_sub)+1;
    nb_y_sub=diff(ylim_sub)+1;
   
    Mask_out_tmp=Mask_out((ylim_sub(1):ylim_sub(end))-ylim(1)+1,(xlim_sub(1):xlim_sub(end))-xlim(1)+1);
    [x,y]=vertices2contours(regs(ireg).Vertices);
    
    x=cellfun(@(u) round(u)-xlim_sub(1)+1,x,'un',0);
    y=cellfun(@(u) round(u)-ylim_sub(1)+1,y,'un',0);
    
    [x,y]=reduce_reg_contour(x,y,10);
    if isempty(x)
        continue;
    end
    
    %temp=poly2mask(regs(ireg).Vertices(2,:),regs(ireg).Vertices(1,:),nb_y_sub,nb_x_sub);
    
    contour_type=false(1,numel(x));
    contour_type(1)=true;
    
    in=cellfun(@(u,v) poly2mask(u,v,nb_y_sub,nb_x_sub),x,y,'un',0);
    for i=1:numel(in)        
        Mask_out_tmp(in{i})=contour_type(i);
        Mask_out_tmp(y{i}+(x{i}-1)*nb_y_sub)=contour_type(i);
    end
    
    Mask_out((ylim_sub(1):ylim_sub(end))-ylim(1)+1,(xlim_sub(1):xlim_sub(end))-xlim(1)+1)=Mask_out_tmp;
end

% [nb_samples,nb_pings]=size(Mask_out);
% [P,S]=meshgrid(1:nb_pings,1:nb_samples);


Mask_out=Mask_out>=1;