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

if ~iscell(Filename_cell)
    Filename_cell={Filename_cell};
end

if isempty(Filename_cell)
    layers=[];
    return;
end


[def_path_m,~,~]=fileparts(Filename_cell{1});

if ischar(Filename_cell)
    def_gps_only_val=1;
else
    def_gps_only_val=ones(1,numel(Filename_cell));
end

addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',def_path_m,@ischar);
addParameter(p,'Calibration',[]);
addParameter(p,'Frequencies',[]);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);
addParameter(p,'GPSOnly',def_gps_only_val);
addParameter(p,'LoadEKbot',0);
addParameter(p,'force_open',0);
addParameter(p,'load_bar_comp',[]);


parse(p,Filename_cell,varargin{:});

cal=p.Results.Calibration;
vec_freq_init=p.Results.Frequencies;

vec_freq_tot=[];

load_bar_comp=p.Results.load_bar_comp;

%profile on;
%For further profiling, it looks like the bottle neck is in
% the parsing of NMEA messages comming from the POS/MV, as they are
% recorded at 10Hz....

if numel(p.Results.GPSOnly)~=numel(Filename_cell)
    GPSOnly=ones(1,numel(Filename_cell))*p.Results.GPSOnly;
else
    GPSOnly=p.Results.GPSOnly;
end

