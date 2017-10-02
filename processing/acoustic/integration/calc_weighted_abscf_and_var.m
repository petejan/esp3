function [abscf_wmean,abscf_var]=calc_weighted_abscf_and_var(trans_abscf,dist)
abscf_wmean= nansum(dist.*trans_abscf)/ nansum(dist);
nb_trans=length(trans_abscf);

if nb_trans>1
    abscf_var = (nansum(dist.^2.*trans_abscf.^2)...
        -2*abscf_wmean*nansum(dist.^2.*trans_abscf)+...
        abscf_wmean^2*nansum(dist.^2))*...
        nb_trans/((nb_trans-1)*nansum(dist)^2); 
%     
%     abscf_var=nansum((trans_abscf-abscf_wmean).^2.*dist.^2)*...
%         nb_trans/((nb_trans-1)*nansum(dist)^2);
else
    abscf_var=0;
end

end