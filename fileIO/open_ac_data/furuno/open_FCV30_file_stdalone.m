function  layers=open_FCV30_file_stdalone(file_lst,varargin)

p = inputParser;

[def_path_m,~,~]=fileparts(file_lst);

addRequired(p,'file_lst',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'FieldNames',{});
addParameter(p,'GPSOnly',0);
addParameter(p,'load_bar_comp',[]);
addParameter(p,'file_idx',[]);

parse(p,file_lst,varargin{:});

[main_path,~,~]=fileparts(file_lst);
load_bar_comp=p.Results.load_bar_comp;

list_files=importdata(file_lst);
[folder_lst,~,~]=fileparts(file_lst);
filename_dat_tot=cell(1,length(list_files));
filename_ini=cell(1,length(list_files));

for i=1:length(list_files)
    str_temp=strsplit(list_files{i},',');
    filename_dat_tot{i}=fullfile(main_path,str_temp{1});
    filename_ini{i}=fullfile(main_path,str_temp{2});
end

[ini_config_files,~,id_config_unique]=unique(filename_ini);
[~,fname_ini_mat,~]=cellfun(@fileparts,ini_config_files,'UniformOutput',0);
file_mat_ini=cellfun(@(x) fullfile(folder_lst,'echoanalysisfiles',[x '.mat']),fname_ini_mat,'UniformOutput',0);

id_config=(1:length(ini_config_files));

if ~isempty(p.Results.file_idx)
    id_config=(p.Results.file_idx);
end


nb_config=length(id_config);

layers(nb_config)=layer_cl();
ilay=0;

