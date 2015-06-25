function C=filter2_perso(B,A)

% [nb_rows,nb_cols]=size(A);
% [filter_h,filter_w]=size(B);
% unit_A=ones(size(A));
% C=nan(size(A));
% [I,J]=find(unit_A);
% 
% for i=1:nb_rows
%     for j=1:nb_cols
%         idx_val=find(abs(I-i)<filter_h/2&abs(J-j)<filter_w/2);
%         idx_B_i=I(idx_val)-i+ceil(filter_h/2);
%         idx_B_j=J(idx_val)-j+ceil(filter_w/2);
%         idx_B=idx_B_i+(idx_B_j-1)*filter_h;
%         if nansum(~isnan(A(idx_val)))>0
%             C(i,j)=nansum(A(idx_val).*B(idx_B))/nansum(B(idx_B));
%         end
%     end
% end

idx_nan=isnan(A);
A(idx_nan)=0;

nan_filt=filter2(B,double(~idx_nan));

C=filter2(B,A)./nan_filt;


end