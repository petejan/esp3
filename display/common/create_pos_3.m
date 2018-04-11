
function pos=create_pos_3(m,n,x_sep,y_sep,txt_w,box_w,h)

pos=cell(m,n);
for i=1:n
    for j=1:m
        pos{j,i}{1}=[x_sep+(i-1)*(x_sep+txt_w+x_sep+box_w+x_sep) y_sep+(j-1)*(y_sep+h)  txt_w h];
        pos{j,i}{2}=[(x_sep+txt_w+x_sep)+(i-1)*(x_sep+txt_w+x_sep+box_w+x_sep) y_sep+(j-1)*(y_sep+h)  box_w h];
    end
end

pos=flipud(pos);

end