%% find_centre.m
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
% * |lat_cell|: TODO: write description and info on variable
% * |lon_cell|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |lat_centre|: TODO: write description and info on variable
% * |long_centre|: TODO: write description and info on variable
% * |lat_trans|: TODO: write description and info on variable
% * |long_trans|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-15: added centre computation for hills survey and weight computation (Yoann Ladroit).
% * 2017-04-13: first version. Methods to find centre for hill survey (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [lat_centre,long_centre,lat_trans,long_trans] = find_centre(lat_cell,lon_cell)
nb_trans=numel(lat_cell);
disp=0;
lat0=0;
long0=0;
for i=1:nb_trans
    nb_points=numel(lat_cell{i});
    idx_keep=nanmax(round(nb_points/4),1):nanmax(round(3*nb_points/4),1);
    lat0=lat0+median(lat_cell{i}(idx_keep));
    long0=long0+nanmean(lon_cell{i}(idx_keep));
end

lat0=lat0/nb_trans;
long0=long0/nb_trans;


[xinit,yinit,zone_init]=deg2utm(lat0,long0);

x=cell(1,nb_trans);
y=cell(1,nb_trans);
zone=cell(1,nb_trans);
a=nan(1,nb_trans);
b=nan(1,nb_trans);
c=nan(1,nb_trans);


for i=1:nb_trans
    nb_points=numel(lat_cell{i});
    idx_keep=nanmax(round(nb_points/4),1):nanmax(round(3*nb_points/4),1);
    [x{i},y{i},zone{i}]=deg2utm(lat_cell{i},lon_cell{i});
    %     x{i}=x{i}-xinit;
    %     y{i}=y{i}-yinit;
    p=polyfit(x{i}(idx_keep),y{i}(idx_keep),1);
    a(i)=-p(1);
    b(i)=1;
    c(i)=-p(2);
end




func_sum = @(xp) sum((a*xp(1)+b*xp(2)+c).^2./(a.^2+b.^2));

x_out=fminsearch(func_sum,[xinit,yinit]);

[lat_centre,long_centre]=utm2degx(x_out(1),x_out(2),zone_init);


lat_trans=nan(1,nb_trans);
long_trans=nan(1,nb_trans);

c2=b*x_out(1)-a*x_out(2);

y_trans=-(a.*c2+b.*c)./(a.^2+b.^2);
x_trans=(b.*c2-a.*c)./(a.^2+b.^2);

for i=1:nb_trans
    [lat_trans(i),long_trans(i)]=utm2degx(x_trans(i),y_trans(i),zone_init);
end
disp=1;
if disp>0
    hfig=new_echo_figure([]);
    ax=axes(hfig,'Nextplot','add');
    grid(ax,'on');
    for i=1:nb_trans
        x_lin=linspace(nanmin(x{i}),nanmax(x{i}),numel(x{i}));
        y_lin=-a(i)/b(i)*x_lin-c(i)/b(i);
        [lat_lin,long_lin]=utm2degx(x_lin',y_lin',repmat(zone{i},size(x_lin,1),1));
        plot(ax,lat_cell{i},lon_cell{i});
        plot(ax,lat_lin,long_lin,'--k');
    end
    
    plot(ax,lat0,long0,'x');
    plot(ax,lat_centre,long_centre,'s');
    plot(ax,lat_trans,long_trans,'*');
end



end


