function [trans_obj,envdata,NMEA,mru0_att]=data_from_raw_idx_cl_v5(path_f,idx_raw_obj,varargin)
HEADER_LEN=12;
p = inputParser;
addRequired(p,'path_f',@(x) ischar(x));
addRequired(p,'idx_raw_obj',@(x) isa(x,'raw_idx_cl'));
addParameter(p,'Frequencies',[],@isnumeric);
addParameter(p,'GPSOnly',0,@isnumeric);
addParameter(p,'DataOnly',0,@isnumeric);
addParameter(p,'PathToMemmap',path_f,@ischar);
addParameter(p,'FieldNames',{});
addParameter(p,'load_bar_comp',[]);
addParameter(p,'block_len',1000,@(x) x>0);


parse(p,path_f,idx_raw_obj,varargin{:});
results=p.Results;
Frequencies=results.Frequencies;

filename=fullfile(path_f,idx_raw_obj.filename);

ftype=get_ftype(filename);

load_bar_comp=results.load_bar_comp;
block_len=results.block_len;

array_type='double';



switch ftype
    case 'EK80'
        [~,config]=read_EK80_config(filename);
        nb_trans_tot=length(config);
        
        freq=nan(1,nb_trans_tot);
        CIDs=cell(1,nb_trans_tot);
        
        for uif=1:length(freq)
            freq(uif)=config(uif).Frequency;
            CIDs{uif}=config(uif).ChannelID;
        end
        
    case 'EK60'
        fid=fopen(fullfile(path_f,idx_raw_obj.filename),'r');
        
        [header, freq] = readEKRaw_ReadHeader(fid);
        nb_trans_tot=length(freq);
        config_EK60=header.transceiver;
        
        CIDs=cell(1,nb_trans_tot);
        
        for uif=1:length(freq)
            config_EK60(uif).soundername=header.header.soundername;
            CIDs{uif}=config_EK60(uif).channelid;
        end
        
        for i=1:nb_trans_tot
            [config(i),~]=config_from_ek60([],config_EK60(i));
        end
end




if isempty(Frequencies)
    idx_freq=(1:length(freq))';
else
    [~,~,idx_freq] = intersect(Frequencies,freq,'stable');
end
channels=unique(idx_raw_obj.chan_dg(~isnan(idx_raw_obj.chan_dg)));
if isempty(idx_freq)
    idx_freq=(1:length(channels))';
end

if length(idx_freq)>length(channels)
    idx_freq=(1:length(channels));
end

channels=channels(idx_freq);
CIDs_freq=CIDs(idx_freq);
trans_obj(length(CIDs_freq))=transceiver_cl();
nb_trans=length(idx_freq);


nb_pings=idx_raw_obj.get_nb_pings_per_channels();
nb_pings=nb_pings(idx_freq);
nb_pings(nb_pings<0)=0;

nb_samples=idx_raw_obj.get_nb_samples_per_channels();
nb_samples=nb_samples(idx_freq);
nb_samples(nb_samples<0)=0;

if p.Results.GPSOnly>0
    nb_pings=nanmin(ones(1,length(CIDs_freq)),nb_pings);
    nb_samples=nanmin(ones(1,length(CIDs_freq)),nb_samples);
end

nb_nmea=idx_raw_obj.get_nb_nmea_dg();

time_nmea=idx_raw_obj.get_time_dg('NME0');
NMEA.time= time_nmea;
NMEA.string= cell(1,nb_nmea);
NMEA.type= cell(1,nb_nmea);

params_cl_init(nb_trans)=params_cl();

[fields,~,fmt_fields,factor_fields]=init_fields();

curr_data_name=cell(nb_trans,numel(fields));
curr_data_name_t=cell(nb_trans,1);
fileID=-ones(nb_trans,numel(fields));


for i=1:nb_trans
    data.pings(i).number=nan(1,nb_pings(i),array_type);
    data.pings(i).time=nan(1,nb_pings(i),array_type);
    %data.pings(i).samples=(1:nb_samples(i))';
    trans_obj(i).Params=params_cl(nb_pings(i));
    
    if p.Results.GPSOnly==0
        [~,curr_filename,~]=fileparts(tempname);
        curr_data_name_t{i}=fullfile(p.Results.PathToMemmap,curr_filename);
        
        for ifif=1:numel(fields)
            curr_data_name{i,ifif}=[curr_data_name_t{i} fields{ifif} '.bin'];
            fileID(i,ifif) = fopen(curr_data_name{i,ifif},'w');
        end
        
    end
