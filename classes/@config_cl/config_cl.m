classdef config_cl
    properties
        EthernetAddress='';
        IPAddress='';
        SerialNumber=0;
        TransceiverName='';
        TransceiverNumber=0;
        TransceiverSoftwareVersion=0;
        TransceiverType='';
        ChannelID='';
        ChannelIdShort='';
        ChannelNumber=0;
        HWChannelConfiguration=0;
        MaxTxPowerTransceiver=0;
        PulseLength=0.001;
        AngleOffsetAlongship=0;
        AngleOffsetAthwartship=0;
        AngleSensitivityAlongship=0;
        AngleSensitivityAthwartship=0;
        Position=[0 0 0];%along across depth
        Angles=[0 0];%pitch roll
        BeamType=1;
        BeamWidthAlongship=7;
        BeamWidthAthwartship=7;
        DirectivityDropAt2XBeamWidth=0;
        EquivalentBeamAngle=0;
        Frequency=0;
        FrequencyMaximum=0;
        FrequencyMinimum=0;
        Gain=0;
        Impedance=1e3;%ohms
        Ztrd=75;%ohms
        MaxTxPowerTransducer=0;
        SaCorrection=0;
        TransducerName=''
        XML_string='';
        Cal_FM=struct.empty();
        TransducerAlphaX=0;
        TransducerAlphaY=0;
        TransducerAlphaZ=0;
        TransducerCustomName='';
        TransducerMounting='';
        TransducerOffsetX=0;
        TransducerOffsetY=0;
        TransducerOffsetZ=0;
        TransducerOrientation='';
        TransducerSerialNumber=0;
        MarketSegment='';
        Version='';
        PulseDurationFM=[];
        ArticleNumber=0;
        
    end
    
    methods
        function config_str=config2str(config_obj)
            fields={'ChannelID',...
                'ChannelIdShort',...
                'TransducerName',...
                'TransceiverSoftwareVersion',...
                'IPAddress',...
                'Frequency',...
                'FrequencyMaximum',...
                'FrequencyMinimum',...
                'BeamWidthAlongship',...
                'BeamWidthAthwartship',...
                'BeamType',...
                'PulseLength',...
                'Gain',...
                'SaCorrection'...
                'EquivalentBeamAngle',...
                'AngleOffsetAlongship',...
                'AngleOffsetAthwartship',...
                'AngleSensitivityAlongship',...
                'AngleSensitivityAthwartship'};
            
            fields_name={'Channel ID',...
                'Channel ID (short)',...
                'Transducer Name',...
                'Transceiver Software Version',...
                'IP Address',...
                'Frequency',...
                'Max Frequency',...
                'Min Frequency',...
                'BeamWidth Alongship',...
                'BeamWidth Athwartship',...
                'Beam Type',...
                'Pulse Length Table',...
                'Gain Table',...
                'Sa Correction Table',...
                'Equivalent Beam Angle'...
                'Angle Offset Alongship',...
                'Angle Offset Athwartship',...
                'Angle Sensitivity Alongship',...
                'Angle Sensitivity Athwartship'};
            
            fields_fmt={'%s',...
                '%s',...
                '%s',...
                'ver: %d',...
                '%s',...
                '%d Hz',...
                '%d Hz',...
                '%d Hz',...
                '%.2f&deg',...
                '%.2f&deg',...
                '%d',...
                '%.6f s ',...
                '%.2f dB ',...
                '%.2f dB ',...
                '%.2f dB ',...
                '%.2f&deg',...
                '%.2f&deg',...
                '%d',...
                '%d'};
            
            
            config_str ='<html><ul>Configuration:';
            
            for ifi=1:length(fields)
                config_str = [config_str '<li><i>' fields_name{ifi} ': </i>' sprintf(fields_fmt{ifi},config_obj.(fields{ifi})) '</li>'];
            end
            config_str = [config_str '</ul></html>'];
        end
        function delete(obj)
            
            if ~isdeployed
                c = class(obj);
                disp(['ML object destructor called for class ',c])
            end
        end
    end
end

