function [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr)


[TVG_Sp,TVG_Sv]=computeTVG(range);

dr=nanmean(diff(range(:)));
r_corr = 2*dr;
%r_corr=0;

if size(range,1)==1
    range=range';
end

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

tmp=bsxfun(@plus,10*log10(power)-2*gain-10*log10(ptx*lambda^2/(16*pi^2)),2*alpha*range_tvg);

Sp=bsxfun(@plus,tmp,TVG_Sp);

Sv=bsxfun(@plus,tmp-10*log10(c*t_eff/2)-eq_beam_angle-2*sacorr,TVG_Sv);

end

        
        