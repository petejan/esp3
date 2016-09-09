function raw_idx_obj=idx_from_raw(filename)
raw_idx_obj=raw_idx_cl();
raw_idx_obj.raw_type= get_ftype(filename);
fid=fopen(filename);

if fid==-1
    return;
end

switch raw_idx_obj.raw_type
    case 'EK80'
        [~,config]=read_EK80_config(filename);
        
        freq=nan(1,length(config));
        CIDs=cell(1,length(config));
        for uif=1:length(freq)
            freq(uif)=config(uif).Frequency;
            CIDs{uif}=config(uif).ChannelID;
        end
        file_comp=fread(fid,'*char', 'l')';
        idx_nme0=strfind(file_comp,'NME0');
        idx_xml0=strfind(file_comp,'XML0');
        idx_raw3=strfind(file_comp,'RAW3');
        idx_tag0=strfind(file_comp,'TAG0');
        idx_mru0=strfind(file_comp,'MRU0');
        idx_fil1=strfind(file_comp,'FIL1');
        [idx_dg,~]=sort([idx_nme0 idx_xml0 idx_raw3 idx_tag0 idx_mru0 idx_fil1]);
    case 'EK60'
        [tmp, ~] = readEKRaw_ReadHeader(fid);
         freq=nan(1,length(tmp.transceiver));
        CIDs=cell(1,length(tmp.transceiver));
        for uif=1:length(freq)
            freq(uif)=tmp.transceiver(uif).frequency;
            CIDs{uif}=tmp.transceiver(uif).channelid;
        end
        frewind(fid);
        file_comp=fread(fid,'*char', 'l')';
        idx_con0=strfind(file_comp,'CON0');
        idx_raw0=strfind(file_comp,'RAW0');
        idx_nme0=strfind(file_comp,'NME0');
        idx_tag0=strfind(file_comp,'TAG0');
        [idx_dg,~]=sort([idx_con0 idx_raw0 idx_nme0  idx_tag0]);
end


HEADER_LEN=12;
MAX_DG_SIZE=length(idx_dg);

[~,fileN,ext]=fileparts(filename);

raw_idx_obj.filename=[fileN ext];

raw_idx_obj.nb_samples=nan(1,MAX_DG_SIZE);
raw_idx_obj.time_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.type_dg=cell(1,MAX_DG_SIZE);
raw_idx_obj.pos_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.len_dg=nan(1,MAX_DG_SIZE);
raw_idx_obj.chan_dg=nan(1,MAX_DG_SIZE);
dgTime_ori = datenum(1601, 1, 1, 0, 0, 0);

frewind(fid);

for i=1:length(idx_dg)
    curr_pos=ftell(fid);
    fread(fid,idx_dg(i)-5-curr_pos);
    %fseek(fid,idx_dg(i)-5,-1);
    len=fread(fid, 1, 'int32', 'l');
    
    if (feof(fid))
        break;
    end
    
    if len<HEADER_LEN
        len=HEADER_LEN+1;
    end
    
    raw_idx_obj.pos_dg(i)=idx_dg(i)-1;
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
            fread(fid,66);
            raw_idx_obj.nb_samples(i) = fread(fid,1,'int32', 'l');
            
        case 'RAW3'
           channelID = (fread(fid,128,'*char', 'l')');
           fread(fid,4,'int16', 'l');
           id_chan=find(strcmp(deblank(channelID),deblank(CIDs)));
           if ~isempty(id_chan)
               raw_idx_obj.chan_dg(i)=id_chan;
               raw_idx_obj.nb_samples(i) = fread(fid,1,'int32', 'l');
           end
    end
    
end

idx_rem=diff(raw_idx_obj.pos_dg)-raw_idx_obj.len_dg(1:end-1)~=(HEADER_LEN-4);

raw_idx_obj.nb_samples(idx_rem)=[];
raw_idx_obj.time_dg(idx_rem)=[];
raw_idx_obj.type_dg(idx_rem)=[];
raw_idx_obj.pos_dg(idx_rem)=[];
raw_idx_obj.len_dg(idx_rem)=[];
raw_idx_obj.chan_dg(idx_rem)=[];

fclose(fid);

end