if ~isequal(Filename_cell, 0)
    nb_files=numel(Filename_cell);

    layers(length(Filename_cell))=layer_cl();
    id_rem=[];
    
    
    
    for uu=1:nb_files
        Filename=Filename_cell{uu};
        [path_f,fileN,~]=fileparts(Filename);
        
        str_disp=sprintf('Opening File %d/%d : %s\n',uu,nb_files,Filename);
        if ~isempty(load_bar_comp)
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',nb_files,'Value',uu-1);
            load_bar_comp.status_bar.setText(str_disp);
            pause(0.1);
        else
            disp(str_disp)
        end
        
        
        try
            
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
                    list_freq_str{ki}=num2str(frequency(ki)/1e3,'%.0f kHz');
                end
                
                if GPSOnly(uu)==0
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
                    vec_freq=vec_freq_temp;
                end
            else
                vec_freq=vec_freq_init;
            end
            
            if isempty(vec_freq)
                vec_freq=-1;
            end
            
            
            if ~isdir(fullfile(path_f,'echoanalysisfiles'))
                mkdir(fullfile(path_f,'echoanalysisfiles'));
            end
            
            
            fileIdx=fullfile(path_f,'echoanalysisfiles',[fileN '_echoidx.mat']);
            
            if exist(fileIdx,'file')==0
                %idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
                idx_raw_obj=idx_from_raw_v2(Filename,p.Results.load_bar_comp);
                save(fileIdx,'idx_raw_obj');
            else
                load(fileIdx);
            end
            
            [~,et]=start_end_time_from_file(Filename);
            dgs=find((strcmp(idx_raw_obj.type_dg,'RAW0')|strcmp(idx_raw_obj.type_dg,'RAW3'))&idx_raw_obj.chan_dg==nanmin(idx_raw_obj.chan_dg));
            
            if isempty(dgs)
                fprintf('No accoustic data in file %s\n',Filename);
                id_rem=union(id_rem,uu);
                continue;
            end
            
            if et-idx_raw_obj.time_dg(dgs(end))>2*nanmax(diff(idx_raw_obj.time_dg(dgs)))
                fprintf('Re-Indexing file: %s\n',Filename);
                delete(fileIdx);
                idx_raw_obj=idx_from_raw(Filename,p.Results.load_bar_comp);
                save(fileIdx,'idx_raw_obj');
            end
            
            
            nb_pings=idx_raw_obj.get_nb_pings_per_channels();
            
            if any(nb_pings<=1)
                id_rem=union(id_rem,uu);
                fprintf('Only one ping in file %s. Ignoring it.\n',Filename);
                continue;
            end
            %
            %             [~,~,~,~]=data_from_raw_idx_cl_v4(path_f,idx_raw_obj,...
            %                 'Frequencies',vec_freq,...
            %                 'GPSOnly',GPSOnly(uu),...
            %                 'FieldNames',p.Results.FieldNames,...
            %                 'PathToMemmap',p.Results.PathToMemmap,...
            %                 'load_bar_comp',p.Results.load_bar_comp);
            
            [trans_obj,envdata,NMEA,mru0_att] =data_from_raw_idx_cl_v5(path_f,idx_raw_obj,...%new version.10% faster...
                'Frequencies',vec_freq,...
                'GPSOnly',GPSOnly(uu),...
                'FieldNames',p.Results.FieldNames,...
                'PathToMemmap',p.Results.PathToMemmap,...
                'load_bar_comp',p.Results.load_bar_comp);
            
            
            
            if isempty(trans_obj)&&GPSOnly(uu)==0
                id_rem=union(id_rem,uu);
                continue;
            end
            
            for it=1:length(trans_obj)
                prop_params=properties(trans_obj(it).Params);
                for iprop=1:length(prop_params)
                    if~any(ismember(prop_params{iprop},{'Time'}))
                        if length(unique(trans_obj(it).Params.(prop_params{iprop})))>1
                            warning('%s parameters changed during file for channel %s\n Do not use this channel and file with ESP3 yet!',prop_params{iprop},trans_obj(it).Config.ChannelID);
                        end
                    end
                end
            end
            
            
            if ~isa(trans_obj,'transceiver_cl')
                disp('Could not read file.')
                id_rem=union(id_rem,uu);
                continue;
            end
            
            if ~isempty(load_bar_comp)
                load_bar_comp.status_bar.setText(sprintf('Parsing NMEA File %s',Filename));
            end
            
            [~,fname,~]=fileparts(idx_raw_obj.filename);
            gps_file=fullfile(path_f,[fname '_gps.csv']);
            att_file=fullfile(path_f,[fname '_att.csv']);
            
            if exist(gps_file,'file')==2&&~exist(att_file,'file')
                fprintf('Using _gps.csv file as GPS input for file %s\n',Filename);
                idx_NMEA=find(ismember(NMEA.type,{'SHR' 'HDT' 'VLW'}));
                [~,attitude_full]=nmea_to_attitude_gps_v2(NMEA.string,NMEA.time,idx_NMEA);
                gps_data_tmp=gps_data_cl.load_gps_from_file(gps_file);
            elseif ~exist(gps_file,'file')&&exist(att_file,'file')==2
                fprintf('Using _att.csv file as Attitude input for file %s\n',Filename);
                idx_NMEA_gps=[strcmpi(NMEA.type,'GGA');...
                    strcmpi(NMEA.type,'GLL');...
                    strcmpi(NMEA.type,'RMC')];
                
                [~,idx_GPS]=max(sum(idx_NMEA_gps,2));
                idx_NMEA=find(idx_NMEA_gps(idx_GPS,:));
                [gps_data_tmp,~]=nmea_to_attitude_gps_v2(NMEA.string,NMEA.time,idx_NMEA);
                attitude_full= attitude_nav_cl.load_att_from_file(att_file);
            elseif exist(gps_file,'file')==2&&exist(att_file,'file')==2
                fprintf('Using _att.csv file as Attitude input for file %s\n',Filename);
                attitude_full= attitude_nav_cl.load_att_from_file(att_file);
                fprintf('Using _gps.csv file as GPS input for file %s\n',Filename);
                gps_data_tmp=gps_data_cl.load_gps_from_file(gps_file);
            else
                idx_NMEA_gps=[strcmpi(NMEA.type,'GGA');...%20 times faster than the old way...
                    strcmpi(NMEA.type,'GLL');...
                    strcmpi(NMEA.type,'RMC')];
                [~,idx_GPS]=max(sum(idx_NMEA_gps,2));
                idx_NMEA=find(ismember(NMEA.type,{'SHR' 'HDT' 'VLW'})|idx_NMEA_gps(idx_GPS,:));
                [gps_data_tmp,attitude_full]=nmea_to_attitude_gps_v2(NMEA.string,NMEA.time,idx_NMEA);
            end
            
            gps_data=gps_data_tmp.clean_gps_track();
            %gps_data=gps_data_tmp;
            if isempty(attitude_full)||~any(attitude_full.Roll)
                attitude_full=mru0_att;
            end
            
            idx_NMEA_dft=find(strcmpi(NMEA.type,'DFT'));
            if ~isempty(idx_NMEA_dft)
                [trans_depth,depth_time]=nmea_to_depth_trans(NMEA.string,NMEA.time,idx_NMEA_dft);
            else
                trans_depth=[];
                depth_time=[];
            end
            
            if GPSOnly(uu)==0
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
                
                
                if p.Results.LoadEKbot>0
                    Filename_bot=[Filename(1:end-4) '.bot'];
                    if exist(Filename_bot,'file')
                        [Bottom_sim, frequencies] = readEKBotSimple(Filename_bot);
                        [~,ia1,~]=intersect(frequencies,vec_freq);
                        Bottom_sim.depth=Bottom_sim.depth(ia1,:);
                        
                        for itrans=1:length(trans_obj)
                            curr_range=trans_obj(itrans).get_transceiver_range();
                            depth_resampled=resample_data_v2(Bottom_sim.depth(itrans,:),Bottom_sim.time,trans_obj(itrans).Time);
                            depth_resampled=depth_resampled-trans_obj(itrans).Params.TransducerDepth;
                            sample_idx=resample_data_v2(1:length(curr_range),curr_range,depth_resampled,'Opt','Nearest');
                            sample_idx(sample_idx==1)=nan;
                            trans_obj(itrans).Bottom=bottom_cl('Origin','Simrad','Sample_idx',sample_idx);
                        end
                    end
                end
                for itrans=1:length(trans_obj)
                    if~isempty(trans_depth)
                        trans_depth_resampled=resample_data_v2(trans_depth,depth_time,trans_obj(itrans).Time);
                        trans_depth_resampled(isnan(trans_depth_resampled))=0;
                        trans_obj(itrans).Params.TransducerDepth=trans_depth_resampled;
                    end
                end
                
                if  ~isa(trans_obj,'transceiver_cl')
                    id_rem=union(id_rem,uu);
                    continue;
                end
                load_bar_comp.status_bar.setText(sprintf('Computing Sv for File %s',Filename));
                for i =1:length(trans_obj)
                    gps_data_ping=gps_data.resample_gps_data(trans_obj(i).Time);
                    attitude=attitude_full.resample_attitude_nav_data(trans_obj(i).Time);
                    [~,~,algo_vec,~]=load_config_from_xml_v2(0,0,1);
                    algo_vec_init=init_algos();
                    algo_vec_init=reset_range(algo_vec_init,trans_obj(i).get_transceiver_range());
                    algo_vec=reset_range(algo_vec,trans_obj(i).get_transceiver_range());
                    trans_obj(i).GPSDataPing=gps_data_ping;
                    trans_obj(i).AttitudeNavPing=attitude;
                    trans_obj(i).add_algo(algo_vec_init);
                    trans_obj(i).add_algo(algo_vec);                    
                    trans_obj(i).computeSpSv_v2(envdata,'FieldNames',p.Results.FieldNames);
                    
                end
            end
            
            layers(uu)=layer_cl('Filename',{Filename},'Filetype',ftype,'GPSData',gps_data,'AttitudeNav',attitude_full,'EnvData',envdata);
            
            for i=1:length(trans_obj)
                layers(uu).add_trans(trans_obj(i));
            end
            
            layers(uu).add_lines(line_cl('Name','TransducerDepth','Range',trans_depth,'Time',depth_time));
            
        catch err
            id_rem=union(id_rem,uu);
            disp(err.message);
            warning('Could not open files %s\n',Filename);
            [~,f_temp,e_temp]=fileparts(err.stack(1).file);
            warning('Error in file %s, line %d\n',[f_temp e_temp],err.stack(1).line);
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
    
    clear('data','transceiver');
    
    %      profile off;
    %      profile viewer;
    
end