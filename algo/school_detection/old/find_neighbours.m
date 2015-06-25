function [I_neighbours,J_neighbours,K_neighbours]=find_neighbours(I,J,K,I_init,J_init)

idx_red=(I>=(nanmin(I_init)-1))&(I<=(nanmax(I_init)+1))&(J>=(nanmin(J_init)-1))&(J<=(nanmax(J_init)+1));

I_red=I(idx_red);
J_red=J(idx_red);
K_red=K(idx_red);

l_init=length(I_init);
l_tot=length(I_red);

I_mat=repmat(I_red,1,l_init);
J_mat=repmat(J_red,1,l_init);
K_mat=repmat(K_red,1,l_init);

I_init_mat=repmat(I_init',l_tot,1);
J_init_mat=repmat(J_init',l_tot,1);

if size(I_init_mat,1)~=size(I_mat,1)
    I_init_mat=I_init_mat';
    J_init_mat=J_init_mat';
end   
% [I_mat,I_init_mat]=meshgrid(I_red,I_init);
% [J_mat,J_init_mat]=meshgrid(J_red,J_init);

% I_mat=I_red*ones(1,l_init);
% J_mat=J_red*ones(1,l_init);
% K_mat=K_red*ones(1,l_init);
% 
% I_init_mat=ones(l_tot,1)*I_init';
% J_init_mat=ones(l_tot,1)*J_init';


D_square=(I_mat-I_init_mat).^2+(J_mat-J_init_mat).^2;

idx_neighbours=(D_square<=2)&D_square>0;

[K_neighbours,KI,~] = unique(K_mat(idx_neighbours));
I_temp=I_mat(idx_neighbours);
J_temp=J_mat(idx_neighbours);

I_neighbours=I_temp(KI);
J_neighbours=J_temp(KI);

end

