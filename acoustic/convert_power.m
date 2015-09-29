function [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr)

[~,nb_pings]=size(power);


[TVG_Sp,TVG_Sv]=computeTVG(range);


dr=nanmean(diff(range(:)));
r_corr = 2*dr;
%r_corr=0;

if size(range,1)==1
    range=range';
end

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;


Sp=10*log10(power)+repmat(TVG_Sp+2*alpha*range_tvg,1,nb_pings)-10*log10(ptx*lambda^2/(16*pi^2))-2*gain;

Sv=10*log10(power)+repmat(TVG_Sv+2*alpha*range_tvg,1,nb_pings)-10*log10(c*t_eff/2)-10*log10(ptx*lambda^2/(16*pi^2))-2*gain-eq_beam_angle-2*sacorr;

end

        
        