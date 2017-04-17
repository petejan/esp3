%% DouglasPeucker.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |x|: TODO: write description and info on variable
% * |y|: TODO: write description and info on variable
% * |epsilon|: TODO: write description and info on variable
% * |i_start|: TODO: write description and info on variable
% * |nb_max|: TODO: write description and info on variable
% * |nb_ite|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |x_out|: TODO: write description and info on variable
% * |y_out|: TODO: write description and info on variable
% * |idx_keep|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-15: mods (Yoann Ladroit).
% * 2017-02-02: first version, Douglas Peucker algorithm to simplify gps tracks (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [x_out,y_out,idx_keep]=DouglasPeucker(x,y,epsilon,i_start,nb_max,nb_ite)
% Find the point with the maximum distance

len = length(x);

d = perp_dist([x(1) y(1)],[x(end) y(end)],[x y]);

[dmax,index]=nanmax(d);

% If max distance is greater than epsilon, recursively simplify
if ( dmax > epsilon )&& nb_max>nb_ite
    nb_ite=nb_ite+1;
    % Recursive call
    [x_1,y_1,idx_keep_1] = DouglasPeucker(x(1:index),y(1:index), epsilon,i_start,nb_max,nb_ite);
    [x_2,y_2,idx_keep_2] = DouglasPeucker(x(index:len),y(index:len),epsilon,i_start+index-1,nb_max,nb_ite);
    
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
