function [fun,r]=polynom_fit_BSD(BSD,pol_order)
p = polyfit(BSD(:,1),BSD(:,2),pol_order);
r=linspace(min(BSD(:,1)),max(BSD(:,1)),200);
B(1:max(size(r)),1:pol_order)=0;
for n=1:(pol_order+1)
B(1:max(size(r)),n)=p(n)*r.^(pol_order+1-n);
end
B=B';
fun=sum(B);
clear B
fun(fun<0)=0;

figure;
plot(BSD(:,1),BSD(:,2),'-bo',r,fun,'-r')
legend('BSD','polynomial fit');
xlabel('radius(m)')
ylabel('Frequency normalized')
title('Bubble Size distribution (red) and polynomial fit (blue)','Color','Black')

%probability density function
dr=abs(r(1)-r(2));
fun=fun/sum(fun)/dr;
clear dr BSD

