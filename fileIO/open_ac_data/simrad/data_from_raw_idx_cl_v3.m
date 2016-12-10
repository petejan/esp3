function [trans_obj,envdata,NMEA,mru0_att]=data_from_raw_idx_cl_v3(path_f,idx_raw_obj,varargin)
HEADER_LEN=12;
p = inputParser;
addRequired(p,'path_f',@(x) ischar(x));
addRequired(p,'idx_raw_obj',@(x) isa(x,'raw_idx_cl'));
addParameter(p,'PingRange',[1 inf],@isnumeric);
addParameter(p,'SampleRange',[1 inf],@isnumeric);
addParameter(p,'Frequencies',[],@isnumeric);
addParameter(p,'GPSOnly',0,@isnumeric);
addParameter(p,'PathToMemmap',path_f,@ischar);
addParameter(p,'FieldNames',{});
addParameter(p,'load_bar_comp',[]);

parse(p,path_f,idx_raw_obj,varargin{:});
results=p.Results;

PingRange=results.PingRange;
SampleRange=results.SampleRange;
Frequencies=results.Frequencies;

filename=fullfile(path_f,idx_raw_obj.filename);

ftype=get_ftype(filename);

load_bar_comp=results.load_bar_comp;



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

if isempty(idx_freq)
    idx_freq=(1:length(freq))';
end

nb_trans=length(idx_freq);
channels=unique(idx_raw_obj.chan_dg(~isnan(idx_raw_obj.chan_dg)));
channels=channels(idx_freq);
CIDs_freq=CIDs(idx_freq);
trans_obj(length(CIDs_freq))=transceiver_cl();

if p.Results.GPSOnly>0
    nb_pings=zeros(1,length(CIDs_freq));
    nb_samples=zeros(1,length(CIDs_freq));
else
    nb_pings=idx_raw_obj.get_nb_pings_per_channels();
    nb_pings=nb_pings(idx_freq);
    nb_pings=nanmin(nb_pings,PingRange(2));
    nb_pings=nb_pings-PingRange(1)+1;
    nb_pings(nb_pings<0)=0;
    
    nb_samples=idx_raw_obj.get_nb_samples_per_channels();
    nb_samples=nb_samples(idx_freq);
    nb_samples=nanmin(nb_samples,SampleRange(2));
    nb_samples=nb_samples-SampleRange(1)+1;
    nb_samples(nb_samples<0)=0;
end


nb_nmea=idx_raw_obj.get_nb_nmea_dg();


time_nmea=idx_raw_obj.get_time_dg('NME0');
NMEA.time= time_nmea;
NMEA.string= cell(1,nb_nmea);

params_cl_init(nb_trans)=params_cl();

for i=1:nb_trans
    nb_pings(i)=nanmin(nb_pings(i),p.Results.PingRange(2)-p.Results.PingRange(1)+1);
    data.pings(i).number=nan(1,nb_pings(i));
    data.pings(i).time=nan(1,nb_pings(i));
    data.pings(i).samples=(1:nb_samples(i))';
    trans_obj(i).Params=params_cl(nb_pings(i));
    
    switch config(i).TransceiverType
        case {'WBT','WBT Tube','WBAT'}
            data.pings(i).comp_sig_1=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_2=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_3=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_4=(nan(nb_samples(i),nb_pings(i)));
            
        case 'GPT'
            data.pings(i).power=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).alongship_e=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).athwartship_e=(nan(nb_samples(i),nb_pings(i)));
    end
end

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


fid=fopen(filename,'r');

if ~isempty(load_bar_comp)
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(idx_raw_obj.type_dg), 'Value',0);
    load_bar_comp.status_bar.setText(sprintf('Opening File %s',filename));
end

nb_dg=length(idx_raw_obj.type_dg);
for idg=1:nb_dg
    pos=ftell(fid);
    if mod(idg,floor(nb_dg/100))==1
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_dg, 'Value',idg);
        end
    end
    switch  idx_raw_obj.type_dg{idg}
        case 'XML0'
            %disp(dgType);
            
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            t_line=(fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'*char','l'))';
            t_line=deblank(t_line);
            if ~isempty(strfind(t_line,'<Configuration>'))&&conf_dg==1
                if conf_dg==1
                    fread(fid, 1, 'int32', 'l');
                    continue;
                end
                
            elseif ~isempty(strfind(t_line,'<Environment>'))&&env_dg==1
                fread(fid, 1, 'int32', 'l');
                continue;
