function [header,config]=read_config_xstruct_v2(xstruct)

conf=xstruct.Configuration;
header=conf.Header.Attributes;


Transceivers=conf.Transceivers;

nb_transceivers=length(Transceivers.Transceiver);
header.transceivercount=nb_transceivers;


for i=1:nb_transceivers
    if nb_transceivers>1
        Transceiver=Transceivers.Transceiver{i};
    else
        Transceiver=Transceivers.Transceiver;
    end

    config_temp=Transceiver.Attributes;

    
    Channels=Transceiver.Channels;
    Channel=Channels.Channel;
    att=fieldnames(Channel.Attributes);
    for j=1:length(att)
        config_temp.(att{j})=Channel.Attributes.(att{j});
    end
    
    Transducer=Channel.Transducer;
    att=fieldnames(Transducer.Attributes);
    for j=1:length(att)
        config_temp.(att{j})=Transducer.Attributes.(att{j});
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