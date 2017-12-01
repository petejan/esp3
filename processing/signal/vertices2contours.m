function [x,y]=vertices2contours(v)

if ~isnan(v(1))
    x = [nan; v(:,1)];
    y = [nan; v(:,2)];
end
idx=find(~isnan(x),1,'first');
x = x(idx-1:end);
y = y(idx-1:end);

a = zeros(size(x));
b = ~isnan(x(:));
a(strfind(~b(:)',[1 0])) = 1;
idx_final = cumsum(a);

x = accumarray(idx_final(b),x(b),[],@(x){x});
y = accumarray(idx_final(b),y(b),[],@(x){x});