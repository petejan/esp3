
function  layers=open_EK60_file_stdalone(PathToFile,Filename_cell,varargin)

p = inputParser;


addRequired(p,'PathToFile',@(x) ischar(x)||iscell(x));
addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',PathToFile);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'PingRange',[1 inf]);
addParameter(p,'SampleRange',[1 inf]);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);

parse(p,PathToFile,Filename_cell,varargin{:});


dir_data=p.Results.PathToMemmap;
cal=p.Results.Calibration;
vec_freq_init=p.Results.Frequencies;
pings_range=p.Results.PingRange;
sample_range=p.Results.SampleRange;

vec_freq_tot=[];
list_freq_str={};

if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end

    prev_ping_end=0;
    prev_ping_start=1;
    
    for uu=1:length(Filename_cell)
        vec_freq_temp=[];
        Filename=Filename_cell{uu};
        if iscell(PathToFile)
            path=PathToFile{uu};
        else
            path=PathToFile;
        end
        
        if isempty(vec_freq_init)
            try
                [header_temp,data_temp, ~]=readEKRaw(fullfile(path,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0);
                AllowModeChange=false;
            catch err
                if (strcmp(err.identifier,'readEKRaw:ModeChange'))
                    [header_temp,data_temp, ~]=readEKRaw(fullfile(path,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0,'AllowModeChange',true);
                    AllowModeChange=true;
                else
                    disp(['Cannot open file ' Filename]);
                    continue;
                end
            end
            
            for ki=1:header_temp.transceivercount
                vec_freq_temp=[vec_freq_temp data_temp.config(ki).frequency];
                list_freq_str=[list_freq_str num2str(data_temp.config(ki).frequency,'%.0f')];
            end
            
            if header_temp.transceivercount>1
                if length(intersect(vec_freq_temp,vec_freq_tot))~=header_temp.transceivercount
                    vec_freq_tot=vec_freq_temp;
                    [select,val] = listdlg('ListString',list_freq_str,'SelectionMode','Multiple','Name','Choose Frequencies to load','PromptString','Choose Frequencies to load','InitialValue',1:length(vec_freq_tot));
                end
                if val==0||isempty(select)
                    continue;
                else
                    vec_freq=vec_freq_tot(select);
                end
            else
                vec_freq=[];
            end

        else
            AllowModeChange=false;
            vec_freq=vec_freq_init;
        end
        
        if isempty(vec_freq)
            vec_freq=-1;
        end
        
        
        try
            waitbar(uu/length(Filename_cell),opening_file,sprintf('Opening file: %s',Filename_cell{uu}), 'WindowStyle', 'modal');
        catch
            opening_file=waitbar(uu/length(Filename_cell),sprintf('Opening file: %s',Filename_cell{uu}),'Name','Opening files', 'WindowStyle', 'modal');
        end
        
        pings_range(1)=pings_range(1)-prev_ping_start+1;
        if pings_range(2)~=Inf
            pings_range(2)=pings_range(2)-prev_ping_end;
        end
        
        
        if pings_range(2)-prev_ping_end<=pings_range(1)-prev_ping_start+1
            break;
        end
        
        try
            [header,data, ~]=readEKRaw(fullfile(path,Filename),'MaxBadBytes',0,'PingRange',pings_range,'SampleRange',sample_range,'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',AllowModeChange);
        catch err2
            disp(err2.message);
            [header,data, ~]=readEKRaw(fullfile(path,Filename),'MaxBadBytes',0,'AllowModeChange',true,'PingRange',pings_range,'SampleRange',sample_range,'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',true);
            AllowModeChange=true;
        end
        
        if isnumeric(header)
            disp('Could not read file.')
            layers_temp(uu)=layer_cl();
            break;
        end
        
        if strcmp(header.soundername(1:4),'ES70') || strcmp(header.soundername(1:4),'ES60')
            for ki=1:header.transceivercount
                data.pings(ki).power=correctES60(data.pings(ki).power,p.Results.EsOffset);
            end
        end
        
        prev_ping_start=pings_range(1);
        prev_ping_end=data.pings(1).number(end);
        
        
        curr_gps=1;
        curr_dist=1;
        curr_att=1;
        curr_heading=1;
        

        
        idx_NMEA=find(cellfun(@(x) ~isempty(x),regexp(data.NMEA.string,'(SHR|HDT|GGA|GGL|VLW)')));

        for iiii=idx_NMEA'
            %for iiii=1:length(data.NMEA.string)
            curr_message=data.NMEA.string{iiii};
            curr_message(isspace(curr_message))=' ';
            [nmea,nmea_type]=parseNMEA(curr_message);
            try
                switch nmea_type
                    case 'gps'
                        if curr_gps==1
                            data.gps.type=nmea.type;
                        end
                        if ~isempty(nmea.lat) && ~isempty(nmea.lon)
                            if strcmp(nmea.type,data.gps.type)
                                data.gps.time(curr_gps) = data.NMEA.time(iiii);
                                %  set lat/lon signs and store values
                                if (nmea.lat_hem == 'S');
                                    data.gps.lat(curr_gps) = -nmea.lat;
                                else
                                    data.gps.lat(curr_gps) = nmea.lat;
                                end
                                if (nmea.lon_hem == 'W');
                                    data.gps.lon(curr_gps) = -nmea.lon;
                                else
                                    data.gps.lon(curr_gps) = nmea.lon;
                                end
                                curr_gps=curr_gps+1;
                            end
                        end
                        %             case 'speed'
                        %                 data.vspeed.time(curr_speed) = dgTime;
                        %                 data.vspeed.speed(curr_speed) = nmea.sog_knts;
                        %                 curr_speed = curr_speed + 1;
                    case 'dist'
                        data.dist.time(curr_dist) = data.NMEA.time(iiii);
                        data.dist.vlog(curr_dist) = nmea.total_cum_dist;
                        curr_dist=curr_dist+1;
                    case 'attitude'
                        data.attitude.time(curr_att) = data.NMEA.time(iiii);
                        data.attitude.heading(curr_att) = nmea.heading;
                        data.attitude.pitch(curr_att) = nmea.pitch;
                        data.attitude.roll(curr_att) = nmea.roll;
                        data.attitude.heave(curr_att) = nmea.heave;
                        curr_att=curr_att+1;
                    case 'heading'
                        data.heading.time(curr_heading) = data.NMEA.time(iiii);
                        data.heading.heading(curr_heading) = nmea.heading;
                        curr_heading=curr_heading+1;
                end
            catch
                fprintf('Invalid NMEA message: %s\n',curr_message);
            end
        end

        
        
        if  ~isstruct(header)
            if exist('opening_file','var')
                close(opening_file);
            end
            return;
        end
        
        
        if ~isempty(cal)
            for n=1:header.transceivercount
                idx_cal=find(data.pings(n).frequency(1)==cal.F);
                if ~isempty(idx_cal)
                    
                    tau = data.pings(n).pulselength(1);
                    idx = find(data.config(n).pulselengthtable == tau);
                    
                    if (~isempty(idx))
                        data.config(n).sacorrectiontable(idx)=cal.SACORRECT(idx_cal);
                        data.config(n).gaintable(idx)=cal.G0(idx_cal);
                    else
                        data.config(n).sacorrectiontable=cal.SACORRECT(idx_cal).*ones(size(calParms(n).pulselengthtable));
                        data.config(n).gaintable=cal.G0(idx_cal).*ones(size(calParms(n).pulselengthtable));
                    end
                end
            end
        end
        
        calParms = readEKRaw_GetCalParms(header,data);
                   
        Filename_bot=[Filename(1:end-4) '.bot'];
        if exist(fullfile(path,Filename_bot),'file')
            [~,temp, ~] = readEKBot(fullfile(path,Filename_bot), calParms,'Frequencies',vec_freq);
            
            
            if pings_range(2)==Inf
                Bottom_sim=double(temp.pings.bottomdepth(:,pings_range(1):end));
            else
                Bottom_sim=double(temp.pings.bottomdepth(:,pings_range(1):pings_range(2)));
            end
        else
            Bottom_sim=nan(header.transceivercount,size( data.pings(1).power,1));
        end
        
        c = [calParms.soundvelocity];
        t = [calParms.sampleinterval];
        
        sample_start=nan(header.transceivercount,1);
        sample_end=nan(header.transceivercount,1);
        
        for i =1:header.transceivercount
            sample_start(i)=sample_range(1);    
            if sample_range(2)==Inf
                sample_end(i) =size(data.pings(i).power,1)+sample_start(i)-1;
            else
                sample_end(i)=sample_range(2);
            end
        end
        

        dR = double(c .* t / 2)';

        Bottom_sim_idx=round(Bottom_sim./repmat(dR,1,size(Bottom_sim,2))-repmat(sample_start,1,size(Bottom_sim,2)))+1;
        Bottom_sim_idx(Bottom_sim_idx<=1)=nan;
        
        if isfield(data, 'gps')
            gps_data=gps_data_cl('Lat',data.gps.lat,'Long',data.gps.lon,'Time',data.gps.time,'NMEA',data.gps.type);
        else
            gps_data=gps_data_cl();
        end
        
        if isfield(data, 'attitude')
            attitude_full=attitude_nav_cl('Heading',data.attitude.heading,'Pitch',data.attitude.pitch,'Roll',data.attitude.roll,'Heave',data.attitude.heave,'Time',data.attitude.time);
        elseif isfield(data,'heading')
            attitude_full=attitude_nav_cl('Heading',data.heading.heading,'Time',data.heading.time);
        else
            attitude_full=attitude_nav_cl();
        end
        
  
        freq=nan(1,header.transceivercount);
        
        fileID = unidrnd(2^64);
        while fileID==0
            fileID = unidrnd(2^64);
        end
        
        for i =1:header.transceivercount
            
            curr_data.power=single(10.^(double(data.pings(i).power/10)));
            curr_data.acrossphi=single(data.pings(i).athwartship_e);
            curr_data.alongphi=single(data.pings(i).alongship_e);
            
            [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(curr_data,dir_data,p.Results.FieldNames);
                        
 
            samples=double((sample_start(i):sample_end(i)))';
            range=double(samples-1)*dR(i);
            
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',range,...
                'Samples',samples,...
                'Time',double(data.pings(i).time),...
                'Number',double(data.pings(i).number),...
                'MemapName',curr_name);
            
            clear curr_data;

            gps_data_ping=gps_data.resample_gps_data(data.pings(i).time);
            attitude=attitude_full.resample_attitude_nav_data(data.pings(i).time);
            
            algo_vec=init_algos(range);
            
            
            
            if length(Bottom_sim(i,:))~=size(data.pings(i).power,2);
                Bottom=nan(1,size(data.pings(i).power,2));
                Bottom_idx=nan(1,size(data.pings(i).power,2));
                bot=bottom_cl('Origin','None','Range',Bottom,'Sample_idx',Bottom_idx);
            else
                bot= bottom_cl('Origin','Simrad','Range',Bottom_sim(i,:),'Sample_idx',Bottom_sim_idx(i,:));
            end
            
            transceiver(i)=transceiver_cl('Data',ac_data_temp,...
                'Algo',algo_vec,...
                'GPSDataPing',gps_data_ping,...
                'Mode','CW',...
                'AttitudeNavPing',attitude);
            transceiver(i).setBottom(bot);
            
            
            freq(i)=data.config(i).frequency(1);
            
            [transceiver(i).Config,transceiver(i).Params]=config_from_ek60(data.config(i),calParms(i));
            envdata=env_data_cl('SoundSpeed',calParms(i).soundvelocity);
            
            transceiver(i).computeAngles();
            transceiver(i).computeSpSv(envdata);
            
        end
        
        layers_temp(uu)=layer_cl('ID_num',fileID,'Filename',{Filename},'Filetype','EK60','PathToFile',path,'Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_full,'Frequencies',freq,'EnvData',envdata);
        
        %layers_temp(uu).create_motion_comp_subdata(3);
        
    end
    
    if exist('layers_temp','var')
        layers=layers_temp;
    else
        layers=[];
        return;
    end
    if exist('opening_file','var')
        close(opening_file);
    end
    clear data transceiver
    
    
end