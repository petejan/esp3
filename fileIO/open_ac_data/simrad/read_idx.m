function raw_idx_obj=read_idx(filename,varargin)
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
        
    case 'EK60'
        [tmp, ~] = readEKRaw_ReadHeader(fid);
        freq=nan(1,length(tmp.transceiver));
        CIDs=cell(1,length(tmp.transceiver));
        for uif=1:length(freq)
            freq(uif)=tmp.transceiver(uif).frequency;
            CIDs{uif}=tmp.transceiver(uif).channelid;
        end
        frewind(fid);
end

BLCK_SIZE=1e8;
overlap=3;
idx_dg=[];
n=0;
while~feof(fid)
    if n>0
        fseek(fid,-overlap,'cof');
        offset=n*(BLCK_SIZE-overlap);
    else
        offset=0;
    end
    file_block=fread(fid,BLCK_SIZE,'*char', 'l')';
    switch raw_idx_obj.raw_type
        case 'EK80'
            idx_dg_temp=regexp(file_block,'(XML0|NME0|RAW3|TAG0|MRU0|FIL1|IDX0)');    
        case 'EK60'
            idx_dg_temp=regexp(file_block,'(CON0|NME0|RAW0|TAG0|IDX0)');

    end
    idx_dg=[idx_dg idx_dg_temp+offset];
    n=n+1;
end

idx_dg=sort(idx_dg);
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

if length(varargin)>=1
    load_bar_comp=varargin{1};
    
else
    load_bar_comp=[];
end

if ~isempty(load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_dg), 'Value',0);
    load_bar_comp.status_bar.setText(sprintf('Indexing File %s',filename));
end
nb_dg=length(idx_dg);

for i=1:length(idx_dg)
    if mod(i,floor(nb_dg/100))==1
    if ~isempty(load_bar_comp)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_dg, 'Value',i);
    end
    end
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

type_dg_unique=unique(raw_idx_obj.type_dg);

for i=1:length(type_dg_unique)
   idx_dg_type=find(strcmp(raw_idx_obj.type_dg,type_dg_unique{i}));
   idx_rem_type=find(diff(raw_idx_obj.time_dg(idx_dg_type))<0)+1;
   idx_rem(idx_dg_type(idx_rem_type))=1;
end

raw_idx_obj.nb_samples(idx_rem)=[];
raw_idx_obj.time_dg(idx_rem)=[];
raw_idx_obj.type_dg(idx_rem)=[];
raw_idx_obj.pos_dg(idx_rem)=[];
raw_idx_obj.len_dg(idx_rem)=[];
raw_idx_obj.chan_dg(idx_rem)=[];

fclose(fid);

end
