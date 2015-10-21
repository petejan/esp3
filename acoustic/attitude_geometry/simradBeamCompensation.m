function compensation = simradBeamCompensation(faBW, psBW, faAngle, psAngle)
% Calculates the simard beam compensation given the beam angles and
% positions in the beam

part1 = 2*faAngle/faBW;
part2 = 2*psAngle/psBW;

compensation = 6.0206 * (part1.^2 + part2.^2 - 0.18*part1.^2.*part2.^2);

end