
function  layers=open_EK60_file_stdalone(cal,dir_data,PathToFile,Filename_cell,vec_freq_init,ping_start,ping_end)

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
        
        if isempty(vec_freq_init)
            try
                [header_temp,data_temp, ~]=readEKRaw(fullfile(PathToFile,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0);
                AllowModeChange=false;
            catch err
                if (strcmp(err.identifier,'readEKRaw:ModeChange'))
                    [header_temp,data_temp, ~]=readEKRaw(fullfile(PathToFile,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0,'AllowModeChange',true);
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
        
        
        
        if ping_end-prev_ping_end<=ping_start-prev_ping_start+1
            break;
        end
        
        try
            [header,data, ~]=readEKRaw(fullfile(PathToFile,Filename),'MaxBadBytes',0,'PingRange',[ping_start-prev_ping_start+1 ping_end-prev_ping_end],'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',AllowModeChange);
        catch err2
            disp(err2.message);
            [header,data, ~]=readEKRaw(fullfile(PathToFile,Filename),'MaxBadBytes',0,'AllowModeChange',true,'PingRange',[ping_start-prev_ping_start+1 ping_end-prev_ping_end],'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',true);
            AllowModeChange=true;
        end
        
        if isnumeric(header)
            disp('Could not read file.')
            layers_temp(uu)=layer_cl();
            break;
        end
        
        if strcmp(header.soundername(1:4),'ES70') || strcmp(header.soundername(1:4),'ES60')
            for ki=1:header.transceivercount
                data.pings(ki).power=correctES60(data.pings(ki).power,[]);
            end
        end
        
        prev_ping_start=ping_start;
        prev_ping_end=data.pings(1).number(end);
        
        
        curr_gps=1;
        curr_dist=1;
        curr_att=1;
        curr_heading=1;
        
        
        for iiii=1:length(data.NMEA.string)
            [nmea,nmea_type]=parseNMEA(data.NMEA.string{iiii});
            switch nmea_type
                case 'gps'
                    if curr_gps==1
                        data.gps.type=nmea.type;
                    end
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
        data = readEKRaw_ConvertAngles(data,calParms,'KeepElecAngles',true);
        
        for n=1:header.transceivercount
            f = calParms(n).frequency;
            c = calParms(n).soundvelocity;
            t = calParms(n).sampleinterval;
            alpha = double(calParms(n).absorptioncoefficient);
            G = calParms(n).gain;
            phi = calParms(n).equivalentbeamangle;
            pt = calParms(n).transmitpower;
            tau = calParms(n).pulselength;
            idx = find(calParms(n).pulselengthtable == tau);
            
            if (~isempty(idx))
                Sac = calParms(n).sacorrectiontable(idx);
            else
                warning('readEKRaw:ParameterError', ...
                    'Sa correction table empty - Sa correction not applied.');
                Sac = 0;
            end
            dR = double(c * t / 2);
            pSize = size(data.pings(n).power);
            %  create range vector (in m)
            data.pings(n).range = double(((0:pSize(1) - 1) + ...
                double(data.pings(n).samplerange(1)) - 1) * dR)';
            
            power=double(10.^(data.pings(n).power/10));
            [data.pings(n).Sp,data.pings(n).Sv]=convert_power(power,double(data.pings(n).range),double(c),double(alpha),double(tau),double(pt),double(c/f),double(G),double(phi),double(Sac));
        end
        
        Filename_bot=[Filename(1:end-4) '.bot'];
        if exist(fullfile(PathToFile,Filename_bot),'file')
            [~,temp, ~] = readEKBot(fullfile(PathToFile,Filename_bot), calParms,'Frequencies',vec_freq);
            
            ping_end_bot=nanmin(size(temp.pings.bottomdepth,2),ping_end);
            
            if ping_end==Inf
                Bottom_sim=double(temp.pings.bottomdepth(:,ping_start:end));
            else
                Bottom_sim=double(temp.pings.bottomdepth(:,ping_start:ping_end));
            end
        else
            Bottom_sim=nan(header.transceivercount,size(power,1));
        end
        Bottom_sim_idx=round(Bottom_sim/dR-(double((data.pings(n).samplerange(1)-1))));
        
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
            curr_data.sp=single(data.pings(i).Sp);
            curr_data.sv=single(data.pings(i).Sv);
            curr_data.acrossphi=single(data.pings(i).athwartship_e);
            curr_data.alongphi=single(data.pings(i).alongship_e);
            curr_data.acrossangle=single(data.pings(i).athwartship);
            curr_data.alongangle=single(data.pings(i).alongship);
            
            
            %                         ff=fields(curr_data);
            %                         tic
            %                         for uuu=1:length(ff)
            %                             MatFileNames=fullfile([tempname '_echo_analysis.mat']);
            %                             data_temp=curr_data.(ff{uu});
            %                             save(MatFileNames,'data_temp','-v7.3');
            %                             curr_matfile=matfile(MatFileNames,'writable',true);
            %                         end
            %                         toc
            
            
            [~,curr_filename,~]=fileparts(tempname);
            curr_name=fullfile(dir_data,curr_filename);
            
            ff=fields(curr_data);
            sub_ac_data_temp=[];
            
            for uuu=1:length(ff)
                sub_ac_data_temp=[sub_ac_data_temp sub_ac_data_cl(ff{uuu},curr_name,curr_data.(ff{uuu}))];
            end
            
            
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',double(data.pings(i).range),...
                'Time',double(data.pings(i).time),...
                'Number',double(data.pings(i).number),...
                'MemapName',curr_name);
            
            clear curr_data;
            
            r=data.pings(i).range;
            gps_data_ping=gps_data.resample_gps_data(data.pings(i).time);
            attitude=attitude_full.resample_attitude_nav_data(data.pings(i).time);
            
            algo_vec=init_algos(r);
            
            
            
            if length(Bottom_sim(i,:))~=size(data.pings(i).power,2);
                Bottom=nan(1,size(data.pings(i).power,2));
                Bottom_idx=nan(1,size(data.pings(i).power,2));
                bot=bottom_cl('Origin','None','Range',Bottom,'Sample_idx',Bottom_idx);
            else
                bot= bottom_cl('Origin','Simrad','Range',Bottom_sim(i,:),'Sample_idx',Bottom_sim_idx(i,:));
            end
            
            transceiver(i)=transceiver_cl('Data',ac_data_temp,...
                'Bottom',bot,...
                'Algo',algo_vec,...
                'GPSDataPing',gps_data_ping,...
                'Mode','CW',...
                'AttitudeNavPing',attitude);
            
            
            
            freq(i)=data.config(i).frequency(1);
            
            [transceiver(i).Config,transceiver(i).Params]=config_from_ek60(data.config(i),calParms(i));
        end
        
        layers_temp(uu)=layer_cl('ID_num',fileID,'Filename',Filename,'Filetype','EK60','PathToFile',PathToFile,'Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_full,'Frequencies',freq);
        
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