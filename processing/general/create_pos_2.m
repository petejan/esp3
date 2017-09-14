
function pos=create_pos_2(m,n,x_ini,y_ini,x_sep,y_sep)

x_w=(1-x_ini)/(n+2);
y_h=(y_ini)/m;

for i=1:n
    for j=1:m
        if i==1
            pos{j,i}=[(x_ini+(i-1)*x_w) (y_ini-j*y_h)+y_sep  3*x_w-x_sep y_h-y_sep];
        else
            pos{j,i}=[(x_ini+(i+1)*x_w) (y_ini-j*y_h)+y_sep  x_w-x_sep y_h-y_sep];
        end
    end
end

end