function [header,config]=read_config_xstruct(xstruct)

Header=xstruct.Children(1);

for j=1:length(Header.Attributes)
    header.(Header.Attributes(j).Name)=Header.Attributes(j).Value;
end

Transceivers=xstruct.Children(2);

nb_transceivers=length(Transceivers.Children);
header.transceivercount=nb_transceivers;
for i=1:nb_transceivers
    Transceiver=Transceivers.Children(i);
    for j=1:length(Transceiver.Attributes)
        config_temp.(Transceiver.Attributes(j).Name)=Transceiver.Attributes(j).Value;
    end
    
    Channels=Transceiver.Children(1);
    Channel=Channels.Children(1);
    
    for j=1:length(Channel.Attributes)
        config_temp.(Channel.Attributes(j).Name)=Channel.Attributes(j).Value;
    end
    
    Transducer=Channel.Children(1);
    for j=1:length(Transducer.Attributes)
        config_temp.(Transducer.Attributes(j).Name)=Transducer.Attributes(j).Value;
    end
    
    fields=fieldnames(config_temp);
    
    for jj=1:length(fields)
        switch fields{jj}
            case {'ChannelID' ,'ChannelIdShort' ,'TransducerName','Version','TransceiverType','TransceiverName','EthernetAddress','IPAddress'}
                config(i).(fields{jj})=(config_temp.(fields{jj}));
            case {'Gain','PulseLength','SaCorrection'}
                config(i).(fields{jj})=str2double(strsplit(config_temp.(fields{jj}),';'));
            otherwise
                config(i).(fields{jj})=str2double(config_temp.(fields{jj}));
        end
    end
end

end