end


block_i=ones(1,nb_trans);
data_tmp=cell(1,nb_trans);
idx_fields=zeros(nb_trans,numel(fields));
i_ping = ones(nb_trans,1);
i_nmea=0;
id_mru0=0;
fil_process=0;
conf_dg=0;
env_dg=0;

prop_params=properties(params_cl);
prop_config=properties(config_cl);
prop_env=properties(env_data_cl);

param_str_init=cell(1,nb_trans);
param_str_init(:)={''};

idx_mru0=strcmp(idx_raw_obj.type_dg,'MRU0');

mru0_att=attitude_nav_cl('Time',idx_raw_obj.time_dg(idx_mru0)');

mode=cell(1,length(trans_obj));
fid=fopen(filename,'r');

if ~isempty(load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_raw_obj.type_dg), 'Value',0);
    load_bar_comp.status_bar.setText(sprintf('Opening File %s',filename));
end

dg_type_keep={'XML0','CON0','NME0','RAW0','RAW3','FIL1','MRU0'};

if p.Results.GPSOnly>0
    dg_type_keep={'XML0','CON0','NME0','RAW0'};
end

if p.Results.DataOnly>0
    dg_type_keep={'XML0','CON0','RAW0','RAW3','FIL1'};
end

idx_keep=ismember(idx_raw_obj.type_dg,dg_type_keep)&(isnan(idx_raw_obj.chan_dg)|ismember(idx_raw_obj.chan_dg,channels));

props=properties(idx_raw_obj);
for iprop=1:numel(props)
    if numel(idx_raw_obj.(props{iprop}))==numel(idx_keep)
        idx_raw_obj.(props{iprop})(~idx_keep)=[];
    end
end


nb_dg=length(idx_raw_obj.type_dg);
envdata=env_data_cl.empty();
% idg_time=idx_raw_obj.time_dg();
% [~,idg_sort]=sort(idg_time);

