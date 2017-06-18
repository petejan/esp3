function layers=read_asl(Filename_cell,varargin)

%Hard coded calibration parameters for now
calParms.X_a=-4.575902369000e+01;
calParms.X_b=-6.699530000000e-04;
calParms.X_c=1.930670000000e-07;
calParms.X_d=-2.984280000000e-12;

calParms.Y_a=-4.825819620000e+01;
calParms.Y_b=-2.867530000000e-04;
calParms.Y_c=1.807400000000e-07;
calParms.Y_d=-2.887230000000e-12;

calParms.ka=525;
calParms.kb=3000;
calParms.kc=1.874;
calParms.A=1.466e-3;
calParms.B=2.38809e-4;
calParms.C=1.00335e-7;
calParms.EL=152.4;
calParms.TVR=165.5;
calParms.VTX=97.2;
calParms.DS=0.022;
calParms.BP=0.024;


p = inputParser;

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'calParms',calParms,@isstruct);

parse(p,Filename_cell,varargin{:});
calParms=p.Results.calParms;

dir_data=p.Results.PathToMemmap;
enc='ieee-be';
for i_cell=1:length(Filename_cell)
    
    file_f=Filename_cell{i_cell};
    fprintf('Openning file %s\n',file_f);
    fid=fopen(file_f,'r','b');
    
    if fid==-1
        return;
    end
    flag=fread(fid,1,'uint16',enc);
    fread(fid,1,'uint16',enc);
    serial=fread(fid,1,'uint16',enc);
    frewind(fid);
    data_tmp=fread(fid,'uint16',enc);
    id_flag=find(hex2dec('FD02')==data_tmp);
    id_serial=find(serial==data_tmp);
    id_flag=intersect(id_flag,id_serial-2);
    
    data=init_data(length(id_flag));
    
    %fseek(fid,0,-1);
    frewind(fid);
    
    for ip=1:length(id_flag)
        
        flag(ip)=fread(fid,1,'uint16',enc);
        if hex2dec('FD02')~=flag(ip)
            continue;
        end
        
        data.burst_num(ip)=fread(fid,1,'uint16',enc);
        data.serial(ip)=fread(fid,1,'uint16',enc);
        data.status(ip)=fread(fid,1,'uint16',enc);
        data.interval(ip)=fread(fid,1,'uint32',enc);
        date=fread(fid,7,'uint16',enc);
        data.time(ip)=datenum(date(1),date(2),date(3),date(4),date(5),date(6)+date(7)/100);
        data.f_s(:,ip)=fread(fid,4,'uint16',enc);
        data.sample_start(:,ip)=fread(fid,4,'uint16',enc);
        data.nb_bins(:,ip)=fread(fid,4,'uint16',enc);
        data.range_sple_bin(:,ip)=fread(fid,4,'uint16',enc);
        data.ping_per_profile(ip)=fread(fid,1,'uint16',enc);
        data.average_ping_flag(ip)=fread(fid,1,'uint16',enc);
        data.nb_pings_in_burst(ip)=fread(fid,1,'uint16',enc);
        data.ping_period(ip)=fread(fid,1,'uint16',enc);
        data.first_ping(ip)=fread(fid,1,'uint16',enc);
        data.last_ping(ip)=fread(fid,1,'uint16',enc);
        data.data_type(:,ip)=fread(fid,4,'uint8',enc);
        data.err_num(ip)=fread(fid,1,'uint16',enc);
        data.phase_num(ip)=fread(fid,1,'uint8',enc);
        data.over_run(ip)=fread(fid,1,'uint8',enc);
        data.nb_channel(ip)=fread(fid,1,'uint8',enc);
        data.gains(:,ip)=fread(fid,4,'uint8',enc);
        fread(fid,1,'uint8',enc);
        data.pulse_length(:,ip)=double(fread(fid,4,'uint16',enc))/1e6;
        data.board_num(:,ip)=fread(fid,4,'uint16',enc);
        data.freq(:,ip)=double(fread(fid,4,'uint16',enc)*1e3);
        data.sensor_flag(ip)=fread(fid,1,'uint16',enc);
        
        
        
        tmp_x=double(fread(fid,1,'uint16',enc));%Tilt_x (degrees) = X_a + X_b (NX) + X_c (NX)2 + X_d (NX)3
        data.tilt_x(ip) = computeTilt(tmp_x,calParms.X_a,calParms.X_b,calParms.X_c,calParms.X_d);
        tmp_y=double(fread(fid,1,'uint16',enc));%Tilt_y (degrees) = Y_a + Y_b (NY) + Y_c (NY)2 + Y_d (NY)3
        data.tilt_x(ip) = computeTilt(tmp_y,calParms.Y_a,calParms.Y_b,calParms.Y_c,calParms.Y_d);
        
        
        data.battery(ip)=fread(fid,1,'uint16',enc);
        
        tmp=fread(fid,1,'uint16',enc);
        tmp=2.5*(double(tmp)/65535);
        data.pressure(ip)=tmp;
        % Vin=2.5*(counts/65535). Then calculate the equivalent pressure in dBar:
        % P = Vin*m + b
        
        
        
        counts_T=fread(fid,1,'uint16',enc);
        data.temperature(ip) = computeTemperature(counts_T,calParms);
        
        
        data.ad_chan_6(ip)=fread(fid,1,'uint16',enc);
        data.ad_chan_7(ip)=fread(fid,1,'uint16',enc);
        
        for ic=1:data.nb_channel(ip)
            if(data.data_type(ic,ip))
                if(data.average_ping_flag(ip))
                    divisor = data.ping_per_profile(ip) * data.data.range_sple_bin(ic,ip);
                else
                    divisor = data.data.range_sple_bin(ic,ip);
                end
                ls = fread(fid,data.nb_bins(ic,ip),'uint32',enc);
                lso = fread(fid,data.nb_bins(ic,ip),'uchar',enc);
                v = (ls + lso*4294967295)/divisor;
                v = (log10(v)-2.5)*(8*65535)*calParms.DS(ic);
                v(isinf(v)) = 0;
                counts = v;
            else
                counts = fread(fid,data.nb_bins(ic,ip),'uint16','ieee-be');
            end
            EL = calParms.EL(ic) - 2.5/calParms.DS(ic) + counts/(65535/2.5*calParms.DS(ic));
            power = db2pow_perso(EL);
            data.(sprintf('chan_%.0f',ic))(:,ip)=power;
        end
        
        
        
    end
    
    fclose(fid);
    
    transceiver(data.nb_channel)=transceiver_cl();
    
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
        config_obj.EquivalentBeamAngle=10*log10(calParms.BP(ic));%10*log10(1.4*pi*(1-cosd(config_obj.BeamWidthAlongship))
        config_obj.Frequency=nanmean(data.freq(ic,:));
        config_obj.FrequencyMaximum=nanmax(data.freq(ic,:));
        config_obj.FrequencyMinimum=nanmin(data.freq(ic,:));
        config_obj.Gain=0;
        config_obj.SaCorrection=0;
        config_obj.TransducerName='';
        
        params_obj.Time=data.time;
        params_obj.Frequency(:)=data.freq(ic,:);
        params_obj.FrequencyEnd(:)=data.freq(ic,:);
        params_obj.FrequencyStart(:)=data.freq(ic,:);
        params_obj.PulseLength(:)=nanmean(data.pulse_length(ic,:));
        params_obj.SampleInterval(:)=1./nanmean(data.f_s(ic,:));
        params_obj.TransducerDepth(:)=0;
        params_obj.TransmitPower(:)=1;
        params_obj.Absorption(:)= sw_absorption(params_obj.Frequency(1)/1e3, (envdata.Salinity), (envdata.Temperature), (envdata.Depth),'fandg')/1e3;
        
        SvOffset = CalcSvOffset(data.freq(1,ic),params_obj.PulseLength(1));
        data_struct.power=db2pow_perso(pow2db_perso(data.(sprintf('chan_%.0f',ic)))-calParms.TVR(ic)-20*log10(calParms.VTX(ic)));
        data_struct.sv = pow2db_perso(data.(sprintf('chan_%.0f',ic)))-calParms.TVR(ic)-20*log10(calParms.VTX(ic)) + repmat(20*log10(range)+2*params_obj.Absorption(1)*range,1,nb_pings) - 10*log10(c*params_obj.PulseLength(1)/2)-config_obj.EquivalentBeamAngle+SvOffset;
        data_struct.sp = pow2db_perso(data.(sprintf('chan_%.0f',ic)))-calParms.TVR(ic)-20*log10(calParms.VTX(ic)) + repmat(40*log10(range)+2*params_obj.Absorption(1)*range,1,nb_pings);
        
        [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(data_struct,dir_data,{});
        
        
        ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
            'Nb_samples',length(range),...
            'Nb_pings',nb_pings,...
            'MemapName',curr_name);
        
        clear curr_data;
        
        main_path=whereisEcho();
        
        [~,~,algo_vec]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));
        if isempty(algo_vec)
            algo_vec=init_algos();
        else
            algo_vec=reset_range(algo_vec,range);
        end
        
        transceiver(ic)=transceiver_cl('Data',ac_data_temp,...
            'Range',range,...
            'Time',data.time,...
            'Algo',algo_vec,...
            'Mode','CW');
        transceiver(ic).Config=config_obj;
        transceiver(ic).Params=params_obj;
           
    end
    layers(i_cell)=layer_cl('Filename',{file_f},'Filetype','ASL','Transceivers',transceiver,'EnvData',envdata);
    
    
    
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


