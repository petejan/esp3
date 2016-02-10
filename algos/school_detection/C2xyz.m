function [x,y,z] = C2xyz(C)

m(1)=1;
n=1;
try
    while n<length(C)
        n=n+1;
        m(n) = m(n-1)+C(2,m(n-1))+1;
    end
end

for nn = 1:n-2
    x{nn} = C(1,m(nn)+1:m(nn+1)-1);
    y{nn} = C(2,m(nn)+1:m(nn+1)-1);
    if nargout==3
        z(nn) = C(1,m(nn));
    end
end

end