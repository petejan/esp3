function layers=read_asl(Filename_cell,varargin)

p = inputParser;

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);

parse(p,Filename_cell,varargin{:});

dir_data=p.Results.PathToMemmap;

for i_cell=1:length(Filename_cell)
    
    file_f=Filename_cell{i_cell};
    fprintf('Openning file %s\n',file_f);
    fid=fopen(file_f,'r','b');
    
    if fid==-1
        return;
    end
    flag=fread(fid,1,'uint16');
    fread(fid,1,'uint16');
    serial=fread(fid,1,'uint16');
    frewind(fid);
    data_tmp=fread(fid,'uint16');
    id_flag=find(hex2dec('FD02')==data_tmp);
    id_serial=find(serial==data_tmp);
    id_flag=intersect(id_flag,id_serial-2);
    
    data=init_data(length(id_flag));
    
    %fseek(fid,0,-1);
    frewind(fid);
    pos=1;
    
    for ip=1:length(id_flag)
%         if pos~=id_flag(ip)
%             id_flag(ip)
%             pos
%             disp('Louche');
%             fseek(fid,(id_flag(ip)-1)*2,-1);
%         end
        flag(ip)=fread(fid,1,'uint16');
        if hex2dec('FD02')~=flag(ip)
            continue;
        end
        
        data.burst_num(ip)=fread(fid,1,'uint16');
        data.serial(ip)=fread(fid,1,'uint16');
        data.status(ip)=fread(fid,1,'uint16');
        data.interval(ip)=fread(fid,1,'uint32');
        time=fread(fid,7,'uint16');
        data.time(ip)=datenum(time(1:6)')+time(end)/100/60/60/24;
        data.f_s(:,ip)=fread(fid,4,'uint16');
        data.sample_start(:,ip)=fread(fid,4,'uint16');
        data.nb_bins(:,ip)=fread(fid,4,'uint16');
        data.range_sple_bin(:,ip)=fread(fid,4,'uint16');
        data.ping_per_profile(ip)=fread(fid,1,'uint16');
        data.average_ping_flag(ip)=fread(fid,1,'uint16');
        data.nb_pings_in_burst(ip)=fread(fid,1,'uint16');
        data.ping_period(ip)=fread(fid,1,'uint16');
        data.first_ping(ip)=fread(fid,1,'uint16');
        data.last_ping(ip)=fread(fid,1,'uint16');
        data.data_type(:,ip)=fread(fid,4,'uint8');
        data.err_num(ip)=fread(fid,1,'uint16');
        data.phase_num(ip)=fread(fid,1,'uint8');
        data.over_run(ip)=fread(fid,1,'uint8');
        data.nb_channel(ip)=fread(fid,1,'uint8');
        data.gains(:,ip)=fread(fid,4,'uint8');
        fread(fid,1,'uint8');
        data.pulse_length(:,ip)=double(fread(fid,4,'uint16'))/1e6;
        data.board_num(:,ip)=fread(fid,4,'uint16');
        data.freq(:,ip)=double(fread(fid,4,'uint16')*1e3);
        data.sensor_flag(ip)=fread(fid,1,'uint16');
        
        tmp_x=double(fread(fid,1,'uint16'));%Tilt_x (degrees) = X_a + X_b (NX) + X_c (NX)2 + X_d (NX)3
        data.tilt_x(ip)=-4.575902369000e+01-6.699530000000e-04*tmp_x+1.930670000000e-07*tmp_x.^2-2.984280000000e-12*tmp_x.^3;
        
        tmp_y=double(fread(fid,1,'uint16'));%Tilt_y (degrees) = Y_a + Y_b (NY) + Y_c (NY)2 + Y_d (NY)3
        data.tilt_y(ip)=-4.825819620000e+01-2.867530000000e-04*tmp_y+1.807400000000e-07*tmp_y.^2-2.887230000000e-12*tmp_y.^3;
        
        data.battery(ip)=fread(fid,1,'uint16');
        
        tmp=fread(fid,1,'uint16');
        tmp=2.5*(double(tmp)/65535);
        data.pressure(ip)=tmp;
        % Vin=2.5*(counts/65535). Then calculate the equivalent pressure in dBar:
        % P = Vin*m + b
        tmp=fread(fid,1,'uint16');
        tmp=2.5*(double(tmp)/65535);
        tmp=(525+3000*tmp)./(1.874-tmp);
        data.temperature(ip)=1./(1.466e-3+2.38809e-4*log(tmp)+1.00335e-7*log(tmp).^3)-273;
        %Vin=2.5*(counts/65535). Then calculate the equivalent bridge resistance:
        % R= (ka+kb*Vin)/(kc-Vin). Finally the temperature in oC=
        % T=1/(A+B*(LN(R))+C*(LN(R)^3))-273
        
        data.ad_chan_6(ip)=fread(fid,1,'uint16');
        data.ad_chan_7(ip)=fread(fid,1,'uint16');
        
        for ic=1:data.nb_channel(ip)
            tmp=double(fread(fid,data.nb_bins(ic,ip),'uint16'));
            power=152.4- 2.5/0.022 + tmp/(65535/2.5*0.022);%EL = ELmax – 2.5/a + N/(26,214·a)
            data.(sprintf('chan_%.0f',ic))(:,ip)=power;
        end

        pos=ftell(fid);
        
    end
    
    fclose(fid);
    
    for ic=1:max(data.nb_channel)
        
        [nb_samples,nb_pings]=size(data.(sprintf('chan_%.0f',ic)));
        sample_number=(nanmean(data.sample_start(ic,:))+1:nb_samples+nanmean(data.sample_start(ic,:)))';
        c=1500;
        time=sample_number/nanmean(data.f_s(ic,:));
        range=c*time/2;
        
        
        config_obj=config_cl();
        params_obj=params_cl(nb_pings);
        envdata=env_data_cl('SoundSpeed',1500);
        config_obj.EthernetAddress='';
        config_obj.IPAddress='';
        config_obj.SerialNumber='';

        config_obj.PulseLength=nanmean(data.pulse_length(ic,:));
        config_obj.BeamType='';
        config_obj.BeamWidthAlongship=6;
        config_obj.BeamWidthAthwartship=6;
        config_obj.EquivalentBeamAngle=10*log10(1.4*pi*(1-cosd(config_obj.BeamWidthAlongship)));
        config_obj.Frequency=data.freq(1,ic);
        config_obj.FrequencyMaximum=data.freq(1,ic);
        config_obj.FrequencyMinimum=data.freq(1,ic);
        config_obj.Gain=0;
        config_obj.SaCorrection=0;
        config_obj.TransducerName='';
        
        params_obj.Time=data.time;
        params_obj.Frequency(:)=data.freq(1,ic);
        params_obj.FrequencyEnd(:)=data.freq(1,ic);
        params_obj.FrequencyStart(:)=data.freq(1,ic);
        params_obj.PulseLength(:)=nanmean(data.pulse_length(ic,:));
        params_obj.SampleInterval(:)=1./nanmean(data.f_s(ic,:));
        params_obj.TransducerDepth(:)=0;
        params_obj.TransmitPower(:)=1;
        params_obj.Absorption(:)= sw_absorption(params_obj.Frequency(1)/1e3, (envdata.Salinity), (envdata.Temperature), (envdata.Depth),'fandg')/1e3;
        
        data_struct.sv = data.(sprintf('chan_%.0f',ic)) - 162.5 - 97.2 + repmat(20*log10(range)+2*params_obj.Absorption(1)*range,1,nb_pings) - 10*log10(c*params_obj.PulseLength(1)/2)-config_obj.EquivalentBeamAngle;
        data_struct.sp = data.(sprintf('chan_%.0f',ic)) - 162.5 - 97.2 + repmat(40*log10(range)+2*params_obj.Absorption(1)*range,1,nb_pings);
        Np=nanmean(params_obj.PulseLength./params_obj.SampleInterval);
        data_struct.power=remove_TVG_from_Sp(data_struct.sp,range,params_obj.Absorption(1),Np);
        
        [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(data_struct,dir_data,{});
        
        
        ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
            'Range',range,...
            'Time',data.time,...
            'MemapName',curr_name);
        
        clear curr_data;
        
        main_path=whereisEcho();
        
        [~,~,algo_vec]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));
        if isempty(algo_vec)
            algo_vec=init_algos();
        else
            algo_vec=reset_range(algo_vec,range);
        end
        
        transceiver=transceiver_cl('Data',ac_data_temp,...
            'Algo',algo_vec,...
            'Mode','CW');
        transceiver.Config=config_obj;
        transceiver.Params=params_obj;
        
         layers(i_cell)=layer_cl('Filename',{file_f},'Filetype','ASL','Transceivers',transceiver,'EnvData',envdata);
       
    end
    
    
    
