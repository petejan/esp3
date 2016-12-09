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
            config(i).(fields{jj})=config_temp.(fields{jj});
            continue;
        end
        val_temp=str2double(strsplit(config_temp.(fields{jj}),';'));
        if any(isnan(val_temp))
            config(i).(fields{jj})=config_temp.(fields{jj});
        else
            config(i).(fields{jj})=val_temp;
        end
    end
end
% 
% if isfield(conf,'Transducers')
%     
%     Transducers=conf.Transducers.Transducer;
%     nb_transducers=length(Transducers);
%     
%     for i=1:nb_transducers
%         if nb_transducers>1
%             Transducer=Transducers{i};
%         else
%             Transducer=Transducers;
%         end
%         
%         config_temp=Transducer.Attributes;
%         
%         
%         att=fieldnames(Transducer.Attributes);
%         for j=1:length(att)
%             config_temp.(att{j})=Transducer.Attributes.(att{j});
%         end
%         
%         
%         
%         fields=fieldnames(config_temp);
%         
%         for jj=1:length(fields)
%             
%             val_temp=str2double(strsplit(config_temp.(fields{jj}),';'));
%             if any(isnan(val_temp))
%                 config_trans(i).(fields{jj})=config_temp.(fields{jj});
%             else
%                 config_trans(i).(fields{jj})=val_temp;
%             end
%             
%         end
%     end
%     
% else
%     
%     config_trans=[];
% end

end