%             elseif ~isempty(strfind(t_line,'<Parameter>'))&&any(strcmp(t_line,param_str_init))
%                 idx = find(strcmp(t_line,param_str_init));
%                 if 0
%                     dgTime=idx_raw_obj.time_dg(idg);
%                     fread(fid, 1, 'int32', 'l');
%                     params_cl_init(idx).Time=dgTime;
%                     trans_obj(idx).Params.Time(i_ping(idx)-p.Results.PingRange(1)+1)=dgTime;
%                     continue;
%                 end
            end
            
            %[~,output,type]=read_xml0_OLD2(t_line);
            
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
                                        if  any(strcmpi(prop_config,props{iii}))
                                            trans_obj(idx).Config.(props{iii})=config_temp(iout).(props{iii});
                                        end
                                end
                                
                            end
                            trans_obj(idx).Config.XML_string=t_line;
                        end
                    end
                case 'Environment'
                    
                    props=fieldnames(output);
                    envdata=env_data_cl();
                    for iii=1:length(props)
                        if  any(strcmpi(prop_env,props{iii}))
                            envdata.(props{iii})=output.(props{iii});
                        end
                    end
                case 'Parameter'
                    params_temp=output;
                    idx = find(strcmp(deblank(CIDs_freq),deblank(params_temp.ChannelID)));
                    dgTime=idx_raw_obj.time_dg(idg);
                    fields_params=fieldnames(params_temp);
                    if ~isempty(idx)
                        param_str_init{idx}=t_line;
                        if i_ping(idx)>=p.Results.PingRange(1)&&i_ping(idx)<=p.Results.PingRange(2)
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
                                        end
                                end
                            end
                            trans_obj(idx).Params.Time(i_ping(idx)-p.Results.PingRange(1)+1)=dgTime;
                            for jj=1:length(prop_params)
                                if ~isempty(params_cl_init(idx).(prop_params{jj}))
                                    if ischar(params_cl_init(idx).(prop_params{jj}))
                                        trans_obj(idx).Params.(prop_params{jj}){i_ping(idx)-p.Results.PingRange(1)+1}=(params_cl_init(idx).(prop_params{jj}));
                                    else
                                        trans_obj(idx).Params.(prop_params{jj})(i_ping(idx)-p.Results.PingRange(1)+1)=(params_cl_init(idx).(prop_params{jj}));
                                    end
                                end
                            end
                        end
                        
                        
                    end
            end
            
        case 'NME0'
            %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            i_nmea=i_nmea+1;
            NMEA.string{i_nmea}=fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'*char', 'l')';
            
        case 'FIL1'
            if fil_process==0
                %disp(dgType);
                
                fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
                stage=fread(fid,1,'int16','l');
                fread(fid,2,'char','l');
                filter_coeff_temp.channelID = (fread(fid,128,'*char', 'l')');
                filter_coeff_temp.NoOfCoefficients=fread(fid,1,'int16','l');
                filter_coeff_temp.DecimationFactor=fread(fid,1,'int16','l');
                filter_coeff_temp.Coefficients=fread(fid,2*filter_coeff_temp.NoOfCoefficients,'float','l');
                idx = find(strcmp(deblank(CIDs_freq),deblank(filter_coeff_temp.channelID)));
                
                if ~isempty(idx)
                    props=fieldnames(filter_coeff_temp);
                    for iii=1:length(props)
                        if isprop(filter_cl(), (props{iii}))
                            trans_obj(idx).Filters(stage).(props{iii})=filter_coeff_temp.(props{iii});
                        end
                    end
                end
            end
        case 'RAW3'
            if p.Results.GPSOnly>0
                continue;
            end
            %disp(dgType);
            % read channel ID
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            dgTime=idx_raw_obj.time_dg(idg);
            channelID = (fread(fid,128,'*char', 'l')');
            idx = find(strcmp(deblank(CIDs_freq),deblank(channelID)));
            
            
            if isempty(idx)
                fread(fid, idx_raw_obj.len_dg(idg) - HEADER_LEN -128);
            else
                if i_ping(idx)>=p.Results.PingRange(1)&&i_ping(idx)<=p.Results.PingRange(2)
                    
                    datatype=fread(fid,1,'int16', 'l');
                    fread(fid,1,'int16', 'l');
                    
                    offset=fread(fid,1,'int32', 'l');
                    sampleCount=fread(fid,1,'int32', 'l');
                    %  store sample number if required/valid
                    number=i_ping(idx);
                    data.pings(idx).channelID=channelID;
                    data.pings(idx).datatype=datatype;
                    data.pings(idx).offset=offset;
                    data.pings(idx).sampleCount(i_ping(idx)-p.Results.PingRange(1)+1)=sampleCount;
                    data.pings(idx).number(i_ping(idx)-p.Results.PingRange(1)+1)=number;
                    data.pings(idx).time(i_ping(idx)-p.Results.PingRange(1)+1)=dgTime;
                    
                    switch config(idx).TransceiverType
                        case {'WBT','WBT Tube','WBAT'}
                            if (sampleCount > 0)
                                temp = fread(fid,8*sampleCount,'float32', 'l');
                            end
                            
                            if (sampleCount > 0)
                                data.pings(idx).comp_sig_1(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(1:8:end)+1i*temp(2:8:end);
                                data.pings(idx).comp_sig_2(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(3:8:end)+1i*temp(4:8:end);
                                data.pings(idx).comp_sig_3(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(5:8:end)+1i*temp(6:8:end);
                                data.pings(idx).comp_sig_4(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(7:8:end)+1i*temp(8:8:end);
                            end
                            
                        case 'GPT'
                            data.pings(idx).power(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=(fread(fid,sampleCount,'int16', 'l') * 0.011758984205624);
                            if sampleCount*4==idx_raw_obj.len_dg(idg)-HEADER_LEN-12-128
                                angle=fread(fid,[2 sampleCount],'int8', 'l');
                                data.pings(idx).athwartship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=angle(1,:);
                                data.pings(idx).alongship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=angle(2,:);
                            else
                                data.pings(idx).athwartship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=zeros(sampleCount,1);
                                data.pings(idx).alongship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=zeros(sampleCount,1);
                            end
                            
                    end
                    i_ping(idx) = i_ping(idx) + 1;
                else
                    fseek(fid, len - HEADER_LEN, 0);
                    i_ping(idx) = i_ping(idx) + 1;
                    
                    if i_ping(idx)>p.Results.PingRange(2)
                        fclose(fid);
                        return;
                    end
                    
                end
            end
            
        case 'MRU0'
            id_mru0=id_mru0+1;
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            mru0_att.Heave(id_mru0) = fread(fid,1,'float32', 'l');
            mru0_att.Roll(id_mru0) = fread(fid,1,'float32', 'l');
            mru0_att.Pitch(id_mru0) = fread(fid,1,'float32', 'l');
            mru0_att.Heading(id_mru0) = fread(fid,1,'float32', 'l');
            
            
        case 'RAW0'
            if p.Results.GPSOnly>0
                continue;
            end
            chan=idx_raw_obj.chan_dg(idg);
            idx_chan=find(chan==channels);
            if isempty(idx_chan)
                continue;
            end
            %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            
            if (i_ping(idx_chan)>=PingRange(1))&&(i_ping(idx_chan)<=PingRange(2))
                data.pings(idx_chan).time(i_ping(idx_chan)-PingRange(1)+1)=idx_raw_obj.time_dg(idg);
                data=readRaw0(data,idx_chan,i_ping(idx_chan)-PingRange(1)+1,PingRange,SampleRange,fid);
            end
            i_ping(idx_chan)=i_ping(idx_chan)+1;
    end
end
fclose(fid);


%Complete Params if necessary

for idx=1:nb_trans
    
    for jj=1:length(prop_params)
        if isnumeric(trans_obj(idx).Params.(prop_params{jj}))
            if any(isnan(trans_obj(idx).Params.(prop_params{jj})))
                trans_obj(idx).Params.(prop_params{jj})(isnan(trans_obj(idx).Params.(prop_params{jj})))=trans_obj(idx).Params.(prop_params{jj})(1);
            end
        end
    end
    if any(isnan(trans_obj(idx).Params.Frequency))
        trans_obj(idx).Params.Frequency(isnan(trans_obj(idx).Params.Frequency))=trans_obj(idx).Config.Frequency;
    end
    if any(isnan(trans_obj(idx).Params.FrequencyStart))
        trans_obj(idx).Params.FrequencyStart(isnan(trans_obj(idx).Params.FrequencyStart))=trans_obj(idx).Params.Frequency(isnan(trans_obj(idx).Params.FrequencyStart));
        trans_obj(idx).Params.FrequencyEnd(isnan(trans_obj(idx).Params.FrequencyEnd))=trans_obj(idx).Params.Frequency(isnan(trans_obj(idx).Params.FrequencyEnd));
    end
    
end



if p.Results.GPSOnly==0
    
    switch ftype
        case 'EK80'
            data_ori=data;
            [data,mode]=match_filter_data_v2(trans_obj,data);
            data=compute_PwEK80_v2(trans_obj,data);
            data=computesPhasesAngles_v2(trans_obj,data);
            data_ori=compute_PwEK80_v2(trans_obj,data_ori);
            data_ori=computesPhasesAngles_v2(trans_obj,data_ori);
        case 'EK60'
            mode=cell(1,length(trans_obj));
            mode(:)={'CW'};
            for i=1:length(idx_freq)
                [trans_obj(i).Config,trans_obj(i).Params]=config_from_ek60(data.pings(i),config_EK60(idx_freq(i)));
            end
            envdata=env_data_cl();
            envdata.SoundSpeed=data.pings(1).soundvelocity(1);
    end
    
    sample_start=nan(nb_trans,1);
    sample_end=nan(nb_trans,1);
    
    for i =1:nb_trans
        sample_start(i)=SampleRange(1);
        if SampleRange(2)==Inf
            sample_end(i) =size(data.pings(i).power,1)+sample_start(i)-1;
        else
            sample_end(i)=SampleRange(2);
        end
    end
    
    c = envdata.SoundSpeed;
    
    for i =1:nb_trans
        curr_data=[];
        trans_obj(i).Mode=mode{i};
        switch trans_obj(i).Config.TransceiverType
            case {'WBT','WBT Tube','WBAT'}
                if strcmpi(mode{i},'FM')
                    curr_data.powerunmatched=single(data_ori.pings(i).power);
                    curr_data.power=single(data.pings(i).power);
                    curr_data.y_real=single(real(data.pings(i).y));
                    curr_data.y_imag=single(imag(data.pings(i).y));
                    curr_data.acrossangle=single(data.pings(i).AcrossAngle);
                    curr_data.alongangle=single(data.pings(i).AlongAngle);
                else
                    curr_data.power=single(data_ori.pings(i).power);
                    curr_data.acrossangle=single(data_ori.pings(i).AcrossAngle);
                    curr_data.alongangle=single(data_ori.pings(i).AlongAngle);
                end
                
            case 'GPT'
                curr_data.power=db2pow_perso(single(data.pings(i).power));
                curr_data.acrossphi=single(data.pings(i).athwartship_e);
                curr_data.alongphi=single(data.pings(i).alongship_e);
        end
        
        if any(isnan(trans_obj(i).Params.Absorption))
            alpha= sw_absorption(trans_obj(i).Params.Frequency(1)/1e3, (envdata.Salinity), (envdata.Temperature), (envdata.Depth),'fandg')/1e3;
            trans_obj(i).Params.Absorption=alpha*ones(1,size(curr_data.power,2));
        end
        
        [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(curr_data,p.Results.PathToMemmap,p.Results.FieldNames);
        t = trans_obj(i).Params.SampleInterval(1);
        dR = double(c .* t / 2)';
        samples=double([sample_start(i) sample_end(i)]);
        range=double(samples-1)*dR;
        
        trans_obj(i).Data=ac_data_cl('SubData',sub_ac_data_temp,...
            'Range',range,...
            'Samples',samples,...
            'Time',double(data.pings(i).time),...
            'Number',[double(data.pings(i).number(1)) double(data.pings(i).number(end))],...
            'MemapName',curr_name);
        trans_obj(i).setBottom([]);
    end
    
else
    trans_obj=transceiver_cl.empty();
    envdata=env_data_cl.empty();
end