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
nb_samples=length(time_ping_vec);
nb_pings=length(time_pings_start);

if ~isempty(time_att)
    pitch_pings=resample_data_v2(pitch,time_att,time_pings_start,'Type','Angle');
    roll_pings=resample_data_v2(roll,time_att,time_pings_start,'Type','Angle');
    
    % idx_nearest=nan(1,length(time_pings));
    % for iu=1:length(time_pings)
    % [~,idx_nearest(iu)]=min(time_att-time_pings(iu));
    % end
    %
    
    pitch_r=nan(nb_samples,nb_pings);
    roll_r=nan(nb_samples,nb_pings);
    
    pitch_t=repmat(pitch_pings(:)',nb_samples,1);
    roll_t=repmat(roll_pings(:)',nb_samples,1);
    
    time_mat=repmat(double(time_ping_vec(:)),1,nb_pings)+repmat((60*60*24)*time_pings_start(:)',nb_samples,1);
    
    
    for i=1:nb_pings
        pitch_r(:,i)=resample_data_v2(pitch,60*60*24*time_att,time_mat(:,i),'Type','Angle');
        roll_r(:,i)=resample_data_v2(roll,60*60*24*time_att,time_mat(:,i),'Type','Angle');
    end
    compensation = attCompensation(faBW, psBW, roll_t, pitch_t,roll_r,pitch_r);   
else
    compensation=zeros(nb_samples,nb_pings);   
end

end