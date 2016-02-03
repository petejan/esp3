function [header,data]=readEK80(path,filenames,varargin)

timeOffset=0;
HEADER_LEN=12;

p = inputParser;

defaultPingRange=[1 Inf];
checkPingRange=@(PingRange)(PingRange(1)>0&&PingRange(2)>=PingRange(1));

checkFilenames=@(name)(ischar(name)||iscell(name));

addRequired(p,'path',@ischar);
addRequired(p,'filenames',checkFilenames);
addParameter(p,'PingRange',defaultPingRange,checkPingRange);
addParameter(p,'GPS',true,@islogical);
addParameter(p,'GPSOnly',false,@islogical);
addParameter(p,'Frequencies',-1,@isnumeric);

parse(p,path,filenames,varargin{:});

vec_freq=p.Results.Frequencies;

if ~iscell(filenames)
    filenames={filenames};
end

file_date=nan(1,length(filenames));
for ii=1:length(filenames)
    listing = dir([path filenames{ii}]);
    file_date(ii)=listing.datenum;
end

if ~issorted(file_date)
    [~,idx_sort]=sort(file_date);
    filenames=filenames(idx_sort);
end


for ii=1:length(filenames)
    filename=filenames{ii};
    fid = fopen([path filename], 'r');
    len=fread(fid, 1, 'int32', 'l');
    
    [dgType, ~] =read_dgHeader(fid,timeOffset);
    switch (dgType)
        
        case 'XML0'
            
            t_line=(fread(fid,len-HEADER_LEN,'*char','l'))';
            t_line=deblank(t_line);
            
            fread(fid, 1, 'int32', 'l');
            
            fid_xml=fopen([path 'xml0_config.xml'],'w');
            fprintf(fid_xml,'%s',t_line);
            fclose(fid_xml);
            
            xstruct=parseXML([path 'xml0_config.xml']);
            
            [header,config]=read_config_xstruct(xstruct);
            
            CIDs=cell(1,length(config));
            
            uuu=0;
            idx_freq=[];
            for i=1:length(config)
                CIDs{i}=char(config(i).ChannelID);
                freqs=config(i).Frequency;
                if nansum((vec_freq==-1))==1||~isempty(find(freqs==vec_freq, 1))
                    uuu=uuu+1;
                    data.config(uuu)=config(i);
                    idx_freq=[idx_freq i];
                end
            end
            CIDs_freq=CIDs(idx_freq);
            header.transceivercount=length(idx_freq);
            if ii==1
                nb_pings=zeros(length(idx_freq),1);
                nb_samples=zeros(length(idx_freq),1);
            end
            
            [nb_samples_curr,nb_pings_curr]=get_nb_samples(fid,CIDs);
            
            nb_samples=nanmax(nb_samples_curr(idx_freq,:),nb_samples);
            nb_pings=nb_pings+nb_pings_curr(idx_freq,:);
            nb_pings_asked=p.Results.PingRange(2)-p.Results.PingRange(1)+1;
            nb_pings=nanmin(nb_pings,nb_pings_asked);
            
            fclose(fid);
            
            
            
        otherwise
            disp(dgType);
            disp('First Datagram is not XML0... EK60 file?');
            header=-1;
            data=-1;
            fclose(fid);
            return;
    end
end



