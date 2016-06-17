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
    if length(x{i})>=250
        x{i}=x{i}-1; 
        y{i}=y{i}-1;
    else
        idx_rem=[idx_rem i];
    end
end

x(idx_rem)=[];
y(idx_rem)=[];
