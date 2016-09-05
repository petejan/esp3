function power=remove_TVG_from_Sp(Sp,range,alpha)

[TVG_Sp,~]=computeTVG(range);

dr=nanmean(diff(range(:)));
r_corr = 2*dr;


if size(range,1)==1
    range=range';
end

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;


power=db2pow_perso(bsxfun(@minus,Sp,TVG_Sp+2*alpha*range_tvg));



end

        
        