for idg=1:nb_dg
    pos=ftell(fid);
    
    
    if (idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN)<0
        disp('');
        continue;
    end
    dgTime=idx_raw_obj.time_dg(idg);
    if mod(idg,floor(nb_dg/100))==5
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_dg, 'Value',idg);
        end
    end
    
    switch  idx_raw_obj.type_dg{idg}
        case 'XML0'
            
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            t_line=(fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'*char','l'))';
            t_line=deblank(t_line);
            if contains(t_line,'<Configuration>')&&conf_dg==1
                if conf_dg==1
                    fread(fid, 1, 'int32', 'l');
                    continue;
                end
                
            elseif contains(t_line,'<Environment>')&&env_dg==1
                fread(fid, 1, 'int32', 'l');
                continue;
            elseif contains(t_line,'<Parameter>')
                idx = find(strcmp(t_line,param_str_init));
                if ~isempty(idx)
                    dgTime=idx_raw_obj.time_dg(idg);
                    fread(fid, 1, 'int32', 'l');
                    params_cl_init(idx).Time=dgTime;
                    trans_obj(idx).Params.Time(i_ping(idx))=dgTime;
                    
                    continue;
                end
            elseif strcmpi(t_line,'')
                continue;
            end
            
            
            [~,output,type]=read_xml0(t_line);%50% faster than the old version!
            
            switch type
                
                case'Configuration'
                    
                    config_temp=output;
                    for iout=1:length(config_temp)
                        idx = find(strcmp(deblank(CIDs_freq),deblank(config_temp(iout).ChannelID)));
                        if ~isempty(idx)
                            props=fieldnames(config_temp(iout));
                            for iii=1:length(props)
                                switch props{iii}
                                    case 'PulseDuration'
                                        trans_obj(idx).Config.PulseLength=config_temp(iout).(props{iii});
                                    otherwise
                                        if  any(strcmp(prop_config,props{iii}))
                                            trans_obj(idx).Config.(props{iii})=config_temp(iout).(props{iii});
                                        else
                                            if ~isdeployed()
                                                fprintf('New parameter in Configuration XML: %s\n', props{iii});
                                            end
                                        end
                                end
                                
                            end
                            
                            trans_obj(idx).Config.XML_string=t_line;
                        end
                    end
                case 'Environment'
                    if ~isempty(output)
                        props=fieldnames(output);
                        if isempty(envdata)
                            envdata=env_data_cl();
                        end
                        
                        for iii=1:length(props)
                            if  any(strcmpi(prop_env,props{iii}))
                                envdata.(props{iii})=output.(props{iii});
                            else
                                if ~isdeployed()
                                    fprintf('New parameter in Environment XML: %s\n', props{iii});
                                end
                            end
                        end
                        
                    end
                case 'Parameter'
                    params_temp=output;
                    idx = find(strcmp(deblank(CIDs_freq),deblank(params_temp.ChannelID)));
                    dgTime=idx_raw_obj.time_dg(idg);
                    fields_params=fieldnames(params_temp);
                    if ~isempty(idx)
                        param_str_init{idx}=t_line;
                        
                        params_cl_init(idx).Time=dgTime;
                        for jj=1:length(fields_params)
                            switch fields_params{jj}
                                case 'ChannelID'
                                    params_cl_init(idx).(fields_params{jj})=params_temp.(fields_params{jj});
                                case 'PulseDuration'
                                    params_cl_init(idx).PulseLength=params_temp.(fields_params{jj});
                                otherwise
                                    if any(strcmpi(prop_params,fields_params{jj}))
                                        params_cl_init(idx).(fields_params{jj})=params_temp.(fields_params{jj});
                                    else
                                        if ~isdeployed()
                                            fprintf('New parameter in Parameters XML: %s\n', fields_params{jj});
                                        end
                                    end
                            end
                        end
                        trans_obj(idx).Params.Time(i_ping(idx))=dgTime;
                        for jj=1:length(prop_params)
                            if ~isempty(params_cl_init(idx).(prop_params{jj}))
                                if ischar(params_cl_init(idx).(prop_params{jj}))
                                    trans_obj(idx).Params.(prop_params{jj}){i_ping(idx)}=(params_cl_init(idx).(prop_params{jj}));
                                else
                                    trans_obj(idx).Params.(prop_params{jj})(i_ping(idx))=(params_cl_init(idx).(prop_params{jj}));
                                end
                            else
                                if ~isdeployed()
                                    fprintf('Parameter not found in Parameters XML: %s\n', fields_params{jj});
                                end
                            end
                        end
                        
                        
                        
                    end
            end
            
        case 'NME0'
            
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            i_nmea=i_nmea+1;
            NMEA.string{i_nmea}=fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'*char', 'l')';
            if numel(NMEA.string{i_nmea})>=6
                NMEA.type{i_nmea}=NMEA.string{i_nmea}(4:6);
            else
                NMEA.type{i_nmea}='';
                %NMEA.string{i_nmea}
            end
        case 'FIL1'
            
            
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            stage=fread(fid,1,'int16','l');
            fread(fid,2,'char','l');
            filter_coeff_temp.channelID = (fread(fid,128,'*char', 'l')');
            filter_coeff_temp.NoOfCoefficients=fread(fid,1,'int16','l');
            filter_coeff_temp.DecimationFactor=fread(fid,1,'int16','l');
            filter_coeff_temp.Coefficients=fread(fid,2*filter_coeff_temp.NoOfCoefficients,'single','l');
            idx = find(strcmp(deblank(CIDs_freq),deblank(filter_coeff_temp.channelID)));
            
            if ~isempty(idx)
                props=fieldnames(filter_coeff_temp);
                for iii=1:length(props)
                    if isprop(filter_cl(), (props{iii}))
                        trans_obj(idx).Filters(stage).(props{iii})=filter_coeff_temp.(props{iii});
                    end
                end
            end
            
        case 'RAW3'
            
            %disp(dgType);
            % read channel ID
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            
            channelID = (fread(fid,128,'*char', 'l')');
            idx = find(strcmp(deblank(CIDs_freq),deblank(channelID)));
            
            if isempty(idx)||i_ping(idx)>nb_pings(idx)
                continue;
            end
            
            datatype=fread(fid,1,'int16', 'l');
            fread(fid,1,'int16', 'l');
            data.pings(idx).datatype=fliplr(dec2bin(datatype,11));
            
            
            temp=fread(fid,2,'int32', 'l');
            %  store sample number if required/valid
            number=i_ping(idx);
            
            data.pings(idx).channelID=channelID;
            
            data.pings(idx).offset(i_ping(idx))=temp(1);
            data.pings(idx).sampleCount(i_ping(idx))=temp(2);
            data.pings(idx).number(i_ping(idx))=number;
            data.pings(idx).time(i_ping(idx))=dgTime;
            sampleCount=temp(2);
            
            if data.pings(idx).datatype(1)==dec2bin(1)
                if (sampleCount > 0)
                    
                    if block_i(idx)==1
                        data_tmp{idx}.power=-999*ones(nb_samples(idx),nanmin(block_len,nb_pings(idx)-i_ping(idx)+1));
                        if data.pings(idx).datatype(2)==dec2bin(1)
                            data_tmp{idx}.AcrossPhi=zeros(nb_samples(idx),nanmin(block_len,nb_pings(idx)-i_ping(idx)+1));
                            data_tmp{idx}.AlongPhi=zeros(nb_samples(idx),nanmin(block_len,nb_pings(idx)-i_ping(idx)+1));
                        end
                    end
                    
                    data_tmp{idx}.power(1:sampleCount,block_i(idx))=(fread(fid,sampleCount,'int16', 'l') * 0.011758984205624);
                    
                    if data.pings(idx).datatype(2)==dec2bin(1)
                        if sampleCount*4==idx_raw_obj.len_dg(idg)-HEADER_LEN-12-128
                            angles=fread(fid,[2 sampleCount],'int8', 'l');
                            data_tmp{idx}.AlongPhi(1:sampleCount,block_i(idx))=angles(1,:);
                            data_tmp{idx}.AcrossPhi(1:sampleCount,block_i(idx))=angles(2,:);
                        end
                        if number==1
                            mode{idx}='CW';
                            idx_fields(idx,:)=ismember(fields,{'power' 'alongangle' 'acrossangle'});
                        end
                    else
                        
                        if number==1
                            idx_fields(idx,:)=ismember(fields,{'power'});
                        end
                    end
                    
                    if block_i(idx)==block_len||i_ping(idx)==nb_pings(idx)
                        if data.pings(idx).datatype(2)==dec2bin(1)
                            [AlongAngle,AcrossAngle]=computesPhasesAngles_v3(data_tmp{idx},...
                                trans_obj(idx).Config.AngleSensitivityAlongship,...
                                trans_obj(idx).Config.AngleSensitivityAthwartship,...
                                data.pings(idx).datatype,trans_obj(idx).Config.TransducerName,...
                                trans_obj(idx).Config.AngleOffsetAlongship,...
                                trans_obj(idx).Config.AngleOffsetAthwartship);
                        end
                        if p.Results.GPSOnly==0
                            fwrite(fileID(idx,strcmp(fields,'power')),db2pow_perso(double(data_tmp{idx}.power))/factor_fields(strcmpi(fields,'power')),fmt_fields{strcmpi(fields,'power')});
                            if data.pings(idx).datatype(2)==dec2bin(1)
                                fwrite(fileID(idx,strcmp(fields,'alongangle')),double(AlongAngle)/factor_fields(strcmpi(fields,'alongangle')),fmt_fields{strcmpi(fields,'alongangle')});
                                fwrite(fileID(idx,strcmp(fields,'acrossangle')),double(AcrossAngle)/factor_fields(strcmpi(fields,'acrossangle')),fmt_fields{strcmpi(fields,'acrossangle')});
                            end
                        end
                        block_i(idx)=0;
                    end
                end
            else
                
                nb_cplx_per_samples=bin2dec(fliplr(data.pings(idx).datatype(8:end)));
                if data.pings(idx).datatype(4)==dec2bin(1)
                    fmt='float32';
                elseif data.pings(idx).datatype(3)==dec2bin(1)
                    fmt='float16';
                end
                
                if (sampleCount > 0)
                    temp = fread(fid,nb_cplx_per_samples*sampleCount,fmt, 'l');
                else
                    continue;
                end
                
                if length(temp)/(nb_cplx_per_samples)~=sampleCount
                    continue;
                end
                
                if (sampleCount > 0)
                    if block_i(idx)==1
                        for isig=1:nb_cplx_per_samples/2
                            data_tmp{idx}.(sprintf('comp_sig_%1d',isig))=zeros(nb_samples(idx),nanmin(block_len,nb_pings(idx)-i_ping(idx)+1));
                        end
                    end
                    
                end
                
                for isig=1:nb_cplx_per_samples/2
                    data_tmp{idx}.(sprintf('comp_sig_%1d',isig))(1:sampleCount,block_i(idx))=temp(1+2*(isig-1):nb_cplx_per_samples:end)+1i*temp(2+2*(isig-1):nb_cplx_per_samples:end);
                end
                
                if block_i(idx)==block_len||i_ping(idx)==nb_pings(idx)
                    [~,powerunmatched]=compute_PwEK80_v3(trans_obj(idx).Config.Impedance,trans_obj(idx).Config.Ztrd,data.pings(idx).datatype,data_tmp{idx});
                    [data_tmp{idx},mode_tmp]=match_filter_data_v3(data_tmp{idx},trans_obj(idx).Params,trans_obj(idx).Filters);
                    
                    switch mode_tmp
                        case 'FM'
                            [y,pow]=compute_PwEK80_v3(trans_obj(idx).Config.Impedance,trans_obj(idx).Config.Ztrd,data.pings(idx).datatype,data_tmp{idx});
                            if i_ping(idx)==block_len||i_ping(idx)==nb_pings(idx)
                                mode{idx}=mode_tmp;
                                idx_fields(idx,:)=ismember(fields,{'power','alongangle','acrossangle','y_real','y_imag','powerunmatched'});
                            end
                        case 'CW'
                            pow=powerunmatched;
                            if i_ping(idx)==block_len||i_ping(idx)==nb_pings(idx)
                                mode{idx}=mode_tmp;
                                idx_fields(idx,:)=ismember(fields,{'power','alongangle','acrossangle'});
                            end
                    end
                    
                    [AlongAngle,AcrossAngle]=computesPhasesAngles_v3(data_tmp{idx},...
                        trans_obj(idx).Config.AngleSensitivityAlongship,...
                        trans_obj(idx).Config.AngleSensitivityAthwartship,...
                        data.pings(idx).datatype,trans_obj(idx).Config.TransducerName,...
                        trans_obj(idx).Config.AngleOffsetAlongship,...
                        trans_obj(idx).Config.AngleOffsetAthwartship);
                    if p.Results.GPSOnly==0
                        if strcmp(mode{idx},'FM')
                            fwrite(fileID(idx,strcmp(fields,'powerunmatched')),(double(powerunmatched))/factor_fields(strcmpi(fields,'powerunmatched')),fmt_fields{strcmpi(fields,'powerunmatched')});
                            fwrite(fileID(idx,strcmp(fields,'y_real')),double(real(y))/factor_fields(strcmpi(fields,'y_real')),fmt_fields{strcmpi(fields,'y_real')});
                            fwrite(fileID(idx,strcmp(fields,'y_imag')),double(imag(y))/factor_fields(strcmpi(fields,'y_imag')),fmt_fields{strcmpi(fields,'y_imag')});
                        end
                        fwrite(fileID(idx,strcmp(fields,'power')),(double(pow))/factor_fields(strcmpi(fields,'power')),fmt_fields{strcmpi(fields,'power')});
                        fwrite(fileID(idx,strcmp(fields,'alongangle')),double(AlongAngle)/factor_fields(strcmpi(fields,'alongangle')),fmt_fields{strcmpi(fields,'alongangle')});
                        fwrite(fileID(idx,strcmp(fields,'acrossangle')),double(AcrossAngle)/factor_fields(strcmpi(fields,'acrossangle')),fmt_fields{strcmpi(fields,'acrossangle')});
                    end
                    block_i(idx)=0;
                end
            end
            i_ping(idx) = i_ping(idx) + 1;
            block_i(idx)=block_i(idx)+1;
            
            
            
        case 'MRU0'
            id_mru0=id_mru0+1;
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            tmp=fread(fid,1,'float32', 'l');
            if~isempty(tmp)
                mru0_att.Heave(id_mru0) = tmp;
                mru0_att.Roll(id_mru0) = fread(fid,1,'float32', 'l');
                mru0_att.Pitch(id_mru0) = fread(fid,1,'float32', 'l');
                mru0_att.Heading(id_mru0) = fread(fid,1,'float32', 'l');
            end
            
        case 'RAW0'
            
            
            chan=idx_raw_obj.chan_dg(idg);
            idx_chan=find(chan==channels);
            
            if isempty(idx_chan)||i_ping(idx_chan)>nb_pings(idx_chan)
                continue;
            end
            
            %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
            fseek(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'cof');
            data.pings(idx_chan).time(i_ping(idx_chan))=idx_raw_obj.time_dg(idg);
            temp=fread(fid,4,'int8', 'l');
            data.pings(idx_chan).datatype=(dec2bin(256*temp(3)+temp(4),8));
            data.pings(idx_chan).mode(i_ping(idx_chan))=256*temp(3)+temp(4);
            
            if block_i(idx_chan)==1
                data_tmp{idx_chan}.power=-999*ones(nb_samples(idx_chan),nanmin(block_len,nb_pings(idx_chan)-i_ping(idx_chan)+1));
                if data.pings(idx_chan).datatype(2)==dec2bin(1)
                    data_tmp{idx_chan}.AcrossPhi=zeros(nb_samples(idx_chan),nanmin(block_len,nb_pings(idx_chan)-i_ping(idx_chan)+1));
                    data_tmp{idx_chan}.AlongPhi=zeros(nb_samples(idx_chan),nanmin(block_len,nb_pings(idx_chan)-i_ping(idx_chan)+1));
                end
            end
            
            [data,power_tmp,angles]=readRaw0_v2(data,idx_chan,i_ping(idx_chan),fid);
            
            if i_ping(idx_chan)==1
                mode{idx_chan}='CW';
                if data.pings(idx_chan).datatype(2)==dec2bin(1)
                    idx_fields(idx_chan,:)=ismember(fields,{'power' 'alongangle' 'acrossangle'});
                else
                    idx_fields(idx_chan,:)=ismember(fields,{'power'});
                end
                [trans_obj(idx_chan).Config,trans_obj(idx_chan).Params]=config_from_ek60(data.pings(idx_chan),config_EK60(idx_freq(idx_chan)));
            end
            
            data_tmp{idx_chan}.power(1:numel(power_tmp),block_i(idx_chan))=power_tmp;
            if data.pings(idx_chan).datatype(2)==dec2bin(1)
                data_tmp{idx_chan}.AlongPhi(1:size(angles,2),block_i(idx_chan))=angles(1,:);
                data_tmp{idx_chan}.AcrossPhi(1:size(angles,2),block_i(idx_chan))=angles(2,:);
            end
            
            if block_i(idx_chan)==block_len||i_ping(idx_chan)==nb_pings(idx_chan)
                if data.pings(idx_chan).datatype(2)==dec2bin(1)
                    [AlongAngle,AcrossAngle]=computesPhasesAngles_v3(data_tmp{idx_chan},...
                        trans_obj(idx_chan).Config.AngleSensitivityAlongship,...
                        trans_obj(idx_chan).Config.AngleSensitivityAthwartship,...
                        data.pings(idx_chan).datatype,...
                        trans_obj(idx_chan).Config.TransducerName,...
                        trans_obj(idx_chan).Config.AngleOffsetAlongship,...
                        trans_obj(idx_chan).Config.AngleOffsetAthwartship);
                end
                if p.Results.GPSOnly==0
                    fwrite(fileID(idx_chan,strcmp(fields,'power')),db2pow_perso(double(data_tmp{idx_chan}.power))/factor_fields(strcmpi(fields,'power')),fmt_fields{strcmpi(fields,'power')});
                    if data.pings(idx_chan).datatype(2)==dec2bin(1)
                        fwrite(fileID(idx_chan,strcmp(fields,'alongangle')),double(AlongAngle)/factor_fields(strcmpi(fields,'alongangle')),fmt_fields{strcmpi(fields,'alongangle')});
                        fwrite(fileID(idx_chan,strcmp(fields,'acrossangle')),double(AcrossAngle)/factor_fields(strcmpi(fields,'acrossangle')),fmt_fields{strcmpi(fields,'acrossangle')});
                    end
                end
                block_i(idx_chan)=0;
            end
            i_ping(idx_chan)=i_ping(idx_chan)+1;
            block_i(idx_chan)=block_i(idx_chan)+1;
    end
end
fclose(fid);

if p.Results.GPSOnly==0
    for i=1:nb_trans
        for ifif=1:numel(fields)
            fclose(fileID(i,ifif));
            %delete(curr_data_name{i,ifif});
        end
    end
end
idx_rem_nmea=cellfun(@isempty,NMEA.string);
NMEA.string(idx_rem_nmea)=[];
NMEA.type(idx_rem_nmea)=[];
NMEA.time(idx_rem_nmea)=[];

%Complete Params if necessary


for idx=1:nb_trans
    
    idx_nonnan=find(trans_obj(idx).Params.PulseLength~=0);
    
    time_s=trans_obj(idx).Params.Time;
    for i=1:length(idx_nonnan)
        if i==length(idx_nonnan)
            idx_rep=idx_nonnan(i):length(trans_obj(idx).Params.TransmitPower);
        else
            idx_rep=idx_nonnan(i):(idx_nonnan(i+1)-1);
        end
        
        for jj=1:length(prop_params)
            
            if iscell(trans_obj(idx).Params.(prop_params{jj}))
                trans_obj(idx).Params.(prop_params{jj})(idx_rep)=trans_obj(idx).Params.(prop_params{jj})(idx_nonnan(i));
            else
                trans_obj(idx).Params.(prop_params{jj})(idx_rep)=trans_obj(idx).Params.(prop_params{jj})(idx_nonnan(i));
            end
            
        end
        
    end
    
    if any(trans_obj(idx).Params.Frequency==0)
        trans_obj(idx).Params.Frequency(trans_obj(idx).Params.Frequency==0)=trans_obj(idx).Config.Frequency;
    end
    if any(trans_obj(idx).Params.FrequencyStart==0)
        trans_obj(idx).Params.FrequencyStart(trans_obj(idx).Params.FrequencyStart==0)=trans_obj(idx).Params.Frequency(trans_obj(idx).Params.FrequencyStart==0);
        trans_obj(idx).Params.FrequencyEnd(trans_obj(idx).Params.FrequencyEnd==0)=trans_obj(idx).Params.Frequency(trans_obj(idx).Params.FrequencyEnd==0);
    end
    trans_obj(idx).Params.Time=time_s;
end





switch ftype
    case 'EK80'
        
    case 'EK60'
        for i=1:length(idx_freq)
            [trans_obj(i).Config,trans_obj(i).Params]=config_from_ek60(data.pings(i),config_EK60(idx_freq(i)));
        end
        envdata=env_data_cl();
        envdata.SoundSpeed=data.pings(1).soundvelocity(1);
end

idx_fields=idx_fields>0;

c = envdata.SoundSpeed;

for i =1:nb_trans
    
    trans_obj(i).Mode=mode{i};
    
    if ~any(trans_obj(i).Params.Absorption~=0)
        alpha= seawater_absorption(trans_obj(i).Params.Frequency(1)/1e3, (envdata.Salinity), (envdata.Temperature), (envdata.Depth),'fandg')/1e3;
        trans_obj(i).Params.Absorption(:)=round(alpha*1e3)/1e3*ones(1,nb_pings(i));
    end
    
    if p.Results.GPSOnly==0
        sub_ac_data_temp=sub_ac_data_cl.sub_ac_data_from_files(curr_data_name(i,idx_fields(i,:)),[nb_samples(i) nb_pings(i)],fields(idx_fields(i,:)));
        
        trans_obj(i).Data=ac_data_cl('SubData',sub_ac_data_temp,...
            'Nb_samples',nb_samples(i),...
            'Nb_pings',nb_pings(i),...
            'MemapName',curr_data_name_t{i});
    end
    
    f_to_del=curr_data_name(i,~idx_fields(i,:));
    for ifif=1:numel(f_to_del)
        delete(f_to_del{ifif});
    end
    
    range=trans_obj(i).compute_transceiver_range(c);
    trans_obj(i).set_transceiver_range(range);
    trans_obj(i).set_transceiver_time(data.pings(i).time);
    if p.Results.GPSOnly==0
        trans_obj(i).set_transceiver_time(data.pings(i).time);
    else
        trans_obj(i).set_transceiver_time([data.pings(i).time dgTime]);
    end
    trans_obj(i).Bottom=[];
end



