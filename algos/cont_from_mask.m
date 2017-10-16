function [x,y]=cont_from_mask(Mask)
Mask_exp=zeros(size(Mask)+2);
Mask_exp(2:end-1,2:end-1)=Mask;

cont=contourc(Mask_exp,[1 1]);
if isempty(cont)
    x=[];
    y=[];
    return;
end

[x,y,~]=C2xyz(cont);

idx_rem=[];
for i=1:length(x)
   x{i}=x{i}-1; 
   y{i}=y{i}-1;
   if length(x{i})<3
       idx_rem=union(idx_rem,i);
   end
end

y(idx_rem)=[];
x(idx_rem)=[];



