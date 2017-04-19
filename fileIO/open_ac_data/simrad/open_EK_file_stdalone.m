%% open_EK_file_stdalone.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |Filename_cell|: TODO write description (Required. Char or cell). 
% * |PathToMemmap|: TODO write description (Optional. Char, Default: TODO).
% * |Calibration|: TODO write description (Optional. Default: empty num).
% * |Frequencies|: TODO write description (Optional. Default: empty num).
% * |PingRange|: TODO write description (Optional. Default: [1 inf]).
% * |SampleRange|: TODO write description (Optional. Default: [1 inf]).
% * |FieldNames|: TODO write description (Optional. Default: empty cell).
% * |EsOffset|: TODO write description (Optional. Default: empty num).
% * |GPSOnly|: TODO write description (Optional. Default: 0).
% * |LoadEKbot|: TODO write description (Optional. Default: 0).
% * |load_bar_comp|: TODO write description (Optional. Default: empty num).
%
% *OUTPUT VARIABLES*
%
% * |layers|: TODO write description,
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function layers = open_EK_file_stdalone(Filename_cell,varargin)

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
addParameter(p,'load_bar_comp',[]);
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
    id_rem=[];
    for uu=1:length(Filename_cell)
        try
            Filename=Filename_cell{uu};
            [path_f,fileN,~]=fileparts(Filename);
            fprintf('(%.0f/%.0f) Opening file: %s\n',uu,length(Filename_cell),fileN);
            ftype=get_ftype(Filename);
            if isempty(vec_freq_init)
                
              
                
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
                    otherwise
                        continue;
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
                            id_rem=union(id_rem,uu);
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
                idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
                save(fileIdx,'idx_raw_obj');
            else
                load(fileIdx);
                [~,et]=start_end_time_from_file(Filename);
                dgs=find((strcmp(idx_raw_obj.type_dg,'RAW0')|strcmp(idx_raw_obj.type_dg,'RAW3'))&idx_raw_obj.chan_dg==nanmin(idx_raw_obj.chan_dg));
                if et-idx_raw_obj.time_dg(dgs(end))>2*nanmax(diff(idx_raw_obj.time_dg(dgs)))
                    fprintf('Re-Indexing file: %s\n',Filename);
                    delete(fileIdx);
                    idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
                    save(fileIdx,'idx_raw_obj');
                end
            end
            
            nb_pings=idx_raw_obj.get_nb_pings_per_channels();
            
            if any(nb_pings<=1)
                id_rem=union(id_rem,uu);
                continue;
            end
            
            
            
            [trans_obj,envdata,NMEA,mru0_att]=data_from_raw_idx_cl_v3(path_f,idx_raw_obj,'PingRange',pings_range,'SampleRange',sample_range,'Frequencies',vec_freq,'GPSOnly',p.Results.GPSOnly,'FieldNames',p.Results.FieldNames,'PathToMemmap',p.Results.PathToMemmap, 'load_bar_comp',p.Results.load_bar_comp);
    
            if ~isa(trans_obj,'transceiver_cl')
                disp('Could not read file.')
                continue;
            end
            [~,fname,~]=fileparts(idx_raw_obj.filename);
            gps_file=fullfile(path_f,[fname '_gps.csv']);
            att_file=fullfile(path_f,[fname '_att.csv']);
            
            if exist(gps_file,'file')==2&&~exist(att_file,'file')
                fprintf('Using _gps.csv file as GPS input for file %s\n',Filename);
                idx_NMEA=find(cellfun(@(x) ~isempty(x),regexp(NMEA.string,'(SHR|HDT|VLW|ZDA|VTG)')));
                [~,attitude_full]=nmea_to_attitude_gps(NMEA.string,NMEA.time,idx_NMEA);
                gps_data_tmp=gps_data_cl.load_gps_from_file(gps_file);
            elseif ~exist(gps_file,'file')&&exist(att_file,'file')==2
                fprintf('Using _att.csv file as Attitude input for file %s\n',Filename);
                idx_NMEA_gps=[cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GGA'));...
                    cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GLL'));...
                    cellfun(@(x) ~isempty(x),regexp(NMEA.string,'RMC'))];
                [~,idx_GPS]=nanmax(nansum(idx_NMEA_gps,2));
                idx_NMEA=find(idx_NMEA_gps(idx_GPS,:));
                [gps_data_tmp,~]=nmea_to_attitude_gps(NMEA.string,NMEA.time,idx_NMEA);
                attitude_full= attitude_nav_cl.load_att_from_file(att_file);
            elseif exist(gps_file,'file')==2&&exist(att_file,'file')==2
                fprintf('Using _att.csv file as Attitude input for file %s\n',Filename);
                attitude_full= attitude_nav_cl.load_att_from_file(att_file);
                fprintf('Using _gps.csv file as GPS input for file %s\n',Filename);
                gps_data_tmp=gps_data_cl.load_gps_from_file(gps_file);
            else
                idx_NMEA_gps=[cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GGA'));...
                    cellfun(@(x) ~isempty(x),regexp(NMEA.string,'GLL'));...
                    cellfun(@(x) ~isempty(x),regexp(NMEA.string,'RMC'))];
                [~,idx_GPS]=nanmax(nansum(idx_NMEA_gps,2));
                idx_NMEA=union(find(cellfun(@(x) ~isempty(x),regexp(NMEA.string,'(SHR|HDT|VLW|ZDA|VTG)'))),find(idx_NMEA_gps(idx_GPS,:)));
                [gps_data_tmp,attitude_full]=nmea_to_attitude_gps(NMEA.string,NMEA.time,idx_NMEA); 
            end
            
            gps_data=gps_data_tmp.clean_gps_track();
            %gps_data=gps_data_tmp;
            if isempty(attitude_full)||~any(attitude_full.Roll)
                attitude_full=mru0_att;  
            end
            
            
            
            if p.Results.GPSOnly==0
                for i =1:length(trans_obj)
                    if trans_obj(i).need_escorr()
                        trans_obj(i).correctTriangleWave('EsOffset',p.Results.EsOffset);
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
                            curr_range=trans_obj(itrans).get_transceiver_range();
                            depth_resampled=resample_data_v2(Bottom_sim.depth(itrans,:),Bottom_sim.time,trans_obj(itrans).Data.Time);
                            depth_resampled=depth_resampled-trans_obj(itrans).Params.TransducerDepth(1);
                            sample_idx=resample_data_v2(1:length(curr_range),curr_range,depth_resampled,'Opt','Nearest');
                            sample_idx(sample_idx==1)=nan;
                            trans_obj(itrans).setBottom(bottom_cl('Origin','Simrad','Sample_idx',sample_idx));
                        end
                    end
                end
                
                
                
                prev_ping_start=pings_range(1);
                pings=trans_obj(1).get_transceiver_pings();
                prev_ping_end=pings(end);
                
                if  ~isa(trans_obj,'transceiver_cl')
                    continue;
                end
                
                sample_start=nan(length(trans_obj),1);
                sample_end=nan(length(trans_obj),1);
                
                for i =1:length(trans_obj)
                    sample_start(i)=sample_range(1);
                    if sample_range(2)==Inf
                        sample_end(i) =length(trans_obj(i).get_transceiver_range())+sample_start(i)-1;
                    else
                        sample_end(i)=sample_range(2);
                    end
                end
                
                for i =1:length(trans_obj)
                    
                    gps_data_ping=gps_data.resample_gps_data(trans_obj(i).Data.Time);
                    attitude=attitude_full.resample_attitude_nav_data(trans_obj(i).Data.Time);
                    
                    main_path=whereisEcho();
                    
                    [~,~,algo_vec]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));
                    
                    algo_vec_init=init_algos();
                    
                    algo_vec_init=reset_range(algo_vec_init,trans_obj(i).get_transceiver_range());
                    algo_vec=reset_range(algo_vec,trans_obj(i).get_transceiver_range());
                    trans_obj(i).GPSDataPing=gps_data_ping;
                    trans_obj(i).AttitudeNavPing=attitude;
                    trans_obj(i).Algo=algo_vec; trans_obj(i).add_algo(algo_vec_init);
                    trans_obj(i).computeSpSv(envdata,'FieldNames',p.Results.FieldNames);
                    
                end
                
            else
                trans_obj=transceiver_cl.empty();
                envdata=env_data_cl.empty();
            end
            
            layers(uu)=layer_cl('Filename',{Filename},'Filetype',ftype,'Transceivers',trans_obj,'GPSData',gps_data,'AttitudeNav',attitude_full,'EnvData',envdata);

        catch err
            id_rem=union(id_rem,uu);
            disp(err.message);
            fprintf('Could not open files %s\n',Filename);
            if ~isdeployed
                rethrow(err);
            end
        end
    end
    
    if length(id_rem)==length(layers)
        layers=layer_cl.empty();
    else
        layers(id_rem)=[];
    end
    
    clear data transceiver
    
    
end