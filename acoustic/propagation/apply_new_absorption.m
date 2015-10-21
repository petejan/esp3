function Sxx=apply_new_absorption(Sxx_ori,range,alpha_ori,alpha)

[~,nb_pings]=size(Sxx_ori);

dr=nanmean(diff(range(:)));
r_corr = 2*dr;

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;

Sxx=Sxx_ori+repmat(2*alpha*range_tvg-2*alpha_ori*range_tvg,1,nb_pings);

end

        
        