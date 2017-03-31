function [pitch_av,pitch_std,pitch_grad_av,roll_av,roll_std,roll_grad_av] = produce_pitch_roll_analysis(layer_obj)

attitude=layer_obj.AttitudeNav;

pitch_av=0;
pitch_std=0;
pitch_grad_av=0;
roll_av=0;
roll_std=0;
roll_grad_av=0;

if isempty(attitude)
    return;
end

pitch_av=nanmean(attitude.Pitch);
roll_av=nanmean(attitude.Roll);
pitch_std=nanstd(attitude.Pitch);
roll_std=nanstd(attitude.Roll);

dt=nanmean(diff(attitude.Time*24*60*60));

pitch_grad_av=nanmean(abs(gradient(attitude.Pitch,dt)));

roll_grad_av=nanmean(abs(gradient(attitude.Roll,dt)));


end

