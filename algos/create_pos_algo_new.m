function pos=create_pos_algo_new(nb_row,nb_col)

x=10/(11*nb_col+1);
x_grp=x;
dx=x/10;

y=4/(5*nb_row+1);
y_grp=y;
dy=y/4;

elt_width=repmat([0.6*x_grp 0.6*x_grp 0.3*x_grp],nb_row,nb_col);

elt_height=repmat([y_grp*2/3 y_grp/3 y_grp],nb_row,nb_col);

col_start=repmat([0 0 0.65*x_grp],nb_row,nb_col);

for i=1:nb_col
    col_start(:,1+(i-1)*3:i*3)=dx+col_start(:,1+(i-1)*3:i*3)+(x_grp+dx)*(i-1);
end

row_start=repmat([1+y_grp/3 1 1],nb_row,nb_col);

for i=1:nb_row
    row_start(i,:)=-dy-y_grp+row_start(i,:)-(y_grp+dy)*(i-1);
end

pos=cell(nb_row,nb_col);
for i=1:nb_col*3
    for j=1:nb_row
        pos{j,i}=[col_start(j,i) row_start(j,i) elt_width(j,i) elt_height(j,i)];
    end
end
end