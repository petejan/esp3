function raw_idx_obj=idx_from_rawEK60_v2(filename)
fid=fopen(filename);
raw_idx_obj=raw_idx_cl();
if fid==-1
    return;
end

file_comp=fread(fid,'*char', 'l')';

idx_con0=strfind(file_comp,'CON0');
idx_raw0=strfind(file_comp,'RAW0');
idx_nme0=strfind(file_comp,'NME0');

[idx_dg,~]=sort([idx_con0 idx_raw0 idx_nme0]);

HEADER_LEN=12;
MAX_DG_SIZE=length(idx_dg);

[~,fileN,ext]=fileparts(filename);

raw_idx_obj.filename=[fileN ext];
raw_idx_obj.raw_type='EK60';
raw_idx_obj.nb_samples=nan(1,MAX_DG_SIZE);
raw_idx_obj.time_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.type_dg=cell(1,MAX_DG_SIZE);
raw_idx_obj.pos_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.len_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.chan_dg=nan(1,MAX_DG_SIZE);
dgTime_ori = datenum(1601, 1, 1, 0, 0, 0);

for i=1:length(idx_dg)
    
    fseek(fid,idx_dg(i)-5,-1);
    len=fread(fid, 1, 'int32', 'l');
    if (feof(fid))
        break;
    end
    
    raw_idx_obj.pos_dg(i)=ftell(fid);
    raw_idx_obj.len_dg(i)=len;
    [dgType,nt_sec]=readEK60Header_v2(fid);
    if (feof(fid))||isempty(dgType)
        break;
    end

    raw_idx_obj.type_dg{i}=dgType;
    raw_idx_obj.time_dg(i)=dgTime_ori+nt_sec/(24*60*60);
    
    switch dgType
        case 'RAW0'
            raw_idx_obj.chan_dg(i)=int16(fread(fid,1,'int16','l')); 
            fseek(fid,66,0);
            raw_idx_obj.nb_samples(i) = fread(fid,1,'int32', 'l');
            fread(fid,len-HEADER_LEN-2-66-4,'uchar', 'l');
        otherwise
            fread(fid,len-HEADER_LEN,'uchar', 'l');
    end
    
end


fclose(fid);

end
