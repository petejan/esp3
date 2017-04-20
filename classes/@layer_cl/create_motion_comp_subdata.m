function compensation=create_motion_comp_subdata(layer,idx_freq,force)
trans_obj=layer.Transceivers(idx_freq);
if ismember('motioncompensation',trans_obj.Data.Fieldname)&&force==0
    return;
end
roll=layer.AttitudeNav.Roll;
pitch=layer.AttitudeNav.Pitch;
time_att=layer.AttitudeNav.Time;

time_pings_start=trans_obj.Time;
time_ping_vec=(trans_obj.Data.get_samples()-1)*trans_obj.Params.SampleInterval(1);

faBW=trans_obj.Config.BeamWidthAlongship;
psBW=trans_obj.Config.BeamWidthAthwartship;

compensation=create_motion_comp(pitch,roll,time_att,time_pings_start,time_ping_vec,faBW,psBW);
compensation(abs(compensation)>12)=-999;

trans_obj.Data.replace_sub_data('motioncompensation',compensation)


end

