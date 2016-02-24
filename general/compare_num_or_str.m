function out=compare_num_or_str(a,b)

if isnumeric(a)&&isnumeric(b)
    out=a==b;
elseif isnumeric(a)&&ischar(b)
    out=strcmp(num2str(a,'%.0f'),b);
elseif isnumeric(b)&&ischar(a)
    out=strcmp(num2str(b,'%.0f'),a);
elseif ischar(a)&&ischar(b)
    out=strcmp(a,b);
end
end