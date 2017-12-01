
function [temp,depth,pressure,date]=read_rbr(file)

fid=fopen(file);
line='';
while ~contains(line,'Depth')
    line=fgetl(fid);
end

i=0;
line=fgetl(fid);
date=[];
temp=[];
pressure=[];
depth=[];
while line~=-1

    data = textscan(line, '%4d/%2d/%2d %2d:%2d:%2d %f %f %f ');
    if length(data)==9
        i=i+1;
        date(i)=datenum(double(data{1}),double(data{2}),double(data{3}),double(data{4}),double(data{5}),double(data{6}));
        temp(i)=data{7};
        pressure(i)=data{8};
        depth(i)=data{9};
    end
   line=fgetl(fid);
end

fclose(fid);