%The following functions have been provided by ASL

% Ver 1.1 October 31, 2016
% written by Dave Billenness
% ASL Environmental Sciences Inc.
% 1-6703 Rajpur Place, Victoria, B.C., V8M 1Z5, Canada
% T: +1 (250) 656-0177 ext. 126
% E: dbillenness@aslenv.com
% w: http://www.aslenv.com/
% For any suggestions, comments, questions or collaboration, please contact me.
% *************************

function T = computeTemperature(counts,Par)

Vin = 2.5 * (counts / 65535);
R = (Par.ka + Par.kb * Vin) / (Par.kc - Vin);
T = 1 / (Par.A + Par.B * (log(R)) + Par.C * (log(R)^3)) - 273;

end

function Tilt = computeTilt(N,a,b,c,d)

% X_a; X_b; X_c and X_d
Tilt = a + b*(N) + c*(N)^2 + d*(N)^3;

end

% A correction must be made to compensate for the effects of the
% finite response times of both the receiving and transmitting parts of the instrument. The
% magnitude of the correction will depend on the length of the transmitted pulse, and the response
% time (on both transmission and reception) of the instrument.
function SvOffset = CalcSvOffset(Frequency,PulseLength)

SvOffset = 0;

if(Frequency > 38) % 125,200,455,769 kHz
    if(PulseLength == 300)
        SvOffset = 1.1;
    elseif(PulseLength == 500)
        SvOffset = 0.8;
    elseif(PulseLength == 700)
        SvOffset = 0.5;
    elseif(PulseLength == 900)
        SvOffset = 0.3;
    elseif(PulseLength == 1000)
        SvOffset = 0.3;
    end
else % 38 kHz
    if(PulseLength == 500)
        SvOffset = 1.1;
    elseif(PulseLength == 1000)
        SvOffset = 0.7;
    end
end

end

