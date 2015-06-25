function [Sp,Sv]=apply_new_absorption(Sp_ori,Sv_ori,range,alpha_ori,alpha)

[~,nb_pings]=size(Sp_ori);
dr=nanmean(diff(range(:)));
r_corr = 2*dr;

range_tvg=range-(r_corr);
range_tvg(range_tvg<0)=0;


Sp=Sp_ori+repmat(2*alpha*range_tvg-2*alpha_ori*range_tvg,1,nb_pings);

Sv=Sv_ori+repmat(2*alpha*range_tvg-2*alpha_ori*range_tvg,1,nb_pings);

end

        
        