function Int_data=integrate_data(x,y,Sv,X,Y,line)

Mask=~isnan(Sv);

if ~isempty(line)
    line_mat=repmat(line,size(Sv,1),1);
else
    line_mat=y(end)*ones(size(Sv));
end

N_x=length(X)-1;
N_y=length(Y)-1;
x_c=(X(2:end)+X(1:end-1))/2;
y_c=(Y(2:end)+Y(1:end-1))/2;

[x_mat,y_mat]=meshgrid(x,y);


x_res=(X(2:end)-X(1:end-1))/2;
y_res=(Y(2:end)-Y(1:end-1))/2;

Int_data.Sv_mean=nan(N_y,N_x);
Int_data.Sv_max=nan(N_y,N_x);
Int_data.Sv_min=nan(N_y,N_x);
Int_data.nb_samples=nan(N_y,N_x);
Int_data.height=2*repmat(x_res,N_y,1);
Int_data.length=2*repmat(y_res',1,N_x);
Int_data.x_node=repmat(x_c,N_y,1);
Int_data.y_node=repmat(y_c',1,N_x);


for i=1:N_x

    idx_red=(((x_mat-x_c(i)))<x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask&(y_mat<line_mat);
    Sv_red=Sv(idx_red);
    y_mat_red=y_mat(idx_red);
    for j=1:N_y
        
        idx_bin=(((y_mat_red-y_c(j)))<y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));
        Int_data.Sv_mean(j,i)=10*log10(nanmean(10.^(Sv_red(idx_bin)/10)));
        %Int_data.Sa=10*log10(nansum(10.^(Sv(idx_bin)/10)));
        if~isempty(Sv(idx_bin))
            Int_data.Sv_min(j,i)=nanmin(Sv_red(idx_bin));
            Int_data.Sv_max(j,i)=nanmax(Sv_red(idx_bin));
            Int_data.nb_samples(j,i)=nansum(idx_bin(:));
        end
        
    end
end


end