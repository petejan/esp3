
function  layer=open_EK60_file_stdalone(PathToFile,Filename_cell,read_all,vec_freq,ping_start,ping_end)

if ~isequal(Filename_cell, 0)

    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    opening_file=msgbox(['Opening file ' Filename_cell '. This box will close when finished...'],'Opening File');
        hlppos=get(opening_file,'position');
        set(opening_file,'position',[100 hlppos(2:4)])
    
    for uu=1:length(Filename_cell)
        
        Filename=Filename_cell{uu};
        
        %s=warning('error','readEKRaw:Datagram');
        
        if isempty(vec_freq)
            vec_freq=-1;
        end
        try
            [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'PingRange',[ping_start ping_end],'GPS', 2,'GPSSource','GPGGA','RawNMEA','True','Frequencies',vec_freq);
        catch err2
            [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'AllowModeChange',true,'PingRange',[ping_start ping_end],'GPS', 2,'GPSSource','GPGGA','RawNMEA','True','Frequencies',vec_freq);
        end
               
        %     curr_gps=1;
        curr_dist=1;
        curr_att=1;
        curr_heading=1;
        
        
        for iiii=1:length(data.NMEA.string)
            [nmea,nmea_type]=parseNMEA(data.NMEA.string{iiii});
            switch nmea_type
                %             case 'gps'
                %                 data.gps.time(curr_gps) = dgTime;
                %                 %data.gps.time_gps(curr_gps) = nmea.time;
                %                 %  set lat/lon signs and store values
                %                 if (nmea.lat_hem == 'S');
                %                     data.gps.lat(curr_gps) = -nmea.lat;
                %                 else
                %                     data.gps.lat(curr_gps) = nmea.lat;
                %                 end
                %                 if (nmea.lon_hem == 'W');
                %                     data.gps.lon(curr_gps) = -nmea.lon;
                %                 else
                %                     data.gps.lon(curr_gps) = nmea.lon;
                %                 end
                %                 curr_gps=curr_gps+1;
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
        
        if isempty(data.gps.lon)
            try
                [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'PingRange',[ping_start ping_end],'GPS', 2,'GPSSource','GPGLL','Frequencies',vec_freq);
            catch err2
                [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'AllowModeChange',true,'PingRange',[ping_start ping_end],'GPS', 2,'GPSSource','GPGLL','Frequencies',vec_freq);
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
        %     data = readEKRaw_Power2Sp(data, calParms,'Double',true,'KeepPower',true);
        %     data = readEKRaw_Power2Sv(data, calParms,'Double',true,'KeepPower',true);
        
        
        Filename_bot=[Filename(1:end-4) '.bot'];
        if exist([PathToFile Filename_bot],'file')
            [~,temp, ~] = readEKBot([PathToFile Filename_bot], calParms,'Frequencies',vec_freq);
            if ping_end==Inf
                Bottom_sim=double(temp.pings.bottomdepth(:,ping_start:end));
            else
                Bottom_sim=double(temp.pings.bottomdepth(:,ping_start:ping_end));
            end
        else
            Bottom_sim=nan(header.transceivercount,size(power,1));
        end
        Bottom_sim_idx=round(Bottom_sim/dR-(double((data.pings(n).samplerange(1)-1))));
        
        gps_data=gps_data_cl('Lat',data.gps.lat,'Long',data.gps.lon,'Time',data.gps.time,'NMEA','GPGGA');
        transceiver=transceiver_cl();
        
        freq=nan(1,header.transceivercount);
        
        
        for i =1:header.transceivercount
            
            sub_ac_data_temp=[sub_ac_data_cl('Power',10.^(double(data.pings(i).power/10)))...
                sub_ac_data_cl('Sp',double(data.pings(i).Sp)) ...
                sub_ac_data_cl('Sv',double(data.pings(i).Sv)) ...
                sub_ac_data_cl('AcrossPhi',double(data.pings(i).athwartship_e)) ...
                sub_ac_data_cl('AlongPhi',double(data.pings(i).alongship_e)) ...
                sub_ac_data_cl('AcrossAngle',double(data.pings(i).athwartship)) ...
                sub_ac_data_cl('AlongAngle',double(data.pings(i).alongship))];
            
            r=data.pings(i).range;
            gps_data_ping=resample_gps_data(gps_data,data.pings(i).time);
            
            
            if isfield(data, 'attitude')
                [heading_pings,~]=resample_data(data.attitude.heading,data.attitude.time,data.pings(i).time);
                [pitch_pings,~]=resample_data(data.attitude.pitch,data.attitude.time,data.pings(i).time);
                [roll_pings,~]=resample_data(data.attitude.roll,data.attitude.time,data.pings(i).time);
                [heave_pings,~]=resample_data(data.attitude.heave,data.attitude.time,data.pings(i).time);
                attitude=attitude_nav_cl('Heading',heading_pings,'Pitch',pitch_pings,'Roll',roll_pings,'Heave',heave_pings,'Time',data.pings(i).time);
            elseif isfield(data,'heading')
                [heading_pings,~]=resample_data(data.heading.heading,data.heading.time,data.pings(i).time);
                attitude=attitude_nav_cl('Heading',heading_pings,'Time',data.pings(i).time);
            else
                attitude=attitude_nav_cl();
            end
            
            
            algo_vec=init_algos(r);
            
            
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',double(data.pings(i).range),...
                'Time',double(data.pings(i).time),...
                'Number',double(data.pings(i).number));
            
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
        
        layer_temp(uu)=layer_cl('Filename',Filename,'Filetype','EK60','PathToFile',PathToFile,'Transceivers',transceiver,'GPSData',gps_data,'Frequencies',freq);
        
    end
    if exist('opening_file','var')
        close(opening_file);
    end
    layer=layer_temp(1);
    
    for kk=1:length(layer_temp)-1
        if layer.Transceivers(1).Data.Time(end)<=layer_temp(kk+1).Transceivers(1).Data.Time(end)
            layer=concatenate_Layer(layer,layer_temp(kk+1));
        else
            layer=concatenate_Layer(layer_temp(kk+1),layer);
        end
    end

end