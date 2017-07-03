function [x,y]=get_ellipse_xy(a,b,x0,y0,nb_pts)

t=linspace(-pi,pi,nb_pts);
x=x0+a*cos(t);
y=y0+b*sin(t);