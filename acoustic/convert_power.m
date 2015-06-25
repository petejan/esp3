function [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr)

[~,nb_pings]=size(power);
dr=nanmean(diff(range(:)));
r_corr = 2*dr;
%r_corr=0;

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

TVG_Sp =real(40*log10(range_tvg));
TVG_Sp(TVG_Sp<0)=0;
TVG_Sv =real(20*log10(range_tvg));
TVG_Sv(TVG_Sv<0)=0;

Sp=10*log10(power)+repmat(TVG_Sp+2*alpha*range_tvg,1,nb_pings)-10*log10(ptx*lambda^2/(16*pi^2))-2*gain;

Sv=10*log10(power)+repmat(TVG_Sv+2*alpha*range_tvg,1,nb_pings)-10*log10(c*t_eff/2)-10*log10(ptx*lambda^2/(16*pi^2))-2*gain-eq_beam_angle-2*sacorr;

end

        
        