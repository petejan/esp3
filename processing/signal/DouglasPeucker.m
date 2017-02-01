function [x_out,y_out,idx_keep]=DouglasPeucker(x,y,epsilon,i_start)
% Find the point with the maximum distance

len = length(x);

d = perp_dist([x(1) y(1)],[x(end) y(end)],[x y]);

[dmax,index]=nanmax(d);

% If max distance is greater than epsilon, recursively simplify
if ( dmax > epsilon )
    % Recursive call
    [x_1,y_1,idx_keep_1] = DouglasPeucker(x(1:index),y(1:index), epsilon,i_start);
    [x_2,y_2,idx_keep_2] = DouglasPeucker(x(index:len),y(index:len),epsilon,i_start+index-1);
    
    % Build the result list
    idx_keep=unique([idx_keep_1 idx_keep_2]);
    x_out = [x_1(1:length(x_1)-1); x_2];
    y_out = [y_1(1:length(y_1)-1); y_2];
    
   
else
    x_out = [x(1);x(end)];
    y_out = [y(1);y(end)];
    idx_keep=[1 length(x)]+i_start;
end
end

function dist=perp_dist(p1,p2,p0)
    dist=abs((p2(2)-p1(2))*p0(:,1)-(p2(1)-p1(1))*p0(:,2)+p2(1)*p1(2)-p2(2)*p1(1))./sqrt((p2(2)-p1(2)).^2+(p2(1)-p1(1)).^2);
end
