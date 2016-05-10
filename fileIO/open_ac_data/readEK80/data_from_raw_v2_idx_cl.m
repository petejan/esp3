function [header,data]=data_from_raw_v2_idx_cl(path_f,idx_raw_obj,varargin)
HEADER_LEN=12;
p = inputParser;
addRequired(p,'path_f',@(x) ischar(x));
addRequired(p,'idx_raw_obj',@(x) isa(x,'raw_idx_cl'));
addParameter(p,'PingRange',[1 inf],@isnumeric);
addParameter(p,'SampleRange',[1 inf],@isnumeric);
addParameter(p,'Frequencies',[],@isnumeric);
addParameter(p,'GPSOnly',0,@isnumeric);

parse(p,path_f,idx_raw_obj,varargin{:});
results=p.Results;

PingRange=results.PingRange;
SampleRange=results.SampleRange;
Frequencies=results.Frequencies;

filename=fullfile(path_f,idx_raw_obj.filename);
[header,config]=read_EK80_config(filename);
freq=nan(1,length(config));
CIDs=cell(1,length(config));
for uif=1:length(freq)
    freq(uif)=config(uif).Frequency;
    CIDs{uif}=config(uif).ChannelID;
end



if isempty(Frequencies)
    idx_freq=(1:length(freq))';
else
    [~,~,idx_freq] = intersect(Frequencies,freq);
end

if isempty(idx_freq)
    idx_freq=(1:length(freq))';
end
CIDs_freq=CIDs(idx_freq);

if p.Results.GPSOnly>0
    channels=[];
    nb_pings=0;
    nb_samples=0;
else
    
    channels=unique(idx_raw_obj.chan_dg(~isnan(idx_raw_obj.chan_dg)));
    channels=channels(idx_freq);
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

data.config=config(idx_freq);
header.transceivercount=length(idx_freq);
time_nmea=idx_raw_obj.get_time_dg('NME0');
data.NMEA.time= time_nmea;
data.NMEA.string= cell(1,nb_nmea);


for i=1:length(nb_pings)
    nb_pings(i)=nanmin(nb_pings(i),p.Results.PingRange(2)-p.Results.PingRange(1)+1);
    data.pings(i).number=nan(1,nb_pings(i));
    data.pings(i).time=nan(1,nb_pings(i));
    data.pings(i).samples=(1:nb_samples(i))';
    switch config(i).TransceiverType
        case 'WBT'
            
            data.pings(i).comp_sig_1=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_2=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_3=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_4=(nan(nb_samples(i),nb_pings(i)));
            
        case 'GPT'
            data.pings(i).power=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).alongphi_e=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).athwarthphi_e=(nan(nb_samples(i),nb_pings(i)));
    end
end

i_ping = ones(length(data.config),1);
i_nmea=0;
fil_process=0;
conf_dg=0;
env_dg=0;
param_dg=zeros(1,length(CIDs_freq));

fid=fopen(filename,'r');

for idg=1:length(idx_raw_obj.type_dg)
    pos=ftell(fid);
    
    switch  idx_raw_obj.type_dg{idg}
        case 'XML0'
            %disp(dgType);
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            t_line=(fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'*char','l'))';
            t_line=deblank(t_line);
            if ~isempty(strfind(t_line,'Configuration'))
                if conf_dg==1
                    fread(fid, 1, 'int32', 'l');
                    continue;
                end
                conf_dg=1;
            elseif ~isempty(strfind(t_line,'Environment'))
                if env_dg==1
                    fread(fid, 1, 'int32', 'l');
                    continue;
                end
                
            elseif ~isempty(strfind(t_line,'Parameter'))
                if nansum(param_dg)==length(CIDs_freq);
                    fread(fid, 1, 'int32', 'l');
                    continue
                end
                
            end
            [~,output,type]=read_xml0(t_line);
            switch type
                case'Configuration'
                    data.config=output(idx_freq);
                case 'Environment'
                    data.env=output;
                case 'Parameter'
                    params_temp=output;
                    idx = find(strcmp(deblank(CIDs_freq),deblank(params_temp.ChannelID)));
                    param_dg(idx)=1;
                    
                    fields_params=fieldnames(params_temp);
                    dgTime=idx_raw_obj.time_dg(idg);
                    if ~isempty(idx)
                        if i_ping(idx)>=p.Results.PingRange(1)&&i_ping(idx)<=p.Results.PingRange(2)
                            data.params(idx).time(i_ping(idx))=dgTime;
                            for jj=1:length(fields_params)
                                switch fields_params{jj}
                                    case 'ChannelID'
                                        data.params(idx).(fields_params{jj}){i_ping(idx)-p.Results.PingRange(1)+1}=(params_temp.(fields_params{jj}));
                                    otherwise
                                        data.params(idx).(fields_params{jj})(i_ping(idx)-p.Results.PingRange(1)+1)=(params_temp.(fields_params{jj}));
                                end
                            end
                        end
                    end
            end
            
        case 'NME0'
            %fseek(fid,idx_raw_obj.pos_dg(idg),'bof');
            fread(fid,idx_raw_obj.pos_dg(idg)-pos+HEADER_LEN,'uchar', 'l');
            i_nmea=i_nmea+1;
            data.NMEA.string{i_nmea}=char(fread(fid,idx_raw_obj.len_dg(idg)-HEADER_LEN,'uchar', 'l')');
            
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
                    data.filter_coeff(idx).stages(stage)=filter_coeff_temp;
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
                fseek(fid, idx_raw_obj.len_dg(idg) - HEADER_LEN -128 , 0);
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
                    data.pings(idx).sampleCount=sampleCount;
                    data.pings(idx).number(i_ping(idx)-p.Results.PingRange(1)+1)=number;
                    data.pings(idx).time(i_ping(idx)-p.Results.PingRange(1)+1)=dgTime;
                    
                    switch config(idx).TransceiverType
                        case 'WBT'
                            if (sampleCount > 0)
                                temp = fread(fid,8*sampleCount,'float32', 'l');
                            end
                            
                            if (sampleCount > 0)
                                data.pings(idx).comp_sig_1(1:data.pings(idx).sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(1:8:end)+1i*temp(2:8:end);
                                data.pings(idx).comp_sig_2(1:data.pings(idx).sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(3:8:end)+1i*temp(4:8:end);
                                data.pings(idx).comp_sig_3(1:data.pings(idx).sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(5:8:end)+1i*temp(6:8:end);
                                data.pings(idx).comp_sig_4(1:data.pings(idx).sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=temp(7:8:end)+1i*temp(8:8:end);
                            end
                            
                        case 'GPT'
                            data.pings(idx).power(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=(fread(fid,sampleCount,'int16', 'l') * 0.011758984205624);
                            angle=fread(fid,[2 sampleCount],'int8', 'l');

                            data.pings(idx).athwartship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=angle(1,:);
                            data.pings(idx).alongship_e(1:sampleCount,i_ping(idx)-p.Results.PingRange(1)+1)=angle(2,:);
                            
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
    end
end


fclose(fid);
end