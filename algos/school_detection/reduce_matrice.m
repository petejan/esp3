function K_red=reduce_matrice(dist_pings_mat,range_mat,curr_candidates,other_candidates,horz_link_max,vert_link_max)

K=reshape(find(ones(size(dist_pings_mat))),size(dist_pings_mat,1),size(dist_pings_mat,2));

idx_red_row=(dist_pings_mat(1,:)>=(nanmin(dist_pings_mat(curr_candidates))-horz_link_max))&(dist_pings_mat(1,:)<=(nanmax(dist_pings_mat(curr_candidates))+horz_link_max));
idx_red_cols=(range_mat(:,1)>=(nanmin(range_mat(curr_candidates))-vert_link_max)&(range_mat(:,1))<=(nanmax(range_mat(curr_candidates))+vert_link_max));

other_candidates_red=other_candidates(idx_red_cols,idx_red_row);
curr_candidates_red=curr_candidates(idx_red_cols,idx_red_row);
dist_pings_mat_red=dist_pings_mat(idx_red_cols,idx_red_row);
range_mat_red=range_mat(idx_red_cols,idx_red_row);
K_red_1=K(idx_red_cols,idx_red_row);

if nansum(other_candidates_red(:))==0||nansum(curr_candidates_red(:))==0
    K_red=[];
    return;
end

idx_red_row=(dist_pings_mat_red(1,:)>=(nanmin(dist_pings_mat_red(other_candidates_red))-horz_link_max))&(dist_pings_mat_red(1,:)<=(nanmax(dist_pings_mat_red(other_candidates_red))+horz_link_max));
idx_red_cols=(range_mat_red(:,1)>=(nanmin(range_mat_red(other_candidates_red))-vert_link_max)&(range_mat_red(:,1))<=(nanmax(range_mat_red(other_candidates_red))+vert_link_max));

K_red=K_red_1(idx_red_cols,idx_red_row);
K_red=K_red(:);

end