for iconfig=id_config
    ilay=ilay+1;
    str_disp=sprintf('Opening File %d/%d\n',ilay,length(id_config));
    if ~isempty(load_bar_comp)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',length(id_config),'Value',ilay-1);
        load_bar_comp.status_bar.setText(str_disp);
        pause(0.1);
    else
        disp(str_disp)
    end
    
    file_exist=0;
    if exist(file_mat_ini{iconfig},'file')        
        if ~isempty(load_bar_comp)
            load_bar_comp.status_bar.setText(sprintf('Reloading %s',file_mat_ini{iconfig}));
        end
        try
            load(file_mat_ini{iconfig});
            file_exist=1;
        catch
            delete(file_mat_ini{iconfig});
             file_exist=0;
        end
    end
    curr_fold=fileparts(file_mat_ini{iconfig});
    if exist(curr_fold,'dir')==0
        mkdir(curr_fold);
    end
    
    if file_exist==0
        filename_dat=filename_dat_tot(id_config_unique==iconfig);
        nb_pings=length(filename_dat);
        
        
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_pings, 'Value',0);
        end
        
        echo.Data=nan(5*1e5,nb_pings);
        
        for ip=1:nb_pings
            
            if ~isempty(load_bar_comp)
                set(load_bar_comp.progress_bar, 'Value',ip);
                load_bar_comp.status_bar.setText(sprintf('Opening File %s',filename_dat{ip}));
            end
            
            fid=fopen(filename_dat{ip},'r','n');
            
            header.Model=fread(fid,8,'*char')';
            header.Fmt_ver=fread(fid,1,'ushort')';
            header.Date=nan(1,6);
            header.Date(1)=fread(fid,1,'short')';
            header.Date(2)=fread(fid,1,'short')';
            header.Date(3)=fread(fid,1,'short')';
            header.Date(4)=fread(fid,1,'short')';
            header.Date(5)=fread(fid,1,'short')';
            header.Date(6)=fread(fid,1,'short')';
            header.Remarks=char(fread(fid,287,'short')');
            
            params.Time(ip)=datenum(header.Date);
            params.Mode(ip)=fread(fid,1,'short');
            params.TotalBeamNumber(ip)=fread(fid,1,'short');
            params.Beam_Id(ip,:)=fread(fid,5,'short');
            params.Range(ip)=fread(fid,1,'short');
            params.Frequency(ip)=fread(fid,1,'short')*10;
            params.BearingAngle(ip,:)=fread(fid,6,'short')*1e-1;
            params.TiltAngle(ip,:)=fread(fid,6,'short')*1e-1;
            params.TXfrequency(ip,:)=fread(fid,6,'short')*10;
            params.TXpower(ip,:)=fread(fid,6,'short');
            params.ChirpWidth(ip,:)=fread(fid,6,'short')*10;
            params.TXcycle(ip)=fread(fid,1,'short')*1e-3;
            params.TXPulseWidth(ip,:)=fread(fid,6,'short')*1e-6;
            params.EnvelopeEdgeWidth(ip,:)=fread(fid,6,'short')*1e-6;
            params.Remarks1{ip}=char(fread(fid,357,'short')');
            params.TXroll(ip)=fread(fid,1,'short')*1e-1;
            params.TXpitch(ip)=fread(fid,1,'short')*1e-1;
            params.RXroll(ip)=fread(fid,1,'short')*1e-1;
            params.RXpitch(ip)=fread(fid,1,'short')*1e-1;
            params.Remarks2{ip}=char(fread(fid,313,'short')');
            
            
            NMEA.UTC(ip)=fread(fid,1,'ulong')/(24*60*60)+datenum('1980/01/06 00:00:00','yyyy/mm/dd HH:MM:SS');
            NMEA.Latitude(ip)=fread(fid,1,'long')*1e-4/60;
            NMEA.Longitude(ip)=fread(fid,1,'long')*1e-4/60;
            NMEA.Status(ip)=fread(fid,1,'short');
            NMEA.speed(ip)=fread(fid,1,'short')*1e-2;%knots
            NMEA.Heading(ip)=fread(fid,1,'short')*1e-1;
            NMEA.VesselCourse(ip)=fread(fid,1,'short')*1e-1;
            NMEA.WaterTemperature(ip)=fread(fid,1,'short')*1e-2;%deg C
            NMEA.Remarks{ip}=char(fread(fid,117,'short')');
            
            fread(fid,768,'int8');
            
            att.DataNumber(ip)=fread(fid,1,'ushort')-1;
            att.Remarks1{ip}=fread(fid,2,'*char')';
            fread(fid,48*att.DataNumber(ip),'int8');
            %         if~isfield(att,'Data')
            %             att.Data(:,ip)=temp;
            %         else
            %             if att.DataNumber(ip)>att.DataNumber(ip-1)
            %               temp_2=att.Data(:,ip);
            %               att.Data=nan(att.DataNumber(ip),nb_pings);
            %               att.Data(1:size(temp_2,1),1:ip-1)=temp_2;
            %             end
            %             att.Data(:,ip)=temp(1:size(att.Data,1));
            %         end
            att.StatuspR(ip)=fread(fid,1,'short');
            att.Roll(ip)=fread(fid,1,'short')*1e-1;
            att.Pitch(ip)=fread(fid,1,'short')*1e-1;
            att.StatusH(ip)=fread(fid,1,'short');
            att.Heave(ip)=fread(fid,1,'short')*1e-2;
            att.Remarks2{ip}=char(fread(fid,19,'short')');
            
            echo.DataSize(ip)=fread(fid,1,'ulong')/4;
            data_temp=fread(fid,echo.DataSize(ip),'long');
            echo.Data(1:length(data_temp),ip)=data_temp;
            fclose(fid);
            
        end
        
        echo.Data(nanmax(echo.DataSize)+1:end,:)=[];
        
        echo.comp_sig_1=echo.Data(1:8:end,:)+1j*echo.Data(2:8:end,:);
        echo.comp_sig_2=echo.Data(3:8:end,:)+1j*echo.Data(4:8:end,:);
        echo.comp_sig_3=echo.Data(5:8:end,:)+1j*echo.Data(6:8:end,:);
        echo.comp_sig_4=echo.Data(7:8:end,:)+1j*echo.Data(8:8:end,:);
        
        
        save(file_mat_ini{iconfig},'echo','att','NMEA','params','header','-v7.3')
        
    end
    
    
    [nb_samples,nb_pings]=size(echo.comp_sig_1);
    config_current=config_cl();
    
    trans_obj=transceiver_cl();
    params_current=params_cl(nb_pings);
    
    G=20;
    SL=30;
    ME=0;
    c=1500;
    alpha=9/1000;
    L0=0.152;
    R=(1:nb_samples)'/nb_samples*params.Range;
    T=2*R/c;
    
    k=2*pi*params.Frequency/c;
    a=0.19;
    psi=5.78./(k*a).^2;
    
    config_current.TransceiverName='FCV30';
    config_current.Gain=G/2;
    config_current.PulseLength=params.TXPulseWidth(1);
    config_current.SaCorrection=0;
    config_current.Frequency=38000;
    config_current.FrequencyMaximum=38000;
    config_current.FrequencyMinimum=38000;
    config_current.EquivalentBeamAngle=10*log10(psi(1));
    config_current.AngleSensitivityAlongship=1/L0;
    config_current.AngleSensitivityAthwartship=1/L0;
    
    params_current.Time=NMEA.UTC;
    params_current.BandWidth(:)=params.ChirpWidth(1);
    params_current.ChannelMode=params.Mode;
    params_current.Frequency(:)=params.Frequency;
    params_current.FrequencyEnd(:)=params.Frequency+params.ChirpWidth(1)/2;
    params_current.FrequencyStart(:)=params.Frequency-params.ChirpWidth(1)/2;
    params_current.PulseLength(:)=params.TXPulseWidth(1);
    params_current.SampleInterval(:)=nanmean(diff(T,1,1),1);
    params_current.Absorption(:)=alpha;
    params_current.TransmitPower(:)=2000;
    env_data=env_data_cl();
    env_data.SoundSpeed=c;
    
    gps_data=gps_data_cl('Time',NMEA.UTC,'Lat',NMEA.Latitude,'Long',NMEA.Longitude);
    att_data=attitude_nav_cl('Time',NMEA.UTC,'Heading',NMEA.VesselCourse,'Pitch',att.Pitch,'Pitch',att.Roll,'Heave',att.Heave);
    
    
    SigIn=4*sqrt((real(echo.comp_sig_1)+real(echo.comp_sig_2)).^2+(imag(echo.comp_sig_1)+imag(echo.comp_sig_2)).^2)/2^32/sqrt(2);
    
    EL=20*log10(SigIn);
    
    PowerdB=EL-(SL+ME);
    
    echo.power=db2pow_perso(PowerdB);
    
    
    echo.alongphi=angle(echo.comp_sig_1.*conj(echo.comp_sig_2));
    echo.acrossphi=angle(echo.comp_sig_3.*conj(echo.comp_sig_4));
    
    echo.alongangle=180/pi*asin(bsxfun(@rdivide,c*echo.alongphi,(2*pi*params.Frequency).*(L0*cosd(att.Pitch))));
    echo.acrossangle=-180/pi*asin(bsxfun(@rdivide,c*echo.acrossphi,(2*pi*params.Frequency).*(L0*cosd(att.Roll))));
    
    %CorAng=pi/180*sqrt(echo.AlongAngle.^2+echo.AcrossAngle.^2);
    
    
    [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(echo,p.Results.PathToMemmap,{'power','acrossangle','alongangle'});
    clear echo att NMEA params header;
    trans_obj.Config=config_current;
    trans_obj.Params=params_current;
    R=R(:,1);
    trans_obj.Data=ac_data_cl('SubData',sub_ac_data_temp,...
        'Nb_samples',length(R),...
        'Nb_pings',length(params_current.Time),...
        'MemapName',curr_name);
    
    trans_obj.set_transceiver_range(R);
    trans_obj.set_transceiver_time(params_current.Time);
    trans_obj.computeSpSv_v2(env_data);

    gps_data_ping=gps_data;
    attitude=att_data;
    
    [~,~,algo_vec,~]=load_config_from_xml_v2(0,0,1);
       
    algo_vec_init=init_algos();
    
    algo_vec_init=reset_range(algo_vec_init,trans_obj.get_transceiver_range());
    algo_vec=reset_range(algo_vec,trans_obj.get_transceiver_range());
    trans_obj.GPSDataPing=gps_data_ping;
    trans_obj.AttitudeNavPing=attitude;
    trans_obj.Algo=algo_vec; trans_obj.add_algo(algo_vec_init);
    
    layers(ilay)=layer_cl('ChannelID',{'FCV30'},'Filename',file_mat_ini(iconfig),'Filetype','FCV30','Transceivers',trans_obj,'GPSData',gps_data,'AttitudeNav',attitude,'EnvData',env_data);
    
    
end



