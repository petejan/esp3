function [sp,sv]=convert_power_lin(power,range_t,c,alpha,t_eff,t_nom,ptx,lambda,gain,eq_beam_angle,sacorr,type)
dr=nanmean(diff(range_t(:)));

Np=c*t_nom/2/dr;

[TVG_Sp,TVG_Sv]=computeTVG(range_t,Np);

r_corr = Np/2*dr;
%r_corr=0;

if size(range_t,1)==1
    range_t=range_t';
end

range_t_tvg=range_t-(r_corr);
range_t_tvg(range_t_tvg<0)=0;

switch type
     case {'FCV30'} 
        tmp=db2pow_perso(10*log10(single(power))-2*gain);
        sp=bsxfun(@times,tmp,db2pow_perso(TVG_Sp+2*alpha*range_t_tvg));
        sv=bsxfun(@times,tmp/db2pow_perso(10*log10(c*t_eff/2)-eq_beam_angle-2*sacorr),db2pow_perso(TVG_Sv+2*alpha*range_t_tvg));
    case {'ASL'}
        sp=bsxfun(@times,power,db2pow_perso(TVG_Sp+2*alpha*range_t_tvg));
        sv=bsxfun(@times,power/db2pow_perso(10*log10(c*t_eff/2)+eq_beam_angle),db2pow_perso(TVG_Sv+2*alpha*range_t_tvg));
    otherwise          
        tmp=bsxfun(@rdivide,power,db2pow_perso(2*gain+10*log10(ptx*lambda^2/(16*pi^2))));
        sp=bsxfun(@times,tmp,db2pow_perso(TVG_Sp+2*alpha*range_t_tvg));
        sv=bsxfun(@times,tmp/db2pow_perso(10*log10(c*t_eff/2)+eq_beam_angle+2*sacorr),db2pow_perso(TVG_Sv+2*alpha*range_t_tvg));       
end

end

        
        