function K_neighbours=find_neighbours_v4(I,J,K,I_init,J_init)

idx_red=(I>=(nanmin(I_init)-1))&(I<=(nanmax(I_init)+1))&(J>=(nanmin(J_init)-1))&(J<=(nanmax(J_init)+1));


K_red=K(idx_red);
I_red=I(idx_red);
J_red=J(idx_red);

K_neighbours=[];

for i=1:length(I_init)
    D_square=(I_red-I_init(i)).^2+(J_red-J_init(i)).^2;
    idx_neighbours=(D_square<=2)&D_square>0;
    K_neighbours = [K_neighbours ; K_red(idx_neighbours)];
end

end

