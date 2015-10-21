function pos=create_pos_algo()
nb_elt_cell=3;
nb_col=2;
nb_row=4;

elt_width=repmat([0.3 0.3 0.1],nb_row,nb_col);

elt_height=repmat([0.1 0.05 0.15],nb_row,nb_col);

col_start=repmat([0.025 0.025 0.35 0.5 0.5 0.825],nb_row,1);

row_start=repmat([0.85 0.8 0.8; 0.65 0.6 0.6; 0.45 0.4 0.4; 0.25 0.2 0.2],1,nb_col);



pos=cell(nb_row,nb_col);
for i=1:nb_col*nb_elt_cell
    for j=1:nb_row
        pos{j,i}=[col_start(j,i) row_start(j,i) elt_width(j,i) elt_height(j,i)];
    end
end
end