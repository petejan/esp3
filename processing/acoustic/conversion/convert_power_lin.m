function [sp,sv]=convert_power_lin(power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr,type)


[TVG_Sp,TVG_Sv]=computeTVG(range);

dr=nanmean(diff(range(:)));
r_corr = 2*dr;
%r_corr=0;

if size(range,1)==1
    range=range';
end

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

profile on;
switch type
    case {'ASL'};    
        sp=bsxfun(@times,power,db2pow_perso(TVG_Sp+2*alpha*range_tvg));
        sv=bsxfun(@times,power/db2pow_perso(10*log10(c*t_eff/2)+eq_beam_angle),db2pow_perso(TVG_Sv+2*alpha*range_tvg));
    otherwise   
       
        tmp=power/db2pow_perso(2*gain+10*log10(ptx*lambda^2/(16*pi^2)));
        sp=bsxfun(@times,tmp,db2pow_perso(TVG_Sp+2*alpha*range_tvg));
        sv=bsxfun(@times,tmp/db2pow_perso(10*log10(c*t_eff/2)+eq_beam_angle+2*sacorr),db2pow_perso(TVG_Sv+2*alpha*range_tvg));
       
end

end

        
        