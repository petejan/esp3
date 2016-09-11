
function  layers=open_EK_file_stdalone(Filename_cell,varargin)

p = inputParser;

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

[def_path_m,~,~]=fileparts(Filename_cell{1});

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'PingRange',[1 inf]);
addParameter(p,'SampleRange',[1 inf]);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);
addParameter(p,'GPSOnly',0);
addParameter(p,'LoadEKbot',0);

parse(p,Filename_cell,varargin{:});

cal=p.Results.Calibration;
vec_freq_init=p.Results.Frequencies;
pings_range=p.Results.PingRange;
sample_range=p.Results.SampleRange;

vec_freq_tot=[];


if ~isequal(Filename_cell, 0)
    
    prev_ping_end=0;
    prev_ping_start=1;

    layers(length(Filename_cell))=layer_cl();
    for uu=1:length(Filename_cell)
        
        Filename=Filename_cell{uu};
        [path_f,fileN,~]=fileparts(Filename);
        fprintf('(%.0f/%.0f) Opening file: %s\n',uu,length(Filename_cell),fileN);
        
        if isempty(vec_freq_init)

            ftype=get_ftype(Filename);
            
            switch ftype
                case 'EK80'
                    [~,config]=read_EK80_config(Filename);
                    nb_trans_tot=length(config);
                    
                    frequency=nan(1,nb_trans_tot);
                    
                    for uif=1:length(frequency)
                        frequency(uif)=config(uif).Frequency;
                    end
                    
                case 'EK60'
                    fid=fopen(Filename,'r');
                    [~, frequency] = readEKRaw_ReadHeader(fid);
                    fclose(fid);
            end
            
            if isempty(frequency)
                disp(['Cannot open file ' Filename]);
                continue;
            end
            transceivercount=length(frequency);
            vec_freq_temp=nan(1,transceivercount);
            list_freq_str=cell(1,transceivercount);
            for ki=1:transceivercount
                vec_freq_temp(ki)=frequency(ki);
                list_freq_str{ki}=num2str(frequency(ki),'%.0f');
            end
            
            if p.Results.GPSOnly==0
                if transceivercount>1
                    if length(intersect(vec_freq_temp,vec_freq_tot))~=transceivercount
                        vec_freq_tot=vec_freq_temp;
                        [select,val] = listdlg('ListString',list_freq_str,'SelectionMode','Multiple','Name','Choose Frequencies to load','PromptString','Choose Frequencies to load','InitialValue',1:length(vec_freq_tot));
                    end
                    if val==0||isempty(select)
                        continue;
                    else
                        vec_freq=vec_freq_tot(select);
                    end
                else
                    vec_freq=vec_freq_temp;
                end
            else
                vec_freq=[];
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
        
        
        if pings_range(2)-prev_ping_end<=pings_range(1)-prev_ping_start+1
            break;
        end
        
        if ~isdir(fullfile(path_f,'echoanalysisfiles'))
            mkdir(fullfile(path_f,'echoanalysisfiles'));
        end
        
       
        fileIdx=fullfile(path_f,'echoanalysisfiles',[fileN '_echoidx.mat']);
        if exist(fileIdx,'file')==0
            fprintf('Indexing file: %s\n',Filename);
            idx_raw_obj=idx_from_raw(Filename);
            save(fileIdx,'idx_raw_obj');
            disp('Done');
        else
            load(fileIdx);
            [~,et]=start_end_time_from_file(Filename);
            if abs(et-idx_raw_obj.time_dg(end))>2*nanmean(diff(idx_raw_obj.time_dg(strcmp(idx_raw_obj.type_dg,'RAW0')&idx_raw_obj.chan_dg==nanmin(idx_raw_obj.chan_dg))))
                fprintf('Re-Indexing file: %s\n',Filename);
                delete(fileIdx);
                idx_raw_obj=idx_from_raw(Filename);
                save(fileIdx,'idx_raw_obj');
                 disp('Done')
            end
        end

        [trans_obj,envdata,NMEA,mru0_att]=data_from_raw_idx_cl_v3(path_f,idx_raw_obj,'PingRange',pings_range,'SampleRange',sample_range,'Frequencies',vec_freq,'GPSOnly',p.Results.GPSOnly,'FieldNames',p.Results.FieldNames,'PathToMemmap',p.Results.PathToMemmap);

        
        if ~isa(trans_obj,'transceiver_cl')
            disp('Could not read file.')
            continue;
        end

        idx_NMEA_gps=[cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GGA'));...
            cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GLL'));...
            cellfun(@(x) ~isempty(x),regexp(NMEA.string,'RMC'))];
        
        [~,idx_GPS]=nanmax(nansum(idx_NMEA_gps,2));
        
        idx_NMEA=union(find(cellfun(@(x) ~isempty(x),regexp(NMEA.string,'(SHR|HDT|VLW|ZDA|VTG)'))),find(idx_NMEA_gps(idx_GPS,:)));
        [gps_data,attitude_full]=nmea_to_attitude_gps(NMEA.string,NMEA.time,idx_NMEA);
        
        if isempty(attitude_full)
            attitude_full=mru0_att;
        end
   
        if p.Results.GPSOnly==0
            for i =1:length(trans_obj)
                if strcmp(trans_obj(i).Config.TransceiverName(1:4),'ES70') || strcmp(trans_obj(i).Config.TransceiverName(1:4),'ES60')
                    for ki=1:length(trans_obj)
                        trans_obj(i).correctTriangleWave('EsOffset',p.Results.EsOffset);
                    end
                end 
            end
            if ~isempty(cal)
                for n=1:length(trans_obj)
                    idx_cal=find(trans_obj(n).Params.Frequency(1)==cal.F);
                    if ~isempty(idx_cal)
                        
                        tau = trans_obj(n).Params.PulseLength(1);
                        idx = find(trans_obj(n).Config.PulseLength == tau);
                        
                        if (~isempty(idx))
                            trans_obj(n).Config.SaCorrection(idx)=cal.SACORRECT(idx_cal);
                            trans_obj(n).Config.Gain(idx)=cal.G0(idx_cal);
                        else
                            trans_obj(n).Config.SaCorrection=cal.SACORRECT(idx_cal).*ones(size(trans_obj(n).Config.SaCorrection));
                            trans_obj(n).Config.Gain=cal.G0(idx_cal).*ones(size(trans_obj(n).Config.SaCorrection));
                        end
                    end
                end
            end
            
            
            if p.Results.LoadEKbot>0;
                Filename_bot=[Filename(1:end-4) '.bot'];
                if exist(Filename_bot,'file')
                    [Bottom_sim, frequencies] = readEKBotSimple(Filename_bot);
                    [~,ia1,~]=intersect(frequencies,vec_freq);
                    Bottom_sim.depth=Bottom_sim.depth(ia1,:);
                    
                    for itrans=1:length(trans_obj)
                        curr_range=trans_obj(itrans).Data.get_range();
                        depth_resampled=resample_data_v2(Bottom_sim.depth(itrans,:),Bottom_sim.time,trans_obj(itrans).Data.Time);
                        depth_resampled=depth_resampled-trans_obj(itrans).Params.TransducerDepth(1);
                        sample_idx=resample_data_v2(1:length(curr_range),curr_range,depth_resampled,'Opt','Nearest');
                        sample_idx(sample_idx==1)=nan;
                        trans_obj(itrans).setBottom(bottom_cl('Origin','Simrad','Sample_idx',sample_idx));
                    end
                end
            end
            
            
            
            prev_ping_start=pings_range(1);
            pings=trans_obj(1).Data.get_numbers();
            prev_ping_end=pings(end);
            
            if  ~isa(trans_obj,'transceiver_cl')
                continue;
            end
            
            sample_start=nan(length(trans_obj),1);
            sample_end=nan(length(trans_obj),1);
            
            for i =1:length(trans_obj)
                sample_start(i)=sample_range(1);
                if sample_range(2)==Inf
                    sample_end(i) =length(trans_obj(i).Data.get_range())+sample_start(i)-1;
                else
                    sample_end(i)=sample_range(2);
                end
            end
            
            for i =1:length(trans_obj)

                gps_data_ping=gps_data.resample_gps_data(trans_obj(i).Data.Time);
                attitude=attitude_full.resample_attitude_nav_data(trans_obj(i).Data.Time);
                
                main_path=whereisEcho();

                [~,~,algo_vec]=load_config_from_xml(fullfile(main_path,'config_echo.xml'));
                
                algo_vec_init=init_algos();
                
                algo_vec_init=reset_range(algo_vec_init,trans_obj(i).Data.get_range());
                algo_vec=reset_range(algo_vec,trans_obj(i).Data.get_range());
                trans_obj(i).GPSDataPing=gps_data_ping;
                trans_obj(i).AttitudeNavPing=attitude;
                trans_obj(i).Algo=algo_vec; trans_obj(i).add_algo(algo_vec_init);
                trans_obj(i).computeAngles();
                trans_obj(i).computeSpSv(envdata,'FieldNames',p.Results.FieldNames);
               
            end
            
        else 
            trans_obj=transceiver_cl.empty();
            envdata=env_data_cl.empty();
        end
        
        layers(uu)=layer_cl('Filename',{Filename},'Filetype','EK60','Transceivers',trans_obj,'GPSData',gps_data,'AttitudeNav',attitude_full,'EnvData',envdata);         
    end
    

    clear data transceiver
    
    
end