function PSI=calculates_PSI(depth,cw,ethas,rhow,cp,gamma,kcond,rhoG0,...
    Pst0,g,freq,fun,r,ris_speed,sample_interval,sigma)

%  buovel clean bubble =0; dirty=1
% 'Woolf93'            => Only Dirty
% 'Woolf & Thorpe91'   => 
% 'Memery & Merlivat'  => Only Clean
% 'Leifer'
% 'Mendelson'          => Only Clean; only for r>rc.
% 'Leifer&Patro'                 Continental Shelf Research, Accepted
% 'Off'   yields Rise Velocities = 0 for all radii
%  ris_speed=(buoyvel(r*100,temp,bubble_type,sel_BRS,Sal ))/100; (m/s)
dist_sample=cw*sample_interval/2;
int_nom=(4*pi/3/dist_sample.*ris_speed).*fun.*r.^3;
nom=trapz(r,int_nom);

Pst=Pst0+rhow*g*depth; %static pressure (Pa)
r_fix=sqrt(3*gamma*Pst/rhow)/(2*pi*freq);
k=2*pi*freq/cw;
rhoG=rhoG0*(1+2*sigma./(Pst*r))*(1+0.1*depth);%density at the measurement depth (Kg/m3)
Da=kcond./(rhoG*cp); %Thermal diffusivity gas m2/s
wM=sqrt(3*gamma*Pst./(rhow*r.*r));%Minneart frequecy rad/s


%dimensionless damping (Ainslie)
Drad=wM.*r/cw; %radiation damping term
Dtherm=3*(gamma-1)./r.*sqrt(Da./(2*wM));%thermal damping term
XX=(1/3+2.2)*ethas;
Dvisc=3*XX./(rhow*wM.*r.*r);%viscous damping term
damp=Drad+Dtherm+Dvisc;%total dimensionless damping

%backscattering Thurainsingham (1997)
Thur_factor=(sin(k*r)./(k*r)).*(sin(k*r)./(k*r))./...
    (1+(k*r).*(k*r));%Thuraisingham factor

int_den=(fun.*r.^2./(((r_fix./r).^2-1).^2+damp.^2)).*Thur_factor;

den=trapz(r,int_den);
PSI=nom/den;

sprintf('coefficient K: %f', PSI)