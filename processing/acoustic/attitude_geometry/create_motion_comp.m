function compensation=create_motion_comp(pitch,roll,time_att,time_pings_start,time_ping_vec,faBW, psBW)
p = inputParser;

addRequired(p,'pitch',@isnumeric);
addRequired(p,'roll',@isnumeric);
addRequired(p,'time_att',@isnumeric);
addRequired(p,'time_pings_start',@isnumeric);
addRequired(p,'time_ping_vec',@isnumeric);
addRequired(p,'faBW',@isnumeric);
addRequired(p,'psBW',@isnumeric);

parse(p,pitch,roll,time_att,time_pings_start,time_ping_vec,faBW, psBW);

pitch_pings=resample_data_v2(pitch,time_att,time_pings_start,'Type','Angle');
roll_pings=resample_data_v2(roll,time_att,time_pings_start,'Type','Angle');

idx_nearest=nan(1,length(time_pings));
for iu=1:length(time_pings)
[~,idx_nearest(iu)]=min(time_att-time_pings(iu));
end

nb_samples=length(time_ping_vec);
nb_pings=length(time_pings_start);

pitch_r=nan(nb_samples,nb_pings);
roll_r=nan(nb_samples,nb_pings);

pitch_t=repmat(pitch_pings(:)',nb_samples,1);
roll_t=repmat(roll_pings(:)',nb_samples,1);

time_mat=repmat(double(time_ping_vec(:)),1,nb_pings)+repmat((60*60*24)*time_pings_start(:)',nb_samples,1);

for i=1:nb_pings
    d_pitch_temp=resample_data_v2(pitch(idx_nearest(iu):end),60*60*24*time_att(idx_nearest(iu):end),time_mat(:,i),'Type','Angle');
    d_roll_temp=resample_data_v2(roll(idx_nearest(iu):end),60*60*24*time_att(idx_nearest(iu):end),time_mat(:,i),'Type','Angle');
    nb_samples_pitch_temp=nanmin(nb_samples,length(d_pitch_temp));
    nb_samples_roll_temp=nanmin(nb_samples,length(d_roll_temp));
    pitch_r(1:nb_samples_pitch_temp,i)=d_pitch_temp(1:nb_samples_pitch_temp);
    roll_r(1:nb_samples_roll_temp,i)=d_roll_temp(1:nb_samples_roll_temp);
end

compensation = attCompensation(faBW, psBW, roll_t, pitch_t,roll_r,pitch_r);
    
end