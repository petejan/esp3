
function [temp,depth,pressure,date]=read_rbr(file)

fid=fopen(file);
line='';
while isempty(strfind(line,'Depth'))
    line=fgetl(fid);
end

i=0;
line=fgetl(fid);
while line~=-1
    
    data = sscanf(line, '%i/%i/%i %i:%i:%i %f %f %f ');
    if length(data)==9
        i=i+1;
        date(i)=datenum(data(1),data(2),data(3),data(4),data(5),data(6));
        temp(i)=data(7);
        pressure(i)=data(8);
        depth(i)=data(9);
    end
   line=fgetl(fid);
end

fclose(fid);