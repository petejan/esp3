
function  layers=open_EK60_file_stdalone(Filename_cell,varargin)

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

parse(p,Filename_cell,varargin{:});


dir_data=p.Results.PathToMemmap;
cal=p.Results.Calibration;
vec_freq_init=p.Results.Frequencies;
pings_range=p.Results.PingRange;
sample_range=p.Results.SampleRange;

vec_freq_tot=[];


if ~isequal(Filename_cell, 0)
    
  
    prev_ping_end=0;
    prev_ping_start=1;
    nb_lay=0;
    for uu=1:length(Filename_cell)
        
        Filename=Filename_cell{uu};
        [path_f,fileN,~]=fileparts(Filename);

        
        if isempty(vec_freq_init)
            %             try
            %                 [header_temp,data_temp, ~]=readEKRaw(fullfile(path_f,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0);
            %                 AllowModeChange=false;
            %             catch err
            %                 if (strcmp(err.identifier,'readEKRaw:ModeChange'))
            %                     [header_temp,data_temp, ~]=readEKRaw(fullfile(path_f,Filename),'PingRange',[1 1],'SampleRange',[1 1],'GPS',0,'AllowModeChange',true);
            %                     AllowModeChange=true;
            %                 else
            %                     disp(['Cannot open file ' Filename]);
            %                     continue;
            %                 end
            %             end
            
            
            fid=fopen(Filename,'r');
            [~, frequency] = readEKRaw_ReadHeader(fid);
            fclose(fid);
            
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
                    vec_freq=[];
                end
            else
                vec_freq=[];
            end
        else
            %AllowModeChange=false;
            vec_freq=vec_freq_init;
        end
        
        if isempty(vec_freq)
            vec_freq=-1;
        end
        
        
        try
            waitbar(uu/length(Filename_cell),opening_file,sprintf('Opening file: %s',fileN), 'WindowStyle', 'modal');
        catch
            opening_file=waitbar(uu/length(Filename_cell),sprintf('Opening file: %s',fileN),'Name','Opening files', 'WindowStyle', 'modal');
        end
        
        pings_range(1)=pings_range(1)-prev_ping_start+1;
        if pings_range(2)~=Inf
            pings_range(2)=pings_range(2)-prev_ping_end;
        end
        
        
        if pings_range(2)-prev_ping_end<=pings_range(1)-prev_ping_start+1
            break;
        end
        
        %         try
        %             [header,data, ~]=readEKRaw(fullfile(path_f,Filename),'MaxBadBytes',0,'PingRange',pings_range,'SampleRange',sample_range,'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',AllowModeChange);
        %         catch err2
        %             disp(err2.message);
        %             [header,data, ~]=readEKRaw(fullfile(path_f,Filename),'MaxBadBytes',0,'AllowModeChange',true,'PingRange',pings_range,'SampleRange',sample_range,'GPS',0,'RawNMEA','True','Frequencies',vec_freq,'AllowModeChange',true);
        %             AllowModeChange=true;
        %         end
        
        if ~isdir(fullfile(path_f,'echoanalysisfiles'))
            mkdir(fullfile(path_f,'echoanalysisfiles'));
        end
        fileIdx=fullfile(path_f,'echoanalysisfiles',[fileN '_echoidx.mat']);
        if exist(fileIdx,'file')==0
            idx_raw_obj=idx_from_rawEK60(Filename);
            save(fileIdx,'idx_raw_obj');
        else
            load(fileIdx);
        end
        
        [header,data]=data_from_raw_idx_cl(path_f,idx_raw_obj,'PingRange',pings_range,'SampleRange',sample_range,'Frequencies',vec_freq,'GPSOnly',p.Results.GPSOnly);
        
        
        if isnumeric(header)
            disp('Could not read file.')
            
            continue;
        end
        nb_lay=nb_lay+1;
        
        idx_NMEA=find(cellfun(@(x) ~isempty(x),regexp(data.NMEA.string,'(SHR|HDT|GGA|GGL|VLW)')));
        [gps_data,attitude_full]=nmea_to_attitude_gps(data.NMEA.string,data.NMEA.time,idx_NMEA);
        
        
        if p.Results.GPSOnly==0
            if strcmp(header.soundername(1:4),'ES70') || strcmp(header.soundername(1:4),'ES60')
                for ki=1:header.transceivercount
                    data.pings(ki).power=correctES60(data.pings(ki).power,p.Results.EsOffset);
                end
            end
            
            prev_ping_start=pings_range(1);
            prev_ping_end=data.pings(1).number(end);
            
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
            
            if exist(Filename_bot,'file')
                [~,temp, ~] = readEKBot(Filename_bot, calParms,'Frequencies',vec_freq);
                
                
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
            
            
            
            freq=nan(1,header.transceivercount);
            
            for i =1:header.transceivercount
                
                curr_data.power=single(db2pow_perso(data.pings(i).power));
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
                
                bot= bottom_cl('Origin','Simrad','Range',Bottom_sim(i,:),'Sample_idx',Bottom_sim_idx(i,:));
                
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
                %transceiver(i).computeSp_comp();
                
            end
            
        else
            
            transceiver=transceiver_cl.empty();
            envdata=env_data_cl.empty();
        end
        
        layers_temp(nb_lay)=layer_cl('Filename',{Filename},'Filetype','EK60','Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_full,'EnvData',envdata);
        
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