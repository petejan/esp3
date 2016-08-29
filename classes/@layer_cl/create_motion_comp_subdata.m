function create_motion_comp_subdata(layer,idx_freq)

roll=layer.AttitudeNav.Roll;
pitch=layer.AttitudeNav.Pitch;
time_att=layer.AttitudeNav.Time;
trans_obj=layer.Transceivers(idx_freq);
time_pings_start=trans_obj.Data.Time;
time_ping_vec=(trans_obj.Data.get_samples()-1)*trans_obj.Params.SampleInterval(1);

faBW=trans_obj.Config.BeamWidthAlongship;
psBW=trans_obj.Config.BeamWidthAthwartship;

compensation=create_motion_comp(pitch,roll,time_att,time_pings_start,time_ping_vec,faBW,psBW);

trans_obj.Data.add_sub_data('motioncompensation',compensation);


end

