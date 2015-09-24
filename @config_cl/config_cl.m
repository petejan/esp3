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
        Frequency=38000;
        FrequencyMaximum=38000;
        FrequencyMinimum=38000;
        Gain=-26;
        MaxTxPowerTransducer=1000;
        SaCorrection=0;
        TransducerName='Dummy Transducer'
    end
     
end

