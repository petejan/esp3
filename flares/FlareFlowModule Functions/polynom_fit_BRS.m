function BRS_poly_fit=polynom_fit_BRS(BRS2,pol_order,r)
%r=linspace(0.001,0.009,200);
%BRS=load('ris_speed.txt');
%pol_order=7;
p = polyfit(BRS2(:,1),BRS2(:,2),pol_order);
B(1:max(size(r)),1:pol_order)=0;
for n=1:(pol_order+1)
B(1:max(size(r)),n)=p(n)*r.^(pol_order+1-n);
end
B=B';
BRS_poly_fit=sum(B);
% figure;plot(r,fun)
figure;
plot(BRS2(:,1),BRS2(:,2),'-bo',r,BRS_poly_fit,'-r')
hleg1 = legend('BSD','polynomial fit');

% hold on;plot(BSD(:,1),BSD(:,2),'Color','Red')
xlabel('radius(m)')
ylabel('BRS (cm/s)')
title('Bubble rising speed (red) and polynomial fit (blue)','Color','Black')