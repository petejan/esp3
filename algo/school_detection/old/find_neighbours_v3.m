function K_neighbours=find_neighbours_v3(I,J,K,I_init,J_init,nb_r,nb_c)

idx_red=(I>=(nanmin(I_init)-1))&(I<=(nanmax(I_init)+1))&(J>=(nanmin(J_init)-1))&(J<=(nanmax(J_init)+1));



K_red=K(idx_red);


l_init=length(I_init);
l_tot=length(K_red);


K_mat=repmat(K_red,1,l_init);


I_init_mat=repmat(I_init',l_tot,1);
J_init_mat=repmat(J_init',l_tot,1);

if size(I_init_mat,1)~=size(K_mat,1)
    I_init_mat=I_init_mat';
    J_init_mat=J_init_mat';
end   

D_square=(rem(K_mat,nb_r)-I_init_mat).^2+(fix(K_mat/nb_r)+1-J_init_mat).^2;

idx_neighbours=(D_square<=2)&D_square>0;

K_neighbours= unique(K_mat(idx_neighbours));

end

