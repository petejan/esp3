function diff_db=compute_abs_diff(range,alpha_ori,alpha,Np)

dr=nanmean(diff(range(:)));
r_corr = Np/2*dr;

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

diff_db=2*alpha*range_tvg-2*alpha_ori*range_tvg;

end

        
        