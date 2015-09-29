function compensation = attCompensation(faBW, psBW, roll_t, pitch_t,roll_r,pitch_r)
% Calculates the simard beam compensation given the beam angles and
% positions in the beam

alpha=(faBW+psBW)/2/180*pi;

phi_t = atan(sqrt( tand(roll_t).^2 + tand(pitch_t).^2 ));
theta_t = atan (tand(roll_t) ./ tand(pitch_t));

phi_r = atan(sqrt( tand(roll_r).^2 + tand(pitch_r).^2 ));
theta_r = atan (tand(roll_r) ./ tand(pitch_r));

cosmu=sin(phi_t).*cos(theta_t).*sin(phi_r).*cos(theta_r) +...
    sin(phi_t).*sin(theta_t).*sin(phi_r).*sin(theta_r) + ...
    cos(phi_t).*cos(phi_t);
mu = abs(acos(cosmu)) ;

x=sin(mu)/sin(alpha/2);

k = 0.17083*x.^5 - 0.39660*x.^4 + 0.53851*x.^3 + 0.13764*x.^2 + 0.039645*x + 1;

compensation=10*log10(k);
compensation(abs(mu)>alpha)=nan;
end