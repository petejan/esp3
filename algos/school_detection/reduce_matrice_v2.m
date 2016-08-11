function K=reduce_matrice_v2(dist_pings,range,curr_candidates,other_candidates,horz_link_max,vert_link_max)

%nb_pings=length(dist_pings);
nb_samples=length(range);


I_curr_can=rem(curr_candidates,nb_samples);
I_curr_can(I_curr_can==0)=nb_samples;
J_curr_can=ceil(curr_candidates/nb_samples);

I_other_can=rem(other_candidates,nb_samples);
I_other_can(I_other_can==0)=nb_samples;
J_other_can=ceil(other_candidates/nb_samples);


idx_col=(dist_pings>=(nanmin(dist_pings(J_curr_can))-horz_link_max))&(dist_pings<=(nanmax(dist_pings(J_curr_can))+horz_link_max));
idx_row=(range>=(nanmin(range(I_curr_can))-vert_link_max))&(range<=(nanmax(range(I_curr_can))+vert_link_max));

idx_col_other=(dist_pings>=(nanmin(dist_pings(J_other_can))-horz_link_max))&(dist_pings<=(nanmax(dist_pings(J_other_can))+horz_link_max));
idx_row_other=(range>=(nanmin(range(I_other_can))-vert_link_max))&(range<=(nanmax(range(I_other_can))+vert_link_max));
% tic
% idx_row_tot_first=find(idx_row&idx_row_other,1);
% idx_col_tot_first=find(idx_col&idx_col_other,1);
% idx_row_tot_last=find(idx_row&idx_row_other,1,'last');
% idx_col_tot_last=find(idx_col&idx_col_other,1,'last');
% 
% 
% K=(idx_row_tot_first+(idx_col_tot_first-1)*nb_samples):(idx_row_tot_last+(idx_col_tot_last-1)*nb_samples);
% toc

idx_row_tot=unique(find(idx_row&idx_row_other));
idx_col_tot=unique(find(idx_col&idx_col_other));

K=bsxfun(@plus,idx_row_tot,(idx_col_tot'-1)*nb_samples);

K=K(:);

end