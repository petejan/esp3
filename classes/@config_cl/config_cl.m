classdef config_cl
    properties
        EthernetAddress
        IPAddress
        SerialNumber
        TransceiverName
        TransceiverNumber
        TransceiverSoftwareVersion
        TransceiverType
        ChannelID
        ChannelIdShort
        ChannelNumber
        HWChannelConfiguration
        MaxTxPowerTransceiver
        PulseLength=0.001;
        AngleOffsetAlongship
        AngleOffsetAthwartship
        AngleSensitivityAlongship
        AngleSensitivityAthwartship
        Position=[0 0 0];%along across depth
        Angles=[0 0];%pitch roll
        BeamType
        BeamWidthAlongship=7;
        BeamWidthAthwartship=7;
        DirectivityDropAt2XBeamWidth
        EquivalentBeamAngle
        Frequency;
        FrequencyMaximum;
        FrequencyMinimum;
        Gain;
        MaxTxPowerTransducer;
        SaCorrection;
        TransducerName='Dummy Transducer'
        XML_string='';
    end
     
end

