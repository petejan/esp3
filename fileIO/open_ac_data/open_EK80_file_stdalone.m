function  layers=open_EK80_file_stdalone(Filename_cell,varargin)

p = inputParser;


if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m);
addParameter(p,'Frequencies',[]);
addParameter(p,'PingRange',[1 inf]);
addParameter(p,'FieldNames',{});

parse(p,Filename_cell,varargin{:});


dir_data=p.Results.PathToMemmap;
vec_freq_init=p.Results.Frequencies;
pings_range=p.Results.PingRange;

ping_end=pings_range(2);
ping_start=pings_range(1);

vec_freq_tot=[];
list_freq_str={};
ite=1;

if ~isequal(Filename_cell, 0)
    
    
    if ite==0
        nb_layers=1;
    else
        nb_layers=length(Filename_cell);
    end
    
    prev_ping_end=0;
    prev_ping_start=1;
    [~,file_currN,~]=fileparts(Filename_cell{1});
    
    opening_file=waitbar(1/nb_layers,sprintf('Opening file: %s ',file_currN),'Name','Opening files','WindowStyle','Modal');
    
    for uuu=1:nb_layers
        vec_freq_temp=[];
        
        if ite==1
            curr_Filename=Filename_cell{uuu};
            [~,fileN,~]=fileparts(curr_Filename);
        else
            curr_Filename=Filename_cell;
            [~,fileN,~]=fileparts(curr_Filename{1});
            
        end
        
        
        if ping_end-prev_ping_end<=ping_start-prev_ping_start+1
            break;
        end
        
        
        if isempty(vec_freq_init)
            [header_temp,data_temp]=readEK80(curr_Filename,'PingRange',[1 1]);
            
            for ki=1:header_temp.transceivercount
                vec_freq_temp=[vec_freq_temp data_temp.config(ki).Frequency];
                list_freq_str=[list_freq_str num2str(data_temp.config(ki).Frequency,'%.0f')];
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
            vec_freq=vec_freq_init;
        end
        
        if isempty(vec_freq)
            vec_freq=-1;
        end
        pings_range(1)=pings_range(1)-prev_ping_start+1;
        
        if pings_range(2)~=Inf
            pings_range(2)=pings_range(2)-prev_ping_end;
        end
        
        
        [header,data]=readEK80(curr_Filename,'PingRange',pings_range,'Frequencies',vec_freq);
        
        prev_ping_start=pings_range(1);
        prev_ping_end=data.pings(1).number(end);
        
       
        if ~isstruct(header)
            if exist('opening_file','var')
                close(opening_file);
            end
            return;
        end
        
        try
            waitbar(uuu/nb_layers,opening_file,['Opening file: ',fileN],'WindowStyle','Modal');
        catch
            opening_file=waitbar(uuu/nb_layers,['Opening file: ',fileN],'Name','Opening files','WindowStyle','Modal');
        end
        
        
        if length(curr_Filename)>1
            data=reorder_ping(data);
        end

        data_ori=data;
        [data,mode]=match_filter_data(data);
        
        
        data=compute_PwEK80(data);
        data_ori=compute_PwEK80(data_ori);
        
        data=computesPhasesAngles(data);
        data_ori=computesPhasesAngles(data_ori);
        
        idx_NMEA=find(cellfun(@(x) ~isempty(x),regexp(data.NMEA.string,'(SHR|HDT|GGA|GGL|VLW)')));
        
        [gps_data,attitude_full]=nmea_to_attitude_gps(data.NMEA.string,data.NMEA.time,idx_NMEA);
        
       
        
        
        freq=nan(1,header.transceivercount);
        
        
        for i =1:header.transceivercount
            
            
            curr_data.powerunmatched=single(data_ori.pings(i).power);
            curr_data.power=single(data.pings(i).power);
            curr_data.y_real=single(real(data.pings(i).y));
            curr_data.y_imag=single(imag(data.pings(i).y));
            curr_data.acrossangle=single(data.pings(i).AcrossAngle);
            curr_data.alongangle=single(data.pings(i).AlongAngle);
            
            
            fileID = unidrnd(2^64);
            while fileID==0
                fileID = unidrnd(2^64);
            end
            
           
            
            [sub_ac_data_temp,curr_name]=sub_ac_data_cl.sub_ac_data_from_struct(curr_data,dir_data,p.Results.FieldNames);
            
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',[double(data.pings(i).range(1)) double(data.pings(i).range(end))],...
                'Samples',[double(data.pings(i).samples(1)) double(data.pings(i).samples(end))],...
                'Time',double(data.pings(i).time),...
                'Number',[double(data.pings(i).number(1)) double(data.pings(i).number(end))],...
                'MemapName',curr_name);
            
            
            clear curr_data;
            
            
            gps_data_ping=gps_data.resample_gps_data(data.pings(i).time);
            
            attitude=attitude_full.resample_attitude_nav_data(data.pings(i).time);
            
            r=data.pings(i).range;
            
            algo_vec=init_algos(r);
            
            
            
            Bottom=nan(1,size(data.pings(i).power,2));
            Bottom_idx=nan(1,size(data.pings(i).power,2));
            
            
            transceiver(i)=transceiver_cl('Data',ac_data_temp,...
                'Algo',algo_vec,...
                'GPSDataPing',gps_data_ping,...
                'Mode',mode{i},...
                'AttitudeNavPing',attitude);
            transceiver(i).setBottom(bottom_cl('Origin','None','Range',Bottom,'Sample_idx',Bottom_idx));
            
            freq(i)=data.config(i).Frequency(1);
            
            transceiver(i).Params=params_cl();
            props=fieldnames(data.params(i));
            for iii=1:length(props)
                if isprop(transceiver(i).Params, (props{iii}))
                    transceiver(i).Params.(props{iii})=data.params(i).(props{iii});
                end
            end
            
            
            transceiver(i).Params.Time=data.params(i).time;
            
            props=fieldnames(data.env);
            envdata=env_data_cl();
            for iii=1:length(props)
                if  isprop(envdata, (props{iii}))
                    envdata.(props{iii})=data.env.(props{iii});
                end
            end
            
            
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
            
            transceiver(i).computeSpSv(envdata);
            %transceiver(i).computeSp_comp();
        end
        
        layers(uuu)=layer_cl('Filename',{curr_Filename},'Filetype','EK80','Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_full,'Frequencies',freq,'EnvData',envdata);
        
    end
    try
        close(opening_file);
    end
    
end

end