end
end




function data=init_data(nb_pings)

data.burst_num=nan(1,nb_pings);
data.serial=nan(1,nb_pings);
data.status=nan(1,nb_pings);
data.interval=nan(1,nb_pings);
data.time=nan(1,nb_pings);
data.f_s=nan(4,nb_pings);
data.sample_start=nan(4,nb_pings);
data.nb_bins=nan(4,nb_pings);
data.range_sple_bin=nan(4,nb_pings);
data.ping_per_profile=nan(1,nb_pings);
data.average_ping_flag=nan(1,nb_pings);
data.nb_pings_in_burst=nan(1,nb_pings);
data.ping_period=nan(1,nb_pings);
data.first_ping=nan(1,nb_pings);
data.last_ping=nan(1,nb_pings);
data.data_type=nan(4,nb_pings);
data.err_num=nan(1,nb_pings);
data.phase_num=nan(1,nb_pings);
data.over_run=nan(1,nb_pings);
data.nb_channel=nan(1,nb_pings);
data.gains=nan(4,nb_pings);
data.pulse_length=nan(4,nb_pings);
data.board_num=nan(4,nb_pings);
data.freq=nan(4,nb_pings);
data.sensor_flag=nan(1,nb_pings);
data.tilt_x=nan(1,nb_pings);
data.tilt_y=nan(1,nb_pings);
data.battery=nan(1,nb_pings);
data.pressure=nan(1,nb_pings);
data.temperature=nan(1,nb_pings);
data.ad_chan_6=nan(1,nb_pings);
data.ad_chan_7=nan(1,nb_pings);


end