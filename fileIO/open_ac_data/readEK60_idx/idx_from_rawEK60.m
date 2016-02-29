function raw_idx_obj=idx_from_rawEK60(filename)
fid=fopen(filename);
raw_idx_obj=raw_idx_cl();
if fid==-1
    return;
end

HEADER_LEN=12;
MAX_DG_SIZE=1e6;

[~,fileN,ext]=fileparts(filename);

raw_idx_obj.filename=[fileN ext];
raw_idx_obj.raw_type='EK60';
raw_idx_obj.nb_samples=nan(1,MAX_DG_SIZE);
raw_idx_obj.time_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.type_dg=cell(1,MAX_DG_SIZE);
raw_idx_obj.pos_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.len_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.chan_dg=nan(1,MAX_DG_SIZE);

i_dg=1;

while true
    len=fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end
    raw_idx_obj.len_dg(i_dg)=len;
    raw_idx_obj.pos_dg(i_dg)=ftell(fid);
    [dgType,dgTime]=readEK60Header(fid);
    if (feof(fid))||isempty(dgType)
        break;
    end

    raw_idx_obj.type_dg{i_dg}=dgType;
    raw_idx_obj.time_dg(i_dg)=dgTime;
    
    switch dgType
        case 'RAW0'
            raw_idx_obj.chan_dg(i_dg)=int16(fread(fid,1,'int16','l')); 
            fseek(fid,66,0);
            raw_idx_obj.nb_samples(i_dg) = fread(fid,1,'int32', 'l');
            fread(fid,len-HEADER_LEN-2-66-4,'uchar', 'l');
        otherwise
            fread(fid,len-HEADER_LEN,'uchar', 'l');
    end
    len=fread(fid, 1, 'int32', 'l');
    i_dg=i_dg+1;
end

idx_nan=isnan(raw_idx_obj.time_dg);
raw_idx_obj.nb_samples(idx_nan)=[];
raw_idx_obj.time_dg(idx_nan)=[];
raw_idx_obj.type_dg(idx_nan)=[];
raw_idx_obj.pos_dg(idx_nan)=[];
raw_idx_obj.len_dg(idx_nan)=[];
raw_idx_obj.chan_dg(idx_nan)=[];


fclose(fid);

end
