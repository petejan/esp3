function [header,config]=read_config_xstruct_v2(xstruct)

conf=xstruct.Configuration;
header=conf.Header.Attributes;


Transceivers=conf.Transceivers;

nb_transceivers=length(Transceivers.Transceiver);
header.transceivercount=nb_transceivers;
i_lay=0;

for i=1:nb_transceivers
    
    if nb_transceivers>1
        Transceiver=Transceivers.Transceiver{i};
    else
        Transceiver=Transceivers.Transceiver;
    end
    
    config_temp=Transceiver.Attributes;
    
    
    Channels=Transceiver.Channels;
    Channel_tot=Channels.Channel;
    if ~iscell(Channel_tot)
        Channel_tot={Channel_tot};
    end
    
    for icha=1:length(Channel_tot)
        i_lay=i_lay+1;
        Channel=Channel_tot{icha};
        att=fieldnames(Channel.Attributes);
        for j=1:length(att)
            config_temp.(att{j})=Channel.Attributes.(att{j});
        end
        
        Transducer=Channel.Transducer;
        att=fieldnames(Transducer.Attributes);
        for j=1:length(att)
            config_temp.(att{j})=Transducer.Attributes.(att{j});
        end
        
        if isfield(Transducer,'FrequencyPar')
            att=fieldnames(Transducer.FrequencyPar{1}.Attributes);
            length_cal_fm=length(Transducer.FrequencyPar);
            for iat=1:length(att)
                freq_struct.(att{iat})=nan(1,length_cal_fm);
                
                for ic=1:length_cal_fm
                    freq_struct.(att{iat})(ic)=str2double(Transducer.FrequencyPar{ic}.Attributes.(att{iat}));
                end
            end
            config_temp.Cal_FM=freq_struct;
        end
        
        fields=fieldnames(config_temp);
        
        for jj=1:length(fields)
            if isstruct(config_temp.(fields{jj}))
                config(i_lay).(fields{jj})=config_temp.(fields{jj});
                continue;
            end
            val_temp=str2double(strsplit(config_temp.(fields{jj}),';'));
            if any(isnan(val_temp))
                config(i_lay).(fields{jj})=config_temp.(fields{jj});
            else
                config(i_lay).(fields{jj})=val_temp;
            end
        end
    end
end


if isfield(conf,'Transducers')
    
    Transducers=conf.Transducers.Transducer;
    nb_transducers=length(Transducers);
    
    for i=1:nb_transducers
        if nb_transducers>1
            Transducer=Transducers{i};
        else
            Transducer=Transducers;
        end
        
        config_temp=Transducer.Attributes;
        if isfield(config_temp,'TransducerCustomName')
            i_trans=find(~cellfun(@isempty,strfind({config(:).ChannelIdShort},config_temp.TransducerCustomName)));
        else
            i_trans=[];
        end
        
        if isempty(i_trans)
            continue;
        end
        
        att=fieldnames(Transducer.Attributes);
        for j=1:length(att)
            config_temp.(att{j})=Transducer.Attributes.(att{j});
        end
        
        fields=fieldnames(config_temp);
        
        for jj=1:length(fields)
            
            val_temp=str2double(strsplit(config_temp.(fields{jj}),';'));
            if any(isnan(val_temp))
                config(i_trans).(fields{jj})=config_temp.(fields{jj});
            else
                config(i_trans).(fields{jj})=val_temp;
            end
            
        end
    end
    
    
    
end




sensor=[];
if isfield(conf,'ConfiguredSensors')
    if isfield(conf.ConfiguredSensors,'Sensor')
        
        Sensors=conf.ConfiguredSensors.Sensor;
        nb_sensors=length(Sensors);
        
        for i=1:nb_sensors
            if nb_sensors>1
                Sensor=Sensors{i};
            else
                Sensor=Sensors;
            end
            
            sensor_temp=Sensor.Attributes;
            
            
            att=fieldnames(Sensor.Attributes);
            for j=1:length(att)
                sensor_temp.(att{j})=Sensor.Attributes.(att{j});
            end
            
            
            
            fields=fieldnames(sensor_temp);
            
            for jj=1:length(fields)
                
                val_temp=str2double(strsplit(sensor_temp.(fields{jj}),';'));
                if any(isnan(val_temp))
                    sensor(i).(fields{jj})=sensor_temp.(fields{jj});
                else
                    sensor(i).(fields{jj})=val_temp;
                end
                
            end
        end
    end
end

end