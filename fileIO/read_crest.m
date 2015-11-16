function layers=read_crest(PathToFile,Filename_cell,varargin)

p = inputParser;


addRequired(p,'PathToFile',@(x) ischar(x)||iscell(x));
addRequired(p,'Filename_cell',@(x) ischar(x)||iscell(x));
addParameter(p,'PathToMemmap',PathToFile);
addParameter(p,'FieldNames',{});
addParameter(p,'EsOffset',[]);
addParameter(p,'CVSCheck',0);
addParameter(p,'CVSroot','');

parse(p,PathToFile,Filename_cell,varargin{:});


dir_data=p.Results.PathToMemmap;

machineformat = 'ieee-le'; %IEEE floating point with little-endian byte ordering
precision = 'uint16'; %2-byte

cvs_root=p.Results.CVSroot;

if ~isequal(Filename_cell, 0)
    
    if ~iscell(Filename_cell)
        Filename_cell={Filename_cell};
    end
    
    
    for uu=1:length(Filename_cell)
        if iscell(PathToFile)
            path=PathToFile{uu};
        else
            path=PathToFile;
        end
        
        FileName=Filename_cell{uu};
        filenumber=str2double(FileName(end-7:end));
        fid = fopen(fullfile(path,FileName),'r',machineformat);
        
        
        if fid == -1
            warning(['Unable to open file ' sprintf('d%07d',filenumber)]);
            data=[];
        end
        idx_mess=1;
        while (true)
            type_temp=fread(fid,1,precision);
            if (feof(fid))
                break;
            end
            type(idx_mess)=type_temp;          %type (32="Bundled")
            ping_num(idx_mess)=fread(fid,1,precision);           %sequence number
            spare(idx_mess)=fread(fid,1,precision); %spare
            origin(idx_mess)=fread(fid,1,precision); %origin
            target(idx_mess)=fread(fid,1,precision); %target
            length_mess(idx_mess)=fread(fid,1,precision); %length
            
            if type(idx_mess)==32
                nb_echoes=fread(fid,1,precision);
                
                for u=1:nb_echoes
                    first_sample=fread(fid,1,precision);
                    nb_samples=fread(fid,1,precision);
                    samples=fread(fid,2*nb_samples,precision);
                    sample_real(first_sample:first_sample+nb_samples-1,idx_mess)=samples(1:2:end);              %real part of sample
                    sample_imag(first_sample:first_sample+nb_samples-1,idx_mess)=samples(2:2:end);
                    %sample_num(first_sample:first_sample+nb_samples-1,idx_mess)=(first_sample:first_sample+nb_samples-1)';
                end
                idx_mess=idx_mess+1;
            end
        end
        fclose(fid);
        
        pings=unique(ping_num);
        samples_val_real=nan(size(sample_real,1),nanmax(pings));
        samples_val_imag=nan(size(sample_real,1),nanmax(pings));
        
        for j=1:nanmax(pings)
            idx=(pings(j)==ping_num);
            samples_val_real(1:end,j)=nansum(sample_real(:,idx),2)/nansum(idx);
            samples_val_imag(1:end,j)=nansum(sample_imag(:,idx),2)/nansum(idx);
        end
        clear sample_real sample_imag ping_num;
        
        
        [gps_data,attitude_data]= read_n_file(fullfile(path,FileName));

        ifileInfo=parse_ifile(path,FileName);

        system_calibration=ifileInfo.system_calibration;
        depth_factor=ifileInfo.depth_factor;
        
        
        start_time=ifileInfo.start_date;
        end_time=ifileInfo.finish_date;
        
        survey_data=survey_data_cl('Snapshot',ifileInfo.snapshot,'Stratum',ifileInfo.stratum,'Transect',ifileInfo.transect);
        

        
        gps_data.Time=linspace(start_time,end_time,length(gps_data.Time));
        attitude_data.Time=linspace(start_time,end_time,length(attitude_data.Time));
        
        samples_num=(1:size(samples_val_imag,1))';
        range=samples_num/depth_factor;
        number=(1:size(samples_val_imag,2));
        Time=linspace(start_time,end_time,length(number));
        
        gps_data_ping=gps_data.resample_gps_data(Time);
        attitude_data_pings=attitude_data.resample_attitude_nav_data(Time);
        
        
        power=sqrt(samples_val_real.^2+samples_val_imag.^2);
        
        
        if strcmp(ifileInfo.sounder_type,'ES70')||strcmp(ifileInfo.sounder_type,'ES60')
            corr=-repmat(es60_error((1:size(power,2))-ifileInfo.es60_zero_error_ping_num),size(power,1),1);
        else
            corr=zeros(size(power));
        end
        
        sv=20*log10(power/system_calibration)+10*log10(depth_factor)+corr;
            
        [~,curr_filename,~]=fileparts(tempname);
        curr_name=fullfile(dir_data,curr_filename);
        
        sub_ac_data=[sub_ac_data_cl('power',curr_name,power) sub_ac_data_cl('sv',curr_name,sv)];
                
          ac_data_temp=ac_data_cl('SubData',sub_ac_data,...
                'Range',range,...
                'Samples',samples_num,...
                'Time',Time,...
                'Number',number,...
                'MemapName',curr_name);
            

         
         transceiver=transceiver_cl('Data',ac_data_temp,...
                'Algo',init_algos(range),...
                'GPSDataPing',gps_data_ping,...
                'Mode','CW',...
                'AttitudeNavPing',attitude_data_pings);
        [transceiver.Config,transceiver.Params]=config_from_ifile(fullfile(path,FileName));
        

            fileID = unidrnd(2^64);
            while fileID==0
                fileID = unidrnd(2^64);
            end
            
            layers(uu)=layer_cl('ID_num',fileID,'Filename',{FileName},'Filetype','CREST','PathToFile',path,'SurveyData',survey_data,...
                'Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_data,'Frequencies',38000,'OriginCrest',fullfile(path,FileName));
 
            if p.Results.CVSCheck&&~strcmp(cvs_root,'')
                layers(uu).CVS_BottomRegions(cvs_root);      
            end
            
    end
end
