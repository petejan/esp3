function [abscf_mean,abscf_sd]=calc_abscf_and_sd(trans_abscf)
nb_trans=length(trans_abscf);
abscf_mean= nansum(trans_abscf)/nb_trans;


if nb_trans>1
    abscf_sd = sqrt(nansum((trans_abscf-abscf_mean).^2)/((nb_trans-1)));
else
    abscf_sd=0;
end
end

