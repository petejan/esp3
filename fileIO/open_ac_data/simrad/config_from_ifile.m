function [config_obj,params_obj]=config_from_ifile(ifile,nb_pings)
config_obj=config_cl();
params_obj=params_cl(nb_pings);


ifileInfo=parse_ifile(ifile);


config_obj.TransceiverName='CREST';
config_obj.AngleSensitivityAlongship=ifileInfo.angle_factor_alongship;
config_obj.AngleSensitivityAthwartship=ifileInfo.angle_factor_alongship;
config_obj.BeamType='singlebeam';
config_obj.BeamWidthAlongship=7;
config_obj.BeamWidthAthwartship=7;
config_obj.Frequency=38000;
config_obj.FrequencyMaximum=38000;
config_obj.FrequencyMinimum=38000;

params_obj.ChannelID(:)={ifileInfo.transducer_id};
params_obj.FrequencyEnd(:)=38000;
params_obj.FrequencyStart(:)=38000;


if isnan(ifileInfo.sound_speed)
    soundspeed=1500;
else
    soundspeed=ifileInfo.sound_speed;
end

if isnan(ifileInfo.transmit_pulse_length)
    params_obj.PulseLength(:)=1/ifileInfo.depth_factor/soundspeed*2;
else
    params_obj.PulseLength(:)=1/ifileInfo.depth_factor/soundspeed*ifileInfo.transmit_pulse_length; 
end

params_obj.SampleInterval(:)=1/ifileInfo.depth_factor/soundspeed;
params_obj.TransducerDepth(:)=0;
params_obj.Absorption(:)=ifileInfo.absorption_coefficient/1000;

end