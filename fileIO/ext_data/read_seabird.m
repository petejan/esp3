function [temp,depth,pressure,date,velocity]=read_seabird(file)

fid=fopen(file);
line='';
while ~contains(line,'# nquan')
    line=fgetl(fid);
end

nquan= sscanf(line, '# nquan = %i');
fgetl(fid);
%nvalues= sscanf(line, '# nvalues = %i');
line=fgetl(fid);
%units= sscanf(line, '# units = %i');

struct_fields=cell(1,nquan);
while ~contains(line,'# name')
    line=fgetl(fid);
end
u=0;

output=struct();
for i=1:nquan
    if contains(lower(line),'depth')
        struct_fields{i}='depth';
    elseif contains(lower(line),'temperature')
        struct_fields{i}='temp';
    elseif contains(lower(line),'pressure')
        struct_fields{i}='pressure';
    elseif contains(lower(line),'conductivity')
        struct_fields{i}='cond';
    elseif contains(lower(line),'time')
        struct_fields{i}='time';
    elseif contains(lower(line),'velocity')
        struct_fields{i}='velocity';
    else
        struct_fields{i}=['undefined' num2str(u,'%.0f')];
        u=u+1;
    end
    output.(struct_fields{i})=[];
    line=fgetl(fid);
end

while ~contains(line,'# interval')
    line=fgetl(fid);
end

%interval=sscanf(line, '# interval = seconds: %i');

while ~contains(line,'# start_time')
    line=fgetl(fid);
end

start_time=datenum(line(length('# start_time = '):end), 'mmm dd yyyy HH:MM:SS');

while ~contains(line,'*END*')
    line=fgetl(fid);
end
line=fgetl(fid);


uu=1;
while line~=-1
    data= sscanf(line, repmat('%f ',1,nquan));
    for i=1:nquan
        output.(struct_fields{i})(uu)=data(i);
    end
    uu=uu+1;
    line=fgetl(fid);
end


if isfield(output,'time')
    date= start_time+[0 cumsum(diff(output.time))];
else
    date=[];
end

if isfield(output,'temp')
    temp=output.temp;
else
    temp=[];
end

if isfield(output,'depth')
    depth=output.depth;
else
    depth=[];
end

if isfield(output,'pressure')
    pressure=output.pressure;
else
    pressure=[];
end

if isfield(output,'velocity')
    velocity=output.velocity;
else
    velocity=[];
end


fclose(fid);