function open_EK80_files(main_figure,PathToFile,Filename,vec_freq_init,ping_start,ping_end,multi_layer,join)
curr_disp=getappdata(main_figure,'Curr_disp');
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

if multi_layer<0
    multi_layer=0;
end
ite=1;
vec_freq_tot=[];
list_freq_str={};

if ~isequal(Filename, 0)
    
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    if ite==0
        nb_layers=1;
    else
        nb_layers=length(Filename);
    end
    
    prev_ping_end=0;
    prev_ping_start=1;
    
    for uuu=1:nb_layers
        vec_freq_temp=[];
        
        if ite==1&&iscell(Filename)
            curr_Filename=Filename{uuu};
        else
            curr_Filename=Filename;
        end
        
        if ping_end-prev_ping_end<=ping_start-prev_ping_start+1
            break;
        end
        
        
        if isempty(vec_freq_init)
            [header_temp,data_temp]=readEK80(PathToFile,curr_Filename,'PingRange',[1 1]);
            
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
        
        
        [header,data]=readEK80(PathToFile,curr_Filename,'PingRange',[ping_start-prev_ping_start+1 ping_end-prev_ping_end],'Frequencies',vec_freq);
        
        
        if ~isstruct(header)
            if exist('opening_file','var')
                close(opening_file);
            end
            return;
        end
        
        try
            waitbar(uuu/nb_layers,opening_file,['Opening file: ',curr_Filename],'WindowStyle','Modal');
        catch
            opening_file=waitbar(uuu/nb_layers,['Opening file: ',curr_Filename],'Name','Opening files','WindowStyle','Modal');
        end
        
        
        if iscell(curr_Filename)
            if length(curr_Filename)>1
                data=reorder_ping(data);
            end
        end
        data_ori=data;
        [data,mode]=match_filter_data(data);
        
        
        data=compute_PwEK80(data);
        data_ori=compute_PwEK80(data_ori);
        
        data=computesPhasesAngles(data);
        data_ori=computesPhasesAngles(data_ori);
        
        if isfield(data,'gps')
            gps_data=gps_data_cl('Lat',data.gps.lat','Long',data.gps.lon','Time',data.gps.time');
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
        
        
        for i =1:header.transceivercount
            
            
            curr_data.powerunmatched=single(data_ori.pings(i).power);
            curr_data.power=single(data.pings(i).power);
            curr_data.y_real=single(real(data.pings(i).y));
            curr_data.y_imag=single(imag(data.pings(i).y));
            curr_data.acrossangle=single(data.pings(i).AcrossAngle);
            curr_data.alongangle=single(data.pings(i).AlongAngle);
            

            fileID = unidrnd(2^64);
            [~,found]=find_layer_idx(layers,fileID);
            
            while found==1||fileID==0
                warning('Who, that''s extremely unlikely!')
                fileID = unidrnd(2^64);
                [~,found]=find_layer_idx(layers,fileID);
            end
            
            dir_data=app_path.data;
            [~,curr_filename,~]=fileparts(tempname);
            curr_name=fullfile(dir_data,curr_filename);
            
            ff=fields(curr_data);
            sub_ac_data_temp=[];
            
            for uuuk=1:length(ff)
                sub_ac_data_temp=[sub_ac_data_temp sub_ac_data_cl(ff{uuuk},curr_name,curr_data.(ff{uuuk}))];
            end
            
            ac_data_temp=ac_data_cl('SubData',sub_ac_data_temp,...
                'Range',double(data.pings(i).range),...
                'Samples',double(data.pings(i).samples),...
                'Time',double(data.pings(i).time),...
                'Number',double(data.pings(i).number),...
                'MemapName',curr_name);
            
            
            clear curr_data;
            
            
            gps_data_ping=gps_data.resample_gps_data(data.pings(i).time);
            
            attitude=attitude_full.resample_attitude_nav_data(data.pings(i).time);
            
            r=data.pings(i).range;
            
            algo_vec=init_algos(r);
            
            
            if multi_layer==0
                prev_ping_start=ping_start;
                prev_ping_end=data.pings(i).number(end);
            else
                prev_ping_start=1;
                prev_ping_end=0;
            end
            
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
            
            computeSpSv(transceiver(i),envdata)
        end
        
        layer_new=layer_cl('ID_num',fileID,'Filename',curr_Filename,'Filetype','EK80','PathToFile',PathToFile,'Transceivers',transceiver,'GPSData',gps_data,'AttitudeNav',attitude_full,'Frequencies',freq,'EnvData',envdata);
        
        
        
        
        if ite==1
            layers_temp(uuu)=layer_new;
        end
    end
    
    [layers,layer]=shuffle_layers(layers,layers_temp,multi_layer,join);
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    curr_disp.Freq=layer.Frequencies(idx_freq);
    curr_disp.setField('sv');
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Layers',layers);
    setappdata(main_figure,'Curr_disp',curr_disp);
    if exist('opening_file','var')
        close(opening_file);
    end
    
    clear data transceiver
    
end