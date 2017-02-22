function remove_sub_data(data,fields)

if nargin<2
    fields=data.Fieldname;
end

if ~iscell(fields)
    fields={fields};
end

for ii=1:length(fields)
    fieldname=fields{ii};
    [idx,found]=find_field_idx(data,fieldname);
    
    if found==0
        return;
    else
        fname=cell(1,length(data.SubData(idx).Memap));
        for icell=1:length(data.SubData(idx).Memap)
            fname{icell}=data.SubData(idx).Memap{icell}.Filename;
        end
 %data.SubData(idx).delete();
        data.SubData(idx)=[];
        data.Type(idx)=[];
        data.Fieldname(idx)=[];
        
        for i=1:length(fname)
            delete(fname{i});
        end
    end
end
end