for ii=1:length(filenames)
    
    filename=filenames{ii};
    fid = fopen([path filename], 'r');
    
    if ii==1
        for i=1:length(data.config)
            nb_pings(i)=nanmin(nb_pings(i),p.Results.PingRange(2)-p.Results.PingRange(1)+1);
            data.pings(i).comp_sig_1=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_2=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_3=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).comp_sig_4=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).samples=(nan(nb_samples(i),nb_pings(i)));
            data.pings(i).number=nan(1,nb_pings(i));
            data.pings(i).time=nan(1,nb_pings(i));
            data.pings(i).samples=(1:nb_samples(i))';
        end
        curr_ping = ones(length(data.config),1);
        curr_nmea=1;

    end
    
    
    while (true)
        
        len = fread(fid, 1, 'int32', 'l');
        if (feof(fid))
            break;
        end
        
        %  read datagram header
        [dgType, dgTime] = read_dgHeader(fid, timeOffset);
        %disp(dgType);
        %  process datagrams by type
        switch (dgType)
            
            case 'XML0'
                %disp(dgType);
                t_line=(fread(fid,len-HEADER_LEN,'*char','l'))';
                t_line=deblank(t_line);
                if ~isempty(strfind(t_line,'Configuration'))
                    fid_xml=fopen([path 'xml0_config.xml'],'w');
                    fprintf(fid_xml,'%s',t_line);
                    fclose(fid_xml);
                    xstruct=parseXML([path 'xml0_config.xml']);
                elseif ~isempty(strfind(t_line,'Environment'))
                    fid_xml=fopen([path 'xml0_env.xml'],'w');
                    fprintf(fid_xml,'%s',t_line);
                    fclose(fid_xml);
                    xstruct=parseXML([path 'xml0_env.xml']);
                elseif ~isempty(strfind(t_line,'Parameter'))
                    fid_xml=fopen([path 'xml0_param.xml'],'w');
                    fprintf(fid_xml,'%s',t_line);
                    fclose(fid_xml);
                    xstruct=parseXML([path 'xml0_param.xml']);
                end
                
                switch xstruct.Name
                    case'Configuration'
                        [~,config_temp]=read_config_xstruct(xstruct);
                        data.config=config_temp(idx_freq);
                    case 'Environment'
                        env_temp=read_env_xstruct(xstruct);
                        data.env=env_temp;
                    case 'Parameter'
                        params_temp=read_params_xstruct(xstruct);
                        
                        idx = find(strcmp(deblank(CIDs_freq),deblank(params_temp.ChannelID)));
                        
                        fields_params=fieldnames(params_temp);
                        
                        if ~isempty(idx)
                            if curr_ping(idx)>=p.Results.PingRange(1)&&curr_ping(idx)<=p.Results.PingRange(2)
                                data.params(idx).time(curr_ping(idx))=dgTime;
                                for jj=1:length(fields_params)
                                    switch fields_params{jj}
                                        case 'ChannelID'
                                            data.params(idx).(fields_params{jj}){curr_ping(idx)-p.Results.PingRange(1)+1}=(params_temp.(fields_params{jj}));
                                        otherwise
                                            data.params(idx).(fields_params{jj})(curr_ping(idx)-p.Results.PingRange(1)+1)=str2double(params_temp.(fields_params{jj}));
                                    end
                                end
                            end
                        end
                end
                
                
            case 'NME0'
                %disp(dgType);
                
                text_nmea=(fread(fid,len-HEADER_LEN,'*char','l'))';
                data.NMEA.string{curr_nmea}=text_nmea;
                data.NMEA.time(curr_nmea)=dgTime;
                curr_nmea=curr_nmea+1;
                
            case 'TAG0'
                %disp(dgType);
                fseek(fid, len - HEADER_LEN, 0);
            case 'FIL1'
                %disp(dgType);
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
            case 'RAW3'
                %disp(dgType);
                % read channel ID
                if isempty(idx)                    
                    fseek(fid, len - HEADER_LEN, 0);   
                else
                    if curr_ping(idx)>=p.Results.PingRange(1)&&curr_ping(idx)<=p.Results.PingRange(2)
                        channelID = (fread(fid,128,'*char', 'l')');
                        idx = find(strcmp(deblank(CIDs_freq),deblank(channelID)));
                        datatype=fread(fid,1,'int16', 'l');
                        fread(fid,1,'int16', 'l');
                        
                        offset=fread(fid,1,'int32', 'l');
                        sampleCount=fread(fid,1,'int32', 'l');
                        %  store sample number if required/valid
                        number=curr_ping(idx);
                        
                        if (sampleCount > 0)
                            temp = fread(fid,8*sampleCount,'float32', 'l');
                        end
                        
                        data.pings(idx).channelID=channelID;
                        data.pings(idx).datatype=datatype;
                        data.pings(idx).offset=offset;
                        data.pings(idx).sampleCount=sampleCount;
                        data.pings(idx).number(curr_ping(idx)-p.Results.PingRange(1)+1)=number;
                        data.pings(idx).time(curr_ping(idx)-p.Results.PingRange(1)+1)=dgTime;
                        if (sampleCount > 0)
                            data.pings(idx).comp_sig_1(1:data.pings(idx).sampleCount,curr_ping(idx)-p.Results.PingRange(1)+1)=temp(1:8:end)+1i*temp(2:8:end);
                            data.pings(idx).comp_sig_2(1:data.pings(idx).sampleCount,curr_ping(idx)-p.Results.PingRange(1)+1)=temp(3:8:end)+1i*temp(4:8:end);
                            data.pings(idx).comp_sig_3(1:data.pings(idx).sampleCount,curr_ping(idx)-p.Results.PingRange(1)+1)=temp(5:8:end)+1i*temp(6:8:end);
                            data.pings(idx).comp_sig_4(1:data.pings(idx).sampleCount,curr_ping(idx)-p.Results.PingRange(1)+1)=temp(7:8:end)+1i*temp(8:8:end);
                        end                        
                        curr_ping(idx) = curr_ping(idx) + 1;                        
                    else
                        fseek(fid, len - HEADER_LEN, 0);
                        curr_ping(idx) = curr_ping(idx) + 1;
  
                        if curr_ping(idx)>p.Results.PingRange(2)
                            fclose(fid);
                            return;
                        end
                        
                    end
                end
                
            case 'MRU0'
                fseek(fid, len - HEADER_LEN, 0);
            otherwise
                
                disp(dgType);
                disp('Unrecognized Datagram... EK60 file?');
                header=-1;
                data=-1;
                fclose(fid);
                return;
        end
        %  datagram length is repeated...
        fread(fid, 1, 'int32', 'l');
    end
    
end


