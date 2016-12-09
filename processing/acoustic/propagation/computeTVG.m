function [TVG_Sp,TVG_Sv]=computeTVG(range,Np)

dr=nanmean(diff(range(:)));
r_corr = Np/2*dr;
%r_corr=0;

if size(range,1)==1
    range=range';
end

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

TVG_Sp = real(40*log10(range_tvg));
TVG_Sp(TVG_Sp<0)=0;
TVG_Sv =real(20*log10(range_tvg));
TVG_Sv(TVG_Sv<0)=0;

end