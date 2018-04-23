function pkey=insert_data_controlled(ac_db_filename,tablename,struct_in,struct_in_minus_key,pkey_name)

if isfield(struct_in_minus_key,pkey_name)
    struct_in_minus_key=rmfield(struct_in_minus_key,pkey_name);
end

fields=fieldnames(struct_in);
try    
    datainsert_perso(ac_db_filename,tablename,struct_in);    
catch
    p_key=nan(numel(struct_in.(fields{1})),1);
    
    for irow=1:numel(struct_in.(fields{1}))
        [~,tmp]=get_cols_from_table(ac_db_filename,tablename,'input_struct',struct_in_minus_key,'output_cols',{pkey_name},'row_idx',irow);
        if~isempty(tmp)
            p_key(irow)=tmp{1,1};
        end
    end
    
    idx_insert=find(isnan(p_key));
    if ~isempty(idx_insert)
        datainsert_perso(ac_db_filename,tablename,struct_in,'idx_insert',idx_insert);
    end
    
end

pkey=[];
bs=500;

for irow=1:bs:numel(struct_in.(fields{1}))
    idx_ite=irow:min(irow+bs-1,numel(struct_in.(fields{1})));
    [~,tmp]=get_cols_from_table(ac_db_filename,tablename,'input_struct',struct_in_minus_key,'output_cols',{pkey_name},'row_idx',idx_ite);
    if~isempty(tmp)
        pkey=[pkey;tmp];
    end
end

if iscell(pkey)
    pkey=cell2mat(pkey);
end

if istable(pkey)
    pkey=table2struct(pkey,'ToScalar',true);
end

if isstruct(pkey)
    pkey=pkey.(pkey_name);
end


end