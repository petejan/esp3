function [config_obj,params_obj]=config_from_ifile(ifile)
config_obj=config_cl();
params_obj=params_cl();


% version: CREST V1.0
% compression: Bundled
% snapshot: 1
% stratum: trawl
% transect: 2
% start_date: Thu Jan 03 10:29:06 2013
% start: LAT:  43 34.8800 S    LONG: 174 28.0400 E
% start: HDG: 73  SOG: 5.7
% start: GMT: 22:29:06
% finish_date: Thu Jan 03 11:38:42 2013
% finish: LAT:  43 33.2700 S    LONG: 174 34.0800 E
% finish: HDG: 71  SOG: 3.4
% finish: GMT: 23:38:42
% #####################
% 10@depth_factor = 5.22964
% 10@system_calibration = 2e+06
% 10@angle_factor = 21.9 # mean
% 10@angle_factor_alongship = 21.9
% 10@angle_factor_athwartship = 21.9
% 10@absorption_coefficient = 9.78527
% 10@sound_speed = 1493.89
% 10@TVG_type = 20
% 10@TVG = on
% 10@transducer_id = ES38B_23083
% sounder_type = ER60
% # converted using command:
% # convertEk60ToCrest -x ES38B_23083 -q 38 -t 20 -c 2e6 -g 25.62 -s -0.61 -o 10 -r ek60/tan1301-D20130102-T222859.raw d17 
% # Run by user aca on computer esp2vm, started at Fri Jan  4 00:18:21 2013
% 

ifileInfo=parse_ifile(ifile);

config_obj.EthernetAddress='';
config_obj.IPAddress='';
config_obj.SerialNumber='';
config_obj.TransceiverName='CREST';
config_obj.TransceiverNumber=nan;
config_obj.TransceiverSoftwareVersion='';
config_obj.TransceiverType='';
config_obj.ChannelID=ifileInfo.transducer_id;
config_obj.ChannelIdShort='';
config_obj.ChannelNumber=nan;
config_obj.HWChannelConfiguration=nan;
config_obj.MaxTxPowerTransceiver=nan;
config_obj.PulseLength=nan;
config_obj.AngleOffsetAlongship=0;
config_obj.AngleOffsetAthwartship=0;
config_obj.AngleSensitivityAlongship=ifileInfo.angle_factor_alongship;
config_obj.AngleSensitivityAthwartship=ifileInfo.angle_factor_alongship;
config_obj.BeamType='singlebeam';
config_obj.BeamWidthAlongship=7;
config_obj.BeamWidthAthwartship=7;
config_obj.DirectivityDropAt2XBeamWidth=nan;
config_obj.EquivalentBeamAngle=nan;
config_obj.Frequency=38000;
config_obj.FrequencyMaximum=38000;
config_obj.FrequencyMinimum=38000;
config_obj.Gain=nan;
config_obj.MaxTxPowerTransducer=nan;
config_obj.SaCorrection=nan;
config_obj.TransducerName='';

params_obj.Time=nan;
params_obj.BandWidth=nan;
params_obj.ChannelID={ifileInfo.transducer_id};
params_obj.ChannelMode={''};
params_obj.FrequencyEnd=38000;
params_obj.FrequencyStart=38000;
params_obj.PulseForm=nan;

if isnan(ifileInfo.sound_speed)
    soundspeed=1500;
else
    soundspeed=ifileInfo.sound_speed;
end

if isnan(ifileInfo.transmit_pulse_length)
    params_obj.PulseLength=1/ifileInfo.depth_factor/soundspeed*4;
else
    params_obj.PulseLength=1/ifileInfo.depth_factor/soundspeed*ifileInfo.transmit_pulse_length; 
end

params_obj.SampleInterval=1/ifileInfo.depth_factor/soundspeed;
params_obj.Slope=nan;
params_obj.TransducerDepth=0;
params_obj.TransmitPower=nan;
params_obj.Absorption=ifileInfo.absorption_coefficient/1000;

end