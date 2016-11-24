function struct_out=csv2struct_perso(file)

fid=fopen(file,'r');

if fid==-1
    struct_out=[];
    return;
end

header_str=fgetl(fid);
fields_cell=textscan(header_str,'%s','Delimiter',',');
fields=deblank(fields_cell{1});
idx_rem=find(strcmpi(fields,''));
for u=1:length(idx_rem)
    fields{idx_rem(u)}=sprintf('field_%d',u);
end
nb_fields=length(fields);
txt_str=fread(fid,'*char')';
fclose(fid);

if isempty(txt_str)
    struct_out=[];
    return;
end


data_cell=textscan(txt_str,'%s','Delimiter',',');
data=data_cell{1};


for i=1:length(data)
    i_field=rem(i,nb_fields);
    if i_field==0
        i_field=nb_fields;
    end
    i_line=ceil(i/nb_fields);
    struct_out.(fields{i_field}){i_line}=data{i};
end


for ifi=1:nb_fields
    temp=cellfun(@str2double,struct_out.(fields{ifi}));
    idx_valid=~isnan(temp);
    if any(idx_valid)
        struct_out.(fields{ifi})=temp;
    end
    
end


end