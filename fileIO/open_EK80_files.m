function open_EK80_files(main_figure,PathToFile,Filename,read_all)
curr_disp=getappdata(main_figure,'Curr_disp');

if ~isequal(Filename, 0)
    
    %s=warning('error','readEKRaw:Datagram');
    
    if read_all==0
        prompt={'First ping:',...
            'Last Ping:'};
        name='Pings to load';
        numlines=1;
        defaultanswer={'1','Inf'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answer)
            return
        end
        
        
        ping_start= str2double(answer{1});
        ping_end= str2double(answer{2});
    else
        ping_start=1;
        ping_end=Inf;
    end
    
    opening_file=msgbox(['Opening file ' Filename '. This box will close when finished...'],'Opening File');
    hlppos=get(opening_file,'position');
    set(opening_file,'position',[100 hlppos(2:4)])
      
    [header,data]=readEK80(PathToFile,Filename,'PingRange',[ping_start ping_end]);
    
    if ~isstruct(header)
        if exist('opening_file','var')
            close(opening_file);
        end
        return;
    end
    
    if iscell(Filename)
        if length(Filename)>1
            data=reorder_ping(data);
        end
    end
    data_ori=data;
    [data,mode]=match_filter_data(data);
    
    data=compute_PwSpSv(data);
    data_ori=compute_PwSpSv(data_ori);
    
    data=computesPhasesAngles(data);
    data_ori=computesPhasesAngles(data_ori);
    
    if isfield(data,'gps')
        gps_data=gps_data_cl('Lat',data.gps.lat,'Long',data.gps.lon,'Time',data.gps.time);
    else
        gps_data=gps_data_cl();
    end
    
    transceiver=transceiver_cl();
    
    freq=nan(1,header.transceivercount);
    
    
    for i =1:header.transceivercount
        
        sub_ac_data_temp=[...
            sub_ac_data_cl('Sp UnMatched',data_ori.pings(i).Sp)...
            sub_ac_data_cl('Sp',data.pings(i).Sp) ...
            sub_ac_data_cl('Sv',data.pings(i).Sv) ...
            sub_ac_data_cl('Power',data.pings(i).power)...
            sub_ac_data_cl('y',data.pings(i).y)...
            sub_ac_data_cl('AcrossPhi',data.pings(i).AcrossPhi) ...
            sub_ac_data_cl('AlongPhi',data.pings(i).AlongPhi) ...
            sub_ac_data_cl('AcrossAngle',data.pings(i).AcrossAngle) ...
            sub_ac_data_cl('AlongAngle',data.pings(i).AlongAngle)];
        
        if isfield(data,'gps')
            gps_data_ping=resample_gps_data(gps_data,data.pings(i).time);
        else
            gps_data_ping=gps_data_cl();
        end
        
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
        
        r=data.pings(i).range;
        
        algo_vec=init_algos(r);
        
              
        ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
            'Range',data.pings(i).range,...
            'Time',data.pings(i).time,...
            'Number',data.pings(i).number);
        
        
        Bottom=nan(1,size(data.pings(i).power,2));
        Bottom_idx=nan(1,size(data.pings(i).power,2));
        
        
        transceiver(i)=transceiver_cl('Data',ac_data_temp,...
            'Bottom',bottom_cl('Origin','None','Range',Bottom,'Sample_idx',Bottom_idx),...
            'Algo',algo_vec,...
            'GPSDataPing',gps_data_ping,...
            'Mode',mode{i},...
            'AttitudeNavPing',attitude);
        
        freq(i)=data.config(i).Frequency(1);
        
        transceiver(i).Params=params_cl();
        props=fieldnames(data.params(i));
        for iii=1:length(props)
            if isprop(transceiver(i).Params, (props{iii}))
                transceiver(i).Params.(props{iii})=data.params(i).(props{iii});
            end
        end
        
        
        transceiver(i).Params.Time=data.params(i).time;
        
        
        transceiver(i).Filters=[filter_cl filter_cl];
        for ii=1:2
            props=fieldnames(data.filter_coeff(i).stages(ii));
            for iii=1:length(props)
                if isprop(transceiver(i).Filters(ii), (props{iii}))
                    transceiver(i).Filters(ii).(props{iii})=data.filter_coeff(i).stages(ii).(props{iii});
                end
            end
        end
        
        
        props=fieldnames(data.config(i));
        for iii=1:length(props)
            if  isprop(transceiver(i).Config, (props{iii}))
                transceiver(i).Config.(props{iii})=data.config(i).(props{iii});
            end
        end
        %         [Bottom,Shadow_Bottom,Double_bottom_region,BS_bottom,idx_bottom]=detec_bottom_algo_v2(transceiver(i),'thr_bottom',-110,'idx_r_min',150);
        %
        %         transceiver(i).Bottom.Origin='Test';
        %         transceiver(i).Bottom.Sample_idx=Bottom;
        %         transceiver(i).Bottom.Range= nan(size(Bottom));
        %         transceiver(i).Bottom.Range(~isnan(Bottom))= transceiver(i).Data.Range(Bottom(~isnan(Bottom)));
        
        
    end
    
    layer=layer_cl('Filename',Filename,'Filetype','EK80','PathToFile',PathToFile,'Transceivers',transceiver,'GPSData',gps_data,'Frequencies',freq);
    
    props=fieldnames(data.env);
    
    for iii=1:length(props)
        if  isprop(layer.EnvData, (props{iii}))
            layer.EnvData.(props{iii})=data.env.(props{iii});
        end
    end
    %layer.EnvData=
    
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    
    curr_disp.Freq=layer.Frequencies(idx_freq);
    
    idx_type=find_type_idx(layer.Transceivers(idx_freq).Data,'Sv');
    curr_disp.Type=layer.Transceivers(idx_freq).Data.SubData(idx_type).Type;
    
    
    
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Curr_disp',curr_disp);
    if exist('opening_file','var')
        close(opening_file);
    end
    
    clear data transceiver
    update_display(main_figure,1);
    
end