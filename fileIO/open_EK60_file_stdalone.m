
function  layers=open_EK60_file_stdalone(main_figure,PathToFile,Filename_cell,vec_freq,ping_start,ping_end)

layers=getappdata(main_figure,'Layers');

matfiles_list=layers.list_matfiles();

if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    opening_file=msgbox(['Opening file ' Filename_cell '. This box will close when finished...'],'Opening File');
    hlppos=get(opening_file,'position');
    set(opening_file,'position',[100 hlppos(2:4)])
    
    prev_ping_end=0;
    prev_ping_start=1;
    
    for uu=1:length(Filename_cell)
        
        Filename=Filename_cell{uu};
        
        %s=warning('error','readEKRaw:Datagram');
        if isempty(vec_freq)
            vec_freq=-1;
        end
        
        if ping_end-prev_ping_end<=ping_start-prev_ping_start+1
            break;
        end
        
        try
            [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'PingRange',[ping_start-prev_ping_start+1 ping_end-prev_ping_end],'GPS',0,'RawNMEA','True','Frequencies',vec_freq);
        catch err2
            [header,data, ~]=readEKRaw([PathToFile Filename],'MaxBadBytes',0,'AllowModeChange',true,'PingRange',[ping_start-prev_ping_start+1 ping_end-prev_ping_end],'GPS',0,'RawNMEA','True','Frequencies',vec_freq);
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
        
        gps_data=gps_data_cl('Lat',data.gps.lat,'Long',data.gps.lon,'Time',data.gps.time,'NMEA',data.gps.type);
        transceiver=transceiver_cl();
        
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
            %
             
            if iscell(Filename)
                name_mat=Filename{1}(1:end-4);
            else
                name_mat=Filename(1:end-4);
            end
            
             MatFileNames{i}=fullfile([tempname '_echo_analysis.mat']);          
             save(MatFileNames{i},'-struct','curr_data','-v7.3');

            
            sub_ac_data_temp=[];
            ff=fields(curr_data);
            for uuu=1:length(ff)
                sub_ac_data_temp=[sub_ac_data_temp sub_ac_data_cl(ff{uuu},[nanmin(nanmin(curr_data.(ff{uuu}))) nanmax(nanmax(curr_data.(ff{uuu})))])];
            end
            
            clear curr_data;
            
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
            
            curr_matfile=matfile(MatFileNames{i},'writable',true);
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',double(data.pings(i).range),...
                'Time',double(data.pings(i).time),...
                'Number',double(data.pings(i).number),...
                'MatfileData',curr_matfile);
            
            
            
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
                'AttitudeNavPing',attitude,...
                'MatFileName',MatFileNames{i});
            
            
            
            freq(i)=data.config(i).frequency(1);
            
            [transceiver(i).Config,transceiver(i).Params]=config_from_ek60(data.config(i),calParms(i));
        end
        
        layers_temp(uu)=layer_cl('ID_num',fileID,'Filename',Filename,'Filetype','EK60','PathToFile',PathToFile,'Transceivers',transceiver,'GPSData',gps_data,'Frequencies',freq);
        
    end
    
    layers=layers_temp;
    if exist('opening_file','var')
        close(opening_file);
    end
    clear data transceiver
    

end