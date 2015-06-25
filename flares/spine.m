function [Lat,Long,depth_mean,Y_Geo_mean,X_Geo_mean,Zone_Geo_mean,...
    TSdB_mean,SvdB_mean]=spine(h,...
    n,TS2aver,Sv2aver,latd2aver,longd2aver,znew2aver)

x=get(h,'XData');
y=get(h,'YData');
z=get(h,'ZData');
j=1;

temp1=find(isnan(z)~=1);
lat=x(temp1);
lon=y(temp1);
znew=z(temp1);
clear temp

%[N,E,Z]=LLtoUTM(23 ,lat , lon);

clear x y z i j Z

% load TS2aver.mat
% clear Z_filt x_filt y_filt
temp=find(TS2aver~=0);
TSsmall=TS2aver(temp);
Svsmall=Sv2aver(temp);
lati=latd2aver(temp);
longi=longd2aver(temp);
zi=znew2aver(temp);

X1=[lat' lon' -znew'];
X2=[lati longi zi];
[Lia,Locb] = ismember(X2,X1,'rows');

temp=find(Locb~=0);

LALOZDB=[lati(temp) longi(temp) -zi(temp) TSsmall(temp) Svsmall(temp)];

[XGeo,YGeo,ZoneGeo]=deg2utm(LALOZDB(:,1), LALOZDB(:,2));


MIN_DEPTH=max(LALOZDB(:,3));
MAX_DEPTH=min(LALOZDB(:,3));
delta=abs(MAX_DEPTH-MIN_DEPTH)/n;

mov=MIN_DEPTH;
i=1;
while (mov-delta)>=MAX_DEPTH;
 
temp=find((LALOZDB(:,3)<=mov) & (LALOZDB(:,3)>(mov-delta)));

depth_mean(i,1)=mean(LALOZDB(temp,3));
Y_Geo_mean(i,1)=nangeomean(YGeo(temp));
X_Geo_mean(i,1)=nangeomean(XGeo(temp));
TSdB_mean(i,1)=10*log10(mean(10.^((LALOZDB(temp,4))/10)));
SvdB_mean(i,1)=10*log10(mean(10.^((LALOZDB(temp,5))/10)));
if isempty(temp)==1
    Zone_Geo_mean(i,1:4)= NaN(1,4);
else
    Zone_Geo_mean(i,1:4)=ZoneGeo(temp(1),:);
end
mov=mov-delta;
i=i+1;
end
clear i
notnan_ind=isnan(X_Geo_mean)==0;
depth_mean=depth_mean(notnan_ind);
Y_Geo_mean=Y_Geo_mean(notnan_ind);
X_Geo_mean=X_Geo_mean(notnan_ind);
TSdB_mean=TSdB_mean(notnan_ind);
Zone_Geo_mean=Zone_Geo_mean(notnan_ind,:);

Lat=NaN(length(depth_mean),1);
Long=NaN(length(depth_mean),1);
for i=1:length(depth_mean)
    [Lat(i,1),Long(i,1)]=utm2degx(X_Geo_mean(i), Y_Geo_mean(i), Zone_Geo_mean(i,:));
end
% figure;
% plot3(Lat,Long,-depth_mean,'Marker','o','MarkerFaceColor','Green')
% grid on;
% xlabel('Latitude')
% ylabel('Longitude')
% zlabel('Depth (meters)')
% title('"Flare Spine"')