function [x_lim_new,y_lim_new]=compute_xylim_zoom(x_lim,y_lim,varargin)


p = inputParser;

addRequired(p,'x_lim',@isnumeric);
addRequired(p,'y_lim',@isnumeric);
addParameter(p,'x_lim_tot',x_lim,@isnumeric);
addParameter(p,'y_lim_tot',y_lim,@isnumeric);
addParameter(p,'VerticalScrollCount',1,@isnumeric);
addParameter(p,'Position',[nanmean(x_lim) nanmean(y_lim)],@isnumeric);

parse(p,x_lim,y_lim,varargin{:});

dx=abs(diff(x_lim));
dy=diff(y_lim);
pos=p.Results.Position;


if p.Results.VerticalScrollCount<0
    x_lim_new=[pos(1) pos(1)]+[-3*dx/8 3*dx/8];
    y_lim_new=[pos(2) pos(2)]+[-3*dy/8 3*dy/8];   
else  
    x_lim_new=[pos(1) pos(1)]+[-5*dx/8 5*dx/8];
    y_lim_new=[pos(2) pos(2)]+[-5*dy/8 5*dy/8]; 
end

dx_new=abs(diff(x_lim_new));
dy_new=diff(y_lim_new);

if any(x_lim_new>p.Results.x_lim_tot(2))
    x_lim_new=[p.Results.x_lim_tot(2)-dx_new p.Results.x_lim_tot(2)];
end

if any(x_lim_new<p.Results.x_lim_tot(1))
    x_lim_new=[p.Results.x_lim_tot(1) dx_new+p.Results.x_lim_tot(1)];
end

if any(y_lim_new>p.Results.y_lim_tot(2))
    y_lim_new=[p.Results.y_lim_tot(2)-dy_new p.Results.y_lim_tot(2)];
end

if any(y_lim_new<p.Results.y_lim_tot(1))
    y_lim_new=[p.Results.y_lim_tot(1) dy_new+p.Results.y_lim_tot(1)];
end


x_lim_new(x_lim_new>p.Results.x_lim_tot(2))=p.Results.x_lim_tot(2);
x_lim_new(x_lim_new<p.Results.x_lim_tot(1))=p.Results.x_lim_tot(1);

y_lim_new(y_lim_new>p.Results.y_lim_tot(2))=p.Results.y_lim_tot(2);
y_lim_new(y_lim_new<p.Results.y_lim_tot(1))=p.Results.y_lim_tot(1);


end