function [config_obj,params_obj]=config_from_ek60(pings,config)
config_obj=config_cl();
params_obj=params_cl();

config_obj.EthernetAddress='';
config_obj.IPAddress='';
config_obj.ChannelID=config.channelid;
config_obj.ChannelIdShort=config.channelid;
%''GPT 200 kHz 00907205da23 5-1 ES200-7C'

config_obj.SerialNumber='';
config_obj.TransducerSerialNumber='';
config_obj.TransceiverType='GPT';
config_obj.TransducerName='';
out=textscan(config_obj.ChannelID,'GPT %d kHz %s %d-%d %s');

if ~isempty(out{2})
    config_obj.SerialNumber=out{2}{1};
end

if ~isempty(out{5})
    config_obj.TransducerName=out{5}{1};
end

config_obj.TransceiverName=config.soundername;
% config_obj.TransceiverNumber=[];
config_obj.TransceiverSoftwareVersion=-1;


% config_obj.ChannelNumber=[];
% config_obj.HWChannelConfiguration=[];
% config_obj.MaxTxPowerTransceiver=[];
config_obj.PulseLength=config.pulselengthtable;
config_obj.AngleOffsetAlongship=config.anglesoffsetalongship;
config_obj.AngleOffsetAthwartship=config.angleoffsetathwartship;
config_obj.AngleSensitivityAlongship=config.anglesensitivityalongship;
config_obj.AngleSensitivityAthwartship=config.anglesensitivityathwartship;
config_obj.BeamType=config.beamtype;
config_obj.BeamWidthAlongship=config.beamwidthalongship;
config_obj.BeamWidthAthwartship=config.beamwidthathwartship;
% config_obj.DirectivityDropAt2XBeamWidth=[];
config_obj.EquivalentBeamAngle=config.equivalentbeamangle;
config_obj.Frequency=config.frequency;
config_obj.FrequencyMaximum=config.frequency;
config_obj.FrequencyMinimum=config.frequency;
config_obj.Gain=config.gaintable;
config_obj.MaxTxPowerTransducer=0;
config_obj.SaCorrection=config.sacorrectiontable;

if ~isempty(pings)
    params_obj.Time=pings.time;
    params_obj.BandWidth=pings.bandwidth;
    params_obj.ChannelID=cell(1,length(pings.time));
    params_obj.ChannelID(:)={config.channelid};
    params_obj.ChannelMode=pings.mode;
    params_obj.Frequency=pings.frequency;
    params_obj.FrequencyEnd=pings.frequency;
    params_obj.FrequencyStart=pings.frequency;
    params_obj.PulseForm=zeros(1,length(pings.time));
    params_obj.PulseLength=pings.pulselength;
    params_obj.SampleInterval=pings.sampleinterval;
    params_obj.Slope=zeros(1,length(pings.time));
    params_obj.TransducerDepth=pings.transducerdepth;
    params_obj.TransmitPower=pings.transmitpower;
    params_obj.Absorption=double(pings.absorptioncoefficient);
end



end